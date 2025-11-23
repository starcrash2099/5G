% Enhanced AeroSat Simulation with Real-World APIs and Multi-Protocol Support
clear; clc; close all;

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║   AeroSat Real-World Enhanced Simulation                  ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

% 1. Load configuration
config_realworld;
global cfg;

fprintf('Campaign: %s\n', cfg.CAMPAIGN_NAME);
fprintf('Simulation Time: %d seconds\n', cfg.simTime);
fprintf('Start Location: [%.4f, %.4f] (NYC)\n', cfg.locations.start);
fprintf('User Location: [%.4f, %.4f] (Times Square)\n', cfg.locations.user);
fprintf('Protocols: ');
for i = 1:length(cfg.protocols)
    fprintf('%s ', cfg.protocols{i}.name);
end
fprintf('\n\n');

% 2. Initialize logger
logger('init', [], cfg);

% 3. Fetch real-world weather
fprintf('--- Fetching Weather Data ---\n');
weather = get_real_weather(cfg.locations.start(1), cfg.locations.start(2), cfg);
fprintf('Source: %s\n', weather.source);
if strcmp(weather.source, 'OpenWeatherMap')
    fprintf('Conditions: %s\n', weather.description);
end
fprintf('Temperature: %.1f°C, Humidity: %.1f%%, Wind: %.1f m/s\n\n', ...
    weather.temperature, weather.humidity, weather.wind_speed);

% 4. Run simulation
fprintf('--- Running Multi-Protocol Simulation ---\n');
timeSteps = 0:cfg.dt:cfg.simTime;
numSteps = length(timeSteps);

% Storage arrays
dronePositions = zeros(numSteps, 3); % lat, lon, alt
allMetrics = cell(numSteps, 1);

% Progress bar
fprintf('Progress: ');
lastPercent = 0;

for i = 1:numSteps
    t = timeSteps(i);
    
    % Get drone position
    [lat, lon, alt] = drone_sim_realworld(t, cfg);
    dronePositions(i, :) = [lat, lon, alt];
    
    % Calculate multi-protocol metrics
    metrics = channel_model_multiprotocol(lat, lon, alt, ...
        cfg.locations.user(1), cfg.locations.user(2), weather, cfg);
    allMetrics{i} = metrics;
    
    % Log entry
    if cfg.log.enabled
        log_entry = struct(...
            'time_s', t, ...
            'drone_lat', lat, ...
            'drone_lon', lon, ...
            'drone_alt', alt, ...
            'metrics', metrics, ...
            'weather', weather ...
        );
        logger('log', log_entry, cfg);
        
        % Periodic save
        if mod(i, cfg.log.save_interval) == 0
            logger('save', [], cfg);
        end
    end
    
    % Progress indicator
    percent = floor((i/numSteps)*100);
    if percent > lastPercent && mod(percent, 10) == 0
        fprintf('%d%% ', percent);
        lastPercent = percent;
    end
end

fprintf('100%% Complete!\n\n');

% 5. Finalize logging
logger('finalize', [], cfg);

% 6. Generate comprehensive visualizations
fprintf('--- Generating Visualizations ---\n');
generate_plots(timeSteps, dronePositions, allMetrics, cfg);

fprintf('\n╔════════════════════════════════════════════════════════════╗\n');
fprintf('║   Simulation Complete!                                     ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('Results saved to:\n');
fprintf('  - logs/ (detailed logs with timestamps)\n');
fprintf('  - results/ (plots and figures)\n');
