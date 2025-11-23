function metrics = channel_model_multiprotocol(droneLat, droneLon, droneAlt, userLat, userLon, weather, cfg)
% Calculate channel metrics for multiple protocols
% Returns struct with metrics for each protocol

% Calculate 3D distance
R = 6371e3; % Earth radius in meters
phi1 = deg2rad(droneLat);
phi2 = deg2rad(userLat);
dphi = deg2rad(userLat - droneLat);
dlambda = deg2rad(userLon - droneLon);

a = sin(dphi/2)^2 + cos(phi1) * cos(phi2) * sin(dlambda/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
d_horizontal = R * c; % horizontal distance in meters

d_3d = sqrt(d_horizontal^2 + droneAlt^2); % 3D distance
if d_3d < 1, d_3d = 1; end

% Weather impact factors
rain_loss_dB = 0;
if weather.rain
    rain_loss_dB = 2 + rand()*3; % 2-5 dB additional loss in rain
end
humidity_factor = 1 + (weather.humidity - 50) / 200; % slight impact
temp_factor = 1 + (weather.temperature - 20) / 100;

c = physconst('LightSpeed');

metrics = struct();

% Calculate for each protocol
for i = 1:length(cfg.protocols)
    proto = cfg.protocols{i};
    
    % Free-space path loss
    fspl = 20*log10(4*pi*d_3d*proto.freq/c);
    
    % Frequency-dependent atmospheric absorption
    if proto.freq > 5e9
        atmos_loss = 0.1 * (d_3d/1000); % 0.1 dB/km for >5GHz
    else
        atmos_loss = 0.05 * (d_3d/1000);
    end
    
    % Log-distance shadowing
    n = 2.5 + 0.3*rand(); % path loss exponent with variation
    shadow = randn()*4;
    pl = fspl + 10*(n-2)*log10(d_3d) + shadow + atmos_loss + rain_loss_dB;
    
    % Received power
    rssi_dBm = proto.txPower_dBm + cfg.txGain_dBi + cfg.rxGain_dBi - pl;
    
    % Noise floor
    bw_Hz = proto.bandwidth_MHz * 1e6;
    noiseFloor_dBm = -174 + 10*log10(bw_Hz) + 7; % 7 dB NF
    
    % SINR (simplified, no interference modeling)
    sinr_dB = rssi_dBm - noiseFloor_dBm;
    
    % Estimate throughput (Shannon capacity with practical efficiency)
    if sinr_dB > 0
        capacity_bps = bw_Hz * log2(1 + 10^(sinr_dB/10));
        efficiency = 0.7; % practical efficiency factor
        throughput_mbps = (capacity_bps * efficiency) / 1e6;
    else
        throughput_mbps = 0;
    end
    
    % Store metrics
    metrics.(proto.name) = struct(...
        'rssi_dBm', rssi_dBm, ...
        'sinr_dB', sinr_dB, ...
        'throughput_mbps', throughput_mbps, ...
        'distance_m', d_3d, ...
        'pathloss_dB', pl ...
    );
end
end
