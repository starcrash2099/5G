%% ========================================================================
% AI-ENABLED DRONE-BASED EMERGENCY COMMUNICATION GATEWAY
% ========================================================================
% 
% DESCRIPTION:
%   Complete emergency communication system that simulates a drone acting
%   as a flying relay station during disasters. Uses AI to intelligently
%   select the best wireless protocol (WiFi, LTE, 5G, Satellite) based on
%   real-time conditions.
%
% FEATURES:
%   - Virtual drone simulation with GPS coordinates
%   - Real-world data integration (weather, satellites, disasters)
%   - AI-based protocol selection using machine learning
%   - Emergency traffic prioritization with QoS
%   - Multi-protocol support (5 protocols)
%   - Adaptive handoff between protocols
%   - Comprehensive logging and visualization
%
% USAGE:
%   Simply run: main_emergency
%
% OUTPUT:
%   - Logs saved to logs/ directory (MAT + TXT)
%   - Visualizations saved to results/ directory (PNG)
%
% REQUIREMENTS:
%   - MATLAB R2019b or later
%   - Statistics and Machine Learning Toolbox
%   - Internet connection (for API calls)
%
% AUTHOR: PRIYAM GANGULI
% DATE: November 23, 2025
% VERSION: 1.0
% ========================================================================

clear; clc; close all;

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  AI Emergency Communication Gateway Simulation             ║\n');
fprintf('║  Drone + Multi-Protocol + Satellite + Real-World Data      ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

%% ========================================================================
% STEP 1: LOAD CONFIGURATION
% ========================================================================
% Load emergency gateway configuration including:
% - Location settings (Delhi, India by default)
% - Drone parameters (altitude, speed, radius)
% - Protocol definitions (WiFi, LTE, 5G, Satellite)
% - AI routing settings
% - Emergency mode parameters
config_emergency;
global cfg;

fprintf('Campaign: %s\n', cfg.CAMPAIGN_NAME);
fprintf('Location: [%.4f, %.4f] (%s)\n', cfg.locations.start, 'Delhi, India');
fprintf('Simulation Time: %d seconds\n', cfg.simTime);
fprintf('Protocols: ');
for i = 1:length(cfg.protocols)
    fprintf('%s ', cfg.protocols{i}.name);
end
fprintf('\n\n');

%% ========================================================================
% STEP 2: INITIALIZE LOGGER
% ========================================================================
% Set up comprehensive logging system that will save:
% - Timestamped simulation data (MAT format)
% - Human-readable summary (TXT format)
% - Performance metrics and statistics
logger('init', [], cfg);

%% ========================================================================
% STEP 3: FETCH REAL-WORLD DATA (NO API KEYS REQUIRED)
% ========================================================================
% Integrate live data from public APIs to make simulation realistic:
% - Weather: Temperature, humidity, wind (affects signal propagation)
% - Emergency Events: Earthquakes, fires, storms (triggers emergency mode)
% - Satellite: Orbital visibility (determines satellite link availability)
fprintf('--- Fetching Real-World Data ---\n');

% Weather data from Open-Meteo API
% Used to calculate signal attenuation due to rain, humidity, etc.
weather = get_real_weather(cfg.locations.start(1), cfg.locations.start(2), cfg);
fprintf('Weather: %.1f°C, %d%% humidity, %.1fm/s wind (Source: %s)\n', ...
    weather.temperature, weather.humidity, weather.wind_speed, weather.source);

% Emergency events from USGS (earthquakes) and NASA EONET (fires, storms)
% Searches within configured radius (default 100km)
events = get_emergency_events(cfg.locations.start(1), cfg.locations.start(2), ...
    cfg.emergency.search_radius_km);
fprintf('Emergency Events: %d total (%d earthquakes, %d fires, %d storms)\n', ...
    events.total_count, length(events.earthquakes), length(events.fires), length(events.storms));

% Satellite visibility from Celestrak TLE data
% Determines if satellite backhaul is available at this location/time
sat_data = get_satellite_visibility(cfg.locations.start(1), cfg.locations.start(2), cfg.drone.altitude_m);
fprintf('Satellite: %s (Visible: %d)\n\n', sat_data.source, sat_data.visible);

% Auto-enable emergency mode if disasters detected nearby
if cfg.emergency.auto_detect && events.has_emergency
    cfg.emergency.enabled = true;
    fprintf('⚠️  EMERGENCY MODE ACTIVATED (Events detected)\n\n');
end

%% ========================================================================
% STEP 4: LOAD AI PREDICTOR MODEL
% ========================================================================
% Load pre-trained machine learning model for intelligent protocol selection
% Model: Ensemble regression (bagged trees) trained on 10,000+ scenarios
% Input: [distance, RSSI, SINR, weather_impact, congestion]
% Output: Predicted throughput for each protocol
% Fallback: Uses heuristic scoring if model not available
predictor_model = [];
if cfg.ai.enabled && exist(cfg.ai.model_path, 'file')
    load(cfg.ai.model_path, 'model');
    predictor_model = model;
    fprintf('✓ AI Predictor loaded\n');
else
    fprintf('⚠️  AI Predictor not found, using heuristics\n');
end

%% ========================================================================
% STEP 5: INITIALIZE SIMULATION
% ========================================================================
% Set up simulation loop and data structures
fprintf('\n--- Running Emergency Gateway Simulation ---\n');

% Time vector: 0 to simTime with dt step size (default: 0 to 600s, 1s steps)
timeSteps = 0:cfg.dt:cfg.simTime;
numSteps = length(timeSteps);

% Storage arrays for simulation data
dronePositions = zeros(numSteps, 3);      % [lat, lon, altitude] at each timestep
allMetrics = cell(numSteps, 1);           % Channel metrics for all protocols
routingDecisions = cell(numSteps, 1);     % AI routing decisions
trafficStats = struct();                   % Traffic statistics

% Performance tracking structure
performance = struct();
performance.total_packets = 0;             % Total packets generated
performance.delivered_packets = 0;         % Successfully delivered packets
performance.emergency_packets = 0;         % Emergency priority packets
performance.emergency_delivered = 0;       % Emergency packets delivered
performance.handoff_count = 0;             % Number of protocol switches
performance.latencies = [];                % Latency for all packets (ms)
performance.emergency_latencies = [];      % Latency for emergency packets (ms)

% Start with first protocol (typically WiFi 2.4GHz)
current_protocol = cfg.protocols{1}.name;

% Progress bar for user feedback
fprintf('Progress: ');
lastPercent = 0;

for i = 1:numSteps
    t = timeSteps(i);
    
    % Get drone position
    [lat, lon, alt] = drone_sim_realworld(t, cfg);
    dronePositions(i, :) = [lat, lon, alt];
    
    % Calculate metrics for all protocols using the channel model
    channel_metrics = channel_model_multiprotocol(lat, lon, alt, ...
        cfg.locations.user(1), cfg.locations.user(2), weather, cfg);
    
    % Process metrics for each protocol
    metrics = struct();
    for p = 1:length(cfg.protocols)
        prot = cfg.protocols{p};
        
        % Get channel metrics from the model
        ch_met = channel_metrics.(prot.name);
        
        % Calculate distance to user
        dist_km = ch_met.distance_m / 1000;
        
        % Extract metrics
        rssi = ch_met.rssi_dBm;
        sinr = ch_met.sinr_dB;
        throughput = ch_met.throughput_mbps;
        
        % Apply satellite-specific adjustments
        if strcmp(prot.type, 'satellite')
            if sat_data.visible
                % Boost for satellite when visible
                rssi = rssi + 10;
                sinr = sinr + 5;
            else
                % Satellite not visible
                rssi = -140;
                sinr = -30;
                throughput = 0;
            end
        else
            % Simulate network outages in emergency zones for terrestrial
            if cfg.emergency.enabled && rand() < cfg.network.outage_probability
                rssi = rssi - 20; % Degraded signal
                throughput = throughput * 0.3;
            end
        end
        
        % Store metrics
        metrics.(prot.name) = struct(...
            'distance_km', dist_km, ...
            'rssi', rssi, ...
            'sinr', sinr, ...
            'throughput', throughput, ...
            'weather_impact', (weather.humidity/100 + weather.wind_speed/20)/2, ...
            'congestion', rand() * cfg.network.congestion_probability);
    end
    
    % Generate traffic packets
    if mod(i, round(1/cfg.traffic.packet_rate_hz)) == 0
        num_packets = randi([1, 5]);
        traffic_queue = [];
        
        for pkt_idx = 1:num_packets
            packet = struct();
            packet.id = performance.total_packets + pkt_idx;
            packet.timestamp = t;
            
            % Random traffic type
            types = {'emergency_voice', 'emergency_data', 'video', 'telemetry'};
            packet.type = types{randi(length(types))};
            
            % Size based on type
            switch packet.type
                case 'emergency_voice'
                    packet.size_bytes = 160 + randi(100);
                case 'emergency_data'
                    packet.size_bytes = 1000 + randi(2000);
                case 'video'
                    packet.size_bytes = 10000 + randi(20000);
                case 'telemetry'
                    packet.size_bytes = 64 + randi(128);
            end
            
            traffic_queue = [traffic_queue; packet];
        end
        
        % Prioritize traffic
        [prioritized_queue, traffic_stats] = emergency_traffic_handler(traffic_queue, cfg.emergency.enabled);
        
        performance.total_packets = performance.total_packets + length(prioritized_queue);
        performance.emergency_packets = performance.emergency_packets + traffic_stats.emergency_count;
    end
    
    % AI Routing decision
    metrics.current_protocol = current_protocol;
    decision = ai_routing_engine(metrics, 'emergency_data', cfg.emergency.enabled, predictor_model);
    routingDecisions{i} = decision;
    
    % Adaptive handoff
    if cfg.ai.adaptive_handoff && decision.handoff_recommended
        current_protocol = decision.selected_protocol;
        performance.handoff_count = performance.handoff_count + 1;
    end
    
    % Simulate packet delivery
    selected_metrics = metrics.(decision.selected_protocol);
    if selected_metrics.throughput > 0.1 % Minimum viable throughput
        delivery_prob = min(0.99, selected_metrics.throughput / 10);
        if rand() < delivery_prob
            performance.delivered_packets = performance.delivered_packets + 1;
            
            % Calculate latency
            if strcmp(cfg.protocols{find(strcmp({cfg.protocols.name}, decision.selected_protocol))}.type, 'satellite')
                latency_ms = cfg.sat.latency_ms + randn()*cfg.sat.jitter_ms;
            else
                latency_ms = 10 + selected_metrics.distance_km * 2 + randn()*5;
            end
            performance.latencies = [performance.latencies; latency_ms];
            
            if cfg.emergency.enabled
                performance.emergency_delivered = performance.emergency_delivered + 1;
                performance.emergency_latencies = [performance.emergency_latencies; latency_ms];
            end
        end
    end
    
    % Store metrics
    allMetrics{i} = metrics;
    
    % Log
    if mod(i, cfg.log.save_interval) == 0
        log_entry = struct('time', t, 'drone', [lat, lon, alt], ...
            'protocol', decision.selected_protocol, 'metrics', selected_metrics);
        logger('log', log_entry, cfg);
    end
    
    % Progress
    percent = floor(100 * i / numSteps);
    if percent >= lastPercent + 10
        fprintf('%d%% ', percent);
        lastPercent = percent;
    end
end

fprintf('100%% Complete!\n\n');

% 6. Finalize and save
logger('finalize', [], cfg);

% 7. Calculate final performance metrics
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Performance Metrics                                       ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('Total Packets: %d\n', performance.total_packets);
fprintf('Delivered: %d (%.1f%%)\n', performance.delivered_packets, ...
    100*performance.delivered_packets/max(1,performance.total_packets));
fprintf('Emergency Packets: %d\n', performance.emergency_packets);
fprintf('Emergency Delivered: %d (%.1f%%)\n', performance.emergency_delivered, ...
    100*performance.emergency_delivered/max(1,performance.emergency_packets));
fprintf('Protocol Handoffs: %d\n', performance.handoff_count);

if ~isempty(performance.latencies)
    fprintf('Avg Latency: %.1f ms (median: %.1f ms)\n', ...
        mean(performance.latencies), median(performance.latencies));
end

if ~isempty(performance.emergency_latencies)
    fprintf('Emergency Latency: %.1f ms (median: %.1f ms)\n', ...
        mean(performance.emergency_latencies), median(performance.emergency_latencies));
    within_threshold = sum(performance.emergency_latencies <= cfg.metrics.emergency_threshold_ms);
    fprintf('Within %d ms threshold: %d/%d (%.1f%%)\n', ...
        cfg.metrics.emergency_threshold_ms, within_threshold, ...
        length(performance.emergency_latencies), ...
        100*within_threshold/length(performance.emergency_latencies));
end

% 8. Generate visualizations
fprintf('\n--- Generating Visualizations ---\n');
generate_emergency_plots(dronePositions, allMetrics, routingDecisions, performance, events, cfg);

fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Emergency Gateway Simulation Complete!                   ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('Results saved to logs/ and results/\n');

function dist = haversine_distance(lat1, lon1, lat2, lon2)
R = 6371;
dlat = deg2rad(lat2 - lat1);
dlon = deg2rad(lon2 - lon1);
a = sin(dlat/2)^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
dist = R * c;
end
