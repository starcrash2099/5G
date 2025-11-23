% Central config for AeroSat MATLAB Project
clearvars -global cfg
global cfg

cfg.CAMPAIGN_NAME = 'AeroSat-CCN-MATLAB';
cfg.simTime = 240; % seconds
cfg.dt = 0.5; % simulation step (s)

% Drone motion
cfg.drone.initPos = [0,0]; % x,y (km)
cfg.drone.speed = 0.02; % km/s

% Wireless
cfg.freq = 2.4e9; % Hz
cfg.txPower_dBm = 20; % dBm
cfg.txGain_dBi = 2;
cfg.rxGain_dBi = 0;

% Satellite emulation
cfg.sat.latency_ms = 600; % mean one-way latency
cfg.sat.jitter_ms = 120;
cfg.sat.loss_prob = 0.02; % packet loss probability

% Traffic
cfg.traffic.rate_normal_kbps = 100; % kbps normal traffic
cfg.traffic.rate_emergency_kbps = 8; % kbps emergency

% Predictor thresholds
cfg.thr.compress_mbps = 1.5; % Mbps threshold to decide compression
cfg.thr.highprio_mbps = 0.5; % below this Mbps => high priority

% Visualization / logging
cfg.visualizeEvery = 2; % seconds
cfg.saveFigures = true;

rng(42);
