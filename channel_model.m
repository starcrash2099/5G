function [rssi_dBm, sinr_dB] = channel_model(dronePos, userPos, cfg)
% dronePos, userPos: [x,y] km
d = norm((dronePos - userPos))*1000;
if d<1, d=1; end

c = physconst('LightSpeed');
f = cfg.freq;

% Free-space path loss (FSPL)
fspl = 20*log10(4*pi*d*f/c);

% Log-distance and shadowing
n = 2.7; % path loss exponent
shadow = randn()*4; % dB
pl = fspl + 10*(n-2)*log10(d) + shadow;

% Received power
rssi_dBm = cfg.txPower_dBm + cfg.txGain_dBi + cfg.rxGain_dBi - pl;

% Noise floor for 1MHz BW (dBm)
bw_Hz = 1e6;
noiseFloor_dBm = -174 + 10*log10(bw_Hz) + 7; % 7 dB NF
sinr_dB = rssi_dBm - noiseFloor_dBm;
end
