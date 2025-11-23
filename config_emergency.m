% Emergency Communication Gateway Configuration
clearvars -global cfg
global cfg

cfg.CAMPAIGN_NAME = 'AI-Emergency-Gateway';
cfg.simTime = 600; % 10 minutes
cfg.dt = 1.0; % simulation step (s)

% Real-world locations (lat, lon)
cfg.locations.start = [28.6139, 77.2090]; % New Delhi (disaster-prone region)
cfg.locations.user = [28.7041, 77.1025]; % Delhi NCR
cfg.locations.radius_km = 5.0; % larger flight radius for emergency coverage

% Drone motion
cfg.drone.altitude_m = 150; % higher for better coverage
cfg.drone.speed_mps = 20; % faster response

% Multi-protocol wireless configs (including satellite)
cfg.protocols = {
    struct('name', 'WiFi_24GHz', 'freq', 2.4e9, 'txPower_dBm', 20, 'bandwidth_MHz', 20, 'type', 'terrestrial'),
    struct('name', 'WiFi_5GHz', 'freq', 5.8e9, 'txPower_dBm', 23, 'bandwidth_MHz', 40, 'type', 'terrestrial'),
    struct('name', 'LTE_Band7', 'freq', 2.6e9, 'txPower_dBm', 23, 'bandwidth_MHz', 10, 'type', 'terrestrial'),
    struct('name', 'NR_5G', 'freq', 3.5e9, 'txPower_dBm', 24, 'bandwidth_MHz', 100, 'type', 'terrestrial'),
    struct('name', 'Satellite', 'freq', 12e9, 'txPower_dBm', 30, 'bandwidth_MHz', 250, 'type', 'satellite')
};

cfg.txGain_dBi = 3;
cfg.rxGain_dBi = 2;

% Satellite configs (Starlink-like)
cfg.sat.enabled = true;
cfg.sat.latency_ms = 25;
cfg.sat.jitter_ms = 5;
cfg.sat.loss_prob = 0.001;
cfg.sat.check_visibility = true;

% Emergency mode settings
cfg.emergency.enabled = true;
cfg.emergency.auto_detect = true; % Auto-detect from event APIs
cfg.emergency.search_radius_km = 100; % Search for events within 100km
cfg.emergency.priority_boost = 1.5; % Boost emergency traffic priority

% Traffic patterns (emergency scenarios)
cfg.traffic.emergency_voice_kbps = 64; % VoIP
cfg.traffic.emergency_data_kbps = 128; % Text, images
cfg.traffic.video_kbps = 2500; % Compressed video
cfg.traffic.telemetry_kbps = 32; % Sensor data
cfg.traffic.packet_rate_hz = 10; % 10 packets/sec

% AI Routing settings
cfg.ai.enabled = true;
cfg.ai.model_path = 'models/predictor_model.mat';
cfg.ai.adaptive_handoff = true;
cfg.ai.handoff_threshold = 0.3; % 30% improvement triggers handoff

% Network condition simulation
cfg.network.simulate_congestion = true;
cfg.network.congestion_probability = 0.2; % 20% chance of congestion
cfg.network.outage_probability = 0.05; % 5% chance of tower outage in emergency

% API settings (no keys needed)
cfg.api.use_real_weather = true;
cfg.api.use_real_events = true;
cfg.api.use_satellite_tle = true;

% Logging
cfg.log.enabled = true;
cfg.log.detailed = true;
cfg.log.save_interval = 10;

% Visualization
cfg.visualizeEvery = 10;
cfg.saveFigures = true;

% Performance metrics
cfg.metrics.track_latency = true;
cfg.metrics.track_delivery_ratio = true;
cfg.metrics.track_handoffs = true;
cfg.metrics.emergency_threshold_ms = 500; % Emergency packets must arrive within 500ms

rng('shuffle');
