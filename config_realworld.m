% Enhanced config with real-world API integration
clearvars -global cfg
global cfg

cfg.CAMPAIGN_NAME = 'AeroSat-RealWorld-Enhanced';
cfg.simTime = 300; % seconds
cfg.dt = 1.0; % simulation step (s)

% Real-world locations (lat, lon)
cfg.locations.start = [40.7128, -74.0060]; % New York City
cfg.locations.user = [40.7580, -73.9855]; % Times Square
cfg.locations.radius_km = 2.0; % flight radius

% Drone motion
cfg.drone.altitude_m = 120; % meters
cfg.drone.speed_mps = 15; % meters per second

% Multi-protocol wireless configs
cfg.protocols = {
    struct('name', 'WiFi_24GHz', 'freq', 2.4e9, 'txPower_dBm', 20, 'bandwidth_MHz', 20),
    struct('name', 'WiFi_5GHz', 'freq', 5.8e9, 'txPower_dBm', 23, 'bandwidth_MHz', 40),
    struct('name', 'LTE_Band7', 'freq', 2.6e9, 'txPower_dBm', 23, 'bandwidth_MHz', 10),
    struct('name', 'NR_5G', 'freq', 3.5e9, 'txPower_dBm', 24, 'bandwidth_MHz', 100)
};

cfg.txGain_dBi = 2;
cfg.rxGain_dBi = 0;

% Satellite configs (Starlink-like)
cfg.sat.latency_ms = 25; % Starlink average
cfg.sat.jitter_ms = 5;
cfg.sat.loss_prob = 0.001;

% API Keys
cfg.api.openweather_key = 'f29715466a768e294bd339b3c49641b1';
cfg.api.use_real_weather = true; % Using real weather data

% Traffic patterns
cfg.traffic.rate_normal_kbps = 500;
cfg.traffic.rate_emergency_kbps = 64;
cfg.traffic.rate_video_kbps = 2500;

% Logging
cfg.log.enabled = true;
cfg.log.detailed = true;
cfg.log.save_interval = 10; % save every 10 steps

% Visualization
cfg.visualizeEvery = 5;
cfg.saveFigures = true;

rng('shuffle'); % Use current time for randomness
