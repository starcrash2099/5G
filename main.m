% AeroSat MATLAB Project - Main Simulation Script
clear; clc; close all;

% 1. Load configuration
config;
global cfg;

fprintf('=== AeroSat Simulation Started ===\n');
fprintf('Campaign: %s\n', cfg.CAMPAIGN_NAME);
fprintf('Simulation Time: %d seconds\n', cfg.simTime);

% 2. Train predictor model (optional - run once)
fprintf('\n--- Training Predictor Model ---\n');
model = predictor_train(cfg);

% 3. Run simulation
fprintf('\n--- Running Simulation ---\n');
timeSteps = 0:cfg.dt:cfg.simTime;
numSteps = length(timeSteps);

% Fixed user position
userPos = [0.5, 0.3]; % km

% Storage for results
dronePositions = zeros(numSteps, 2);
rssiValues = zeros(numSteps, 1);
sinrValues = zeros(numSteps, 1);

% Simulate
for i = 1:numSteps
    t = timeSteps(i);
    
    % Get drone position
    dronePos = drone_sim(t, cfg);
    dronePositions(i, :) = dronePos;
    
    % Calculate channel metrics
    [rssi, sinr] = channel_model(dronePos, userPos, cfg);
    rssiValues(i) = rssi;
    sinrValues(i) = sinr;
    
    % Progress indicator
    if mod(i, 100) == 0
        fprintf('Progress: %.1f%%\n', (i/numSteps)*100);
    end
end

fprintf('Simulation Complete!\n');

% 4. Visualize results
fprintf('\n--- Generating Plots ---\n');

figure('Position', [100, 100, 1200, 400]);

% Plot 1: Drone trajectory
subplot(1,3,1);
plot(dronePositions(:,1), dronePositions(:,2), 'b-', 'LineWidth', 1.5);
hold on;
plot(userPos(1), userPos(2), 'r*', 'MarkerSize', 15, 'LineWidth', 2);
plot(dronePositions(1,1), dronePositions(1,2), 'go', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('X Position (km)');
ylabel('Y Position (km)');
title('Drone Trajectory');
legend('Drone Path', 'User', 'Start', 'Location', 'best');
grid on;
axis equal;

% Plot 2: RSSI over time
subplot(1,3,2);
plot(timeSteps, rssiValues, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('RSSI (dBm)');
title('Received Signal Strength');
grid on;

% Plot 3: SINR over time
subplot(1,3,3);
plot(timeSteps, sinrValues, 'g-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('SINR (dB)');
title('Signal-to-Interference-plus-Noise Ratio');
grid on;

% Save figure if configured
if cfg.saveFigures
    if ~exist('results', 'dir'), mkdir('results'); end
    saveas(gcf, 'results/simulation_results.png');
    fprintf('Figure saved to results/simulation_results.png\n');
end

% 5. Test satellite emulator
fprintf('\n--- Testing Satellite Emulator ---\n');
txTime = 10; % seconds
[deliverTime, dropped] = sat_emulator(txTime, cfg);
fprintf('Packet sent at t=%.2fs\n', txTime);
if dropped
    fprintf('Packet DROPPED!\n');
else
    fprintf('Packet delivered at t=%.2fs (latency: %.2fms)\n', ...
        deliverTime, (deliverTime-txTime)*1000);
end

fprintf('\n=== Simulation Complete ===\n');
