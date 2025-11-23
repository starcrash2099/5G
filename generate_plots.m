function generate_plots(timeSteps, dronePositions, allMetrics, cfg)
% Generate comprehensive visualization plots

if ~exist('results', 'dir')
    mkdir('results');
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

% Extract protocol names
proto_names = fieldnames(allMetrics{1});
num_protocols = length(proto_names);

%% Figure 1: Map View with Drone Trajectory
fig1 = figure('Position', [50, 50, 1000, 800]);

% Plot trajectory
plot(dronePositions(:,2), dronePositions(:,1), 'b-', 'LineWidth', 2);
hold on;

% Mark start and end
plot(dronePositions(1,2), dronePositions(1,1), 'go', 'MarkerSize', 15, 'LineWidth', 3);
plot(dronePositions(end,2), dronePositions(end,1), 'rs', 'MarkerSize', 15, 'LineWidth', 3);

% Mark user location
plot(cfg.locations.user(2), cfg.locations.user(1), 'r*', 'MarkerSize', 20, 'LineWidth', 3);

xlabel('Longitude (°)');
ylabel('Latitude (°)');
title(sprintf('Drone Flight Path - %s', cfg.CAMPAIGN_NAME));
legend('Flight Path', 'Start', 'End', 'User Location', 'Location', 'best');
grid on;
axis equal;

saveas(fig1, sprintf('results/map_trajectory_%s.png', timestamp));
fprintf('  ✓ Map trajectory saved\n');

%% Figure 2: Multi-Protocol RSSI Comparison
fig2 = figure('Position', [100, 100, 1400, 600]);

for i = 1:num_protocols
    pname = proto_names{i};
    rssi_vals = cellfun(@(x) x.(pname).rssi_dBm, allMetrics);
    
    subplot(2, 2, i);
    plot(timeSteps, rssi_vals, 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('RSSI (dBm)');
    title(sprintf('%s - Signal Strength', strrep(pname, '_', ' ')));
    grid on;
    ylim([min(rssi_vals)-5, max(rssi_vals)+5]);
end

sgtitle('Multi-Protocol RSSI Over Time');
saveas(fig2, sprintf('results/rssi_comparison_%s.png', timestamp));
fprintf('  ✓ RSSI comparison saved\n');

%% Figure 3: Multi-Protocol Throughput
fig3 = figure('Position', [150, 150, 1400, 600]);

colors = lines(num_protocols);
hold on;

for i = 1:num_protocols
    pname = proto_names{i};
    tput_vals = cellfun(@(x) x.(pname).throughput_mbps, allMetrics);
    plot(timeSteps, tput_vals, 'LineWidth', 2.5, 'Color', colors(i,:), ...
        'DisplayName', strrep(pname, '_', ' '));
end

xlabel('Time (s)');
ylabel('Throughput (Mbps)');
title('Multi-Protocol Throughput Comparison');
legend('Location', 'best');
grid on;

saveas(fig3, sprintf('results/throughput_comparison_%s.png', timestamp));
fprintf('  ✓ Throughput comparison saved\n');

%% Figure 4: SINR Heatmap
fig4 = figure('Position', [200, 200, 1400, 600]);

for i = 1:num_protocols
    pname = proto_names{i};
    sinr_vals = cellfun(@(x) x.(pname).sinr_dB, allMetrics);
    
    subplot(2, 2, i);
    plot(timeSteps, sinr_vals, 'LineWidth', 2, 'Color', colors(i,:));
    xlabel('Time (s)');
    ylabel('SINR (dB)');
    title(sprintf('%s - Signal Quality', strrep(pname, '_', ' ')));
    grid on;
    yline(10, 'r--', 'Good Quality Threshold');
end

sgtitle('Signal-to-Interference-plus-Noise Ratio (SINR)');
saveas(fig4, sprintf('results/sinr_analysis_%s.png', timestamp));
fprintf('  ✓ SINR analysis saved\n');

%% Figure 5: Distance vs Performance
fig5 = figure('Position', [250, 250, 1200, 800]);

pname = proto_names{1}; % Use first protocol for distance
dist_vals = cellfun(@(x) x.(pname).distance_m, allMetrics) / 1000; % km

subplot(2,2,1);
for i = 1:num_protocols
    pname = proto_names{i};
    rssi_vals = cellfun(@(x) x.(pname).rssi_dBm, allMetrics);
    scatter(dist_vals, rssi_vals, 50, colors(i,:), 'filled', ...
        'DisplayName', strrep(pname, '_', ' '));
    hold on;
end
xlabel('Distance (km)');
ylabel('RSSI (dBm)');
title('RSSI vs Distance');
legend('Location', 'best');
grid on;

subplot(2,2,2);
for i = 1:num_protocols
    pname = proto_names{i};
    sinr_vals = cellfun(@(x) x.(pname).sinr_dB, allMetrics);
    scatter(dist_vals, sinr_vals, 50, colors(i,:), 'filled', ...
        'DisplayName', strrep(pname, '_', ' '));
    hold on;
end
xlabel('Distance (km)');
ylabel('SINR (dB)');
title('SINR vs Distance');
legend('Location', 'best');
grid on;

subplot(2,2,3);
for i = 1:num_protocols
    pname = proto_names{i};
    tput_vals = cellfun(@(x) x.(pname).throughput_mbps, allMetrics);
    scatter(dist_vals, tput_vals, 50, colors(i,:), 'filled', ...
        'DisplayName', strrep(pname, '_', ' '));
    hold on;
end
xlabel('Distance (km)');
ylabel('Throughput (Mbps)');
title('Throughput vs Distance');
legend('Location', 'best');
grid on;

subplot(2,2,4);
plot(timeSteps, dist_vals, 'k-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Distance (km)');
title('Distance Over Time');
grid on;

sgtitle('Performance vs Distance Analysis');
saveas(fig5, sprintf('results/distance_analysis_%s.png', timestamp));
fprintf('  ✓ Distance analysis saved\n');

%% Figure 6: Protocol Performance Summary
fig6 = figure('Position', [300, 300, 1000, 600]);

avg_tput = zeros(num_protocols, 1);
max_tput = zeros(num_protocols, 1);
avg_rssi = zeros(num_protocols, 1);

for i = 1:num_protocols
    pname = proto_names{i};
    tput_vals = cellfun(@(x) x.(pname).throughput_mbps, allMetrics);
    rssi_vals = cellfun(@(x) x.(pname).rssi_dBm, allMetrics);
    
    avg_tput(i) = mean(tput_vals);
    max_tput(i) = max(tput_vals);
    avg_rssi(i) = mean(rssi_vals);
end

subplot(1,2,1);
bar_data = [avg_tput, max_tput];
b = bar(bar_data);
set(gca, 'XTickLabel', strrep(proto_names, '_', ' '));
ylabel('Throughput (Mbps)');
title('Average and Peak Throughput');
legend('Average', 'Peak', 'Location', 'best');
grid on;
xtickangle(45);

subplot(1,2,2);
bar(avg_rssi);
set(gca, 'XTickLabel', strrep(proto_names, '_', ' '));
ylabel('RSSI (dBm)');
title('Average Signal Strength');
grid on;
xtickangle(45);

sgtitle('Protocol Performance Summary');
saveas(fig6, sprintf('results/protocol_summary_%s.png', timestamp));
fprintf('  ✓ Protocol summary saved\n');

close all;
end
