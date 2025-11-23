function generate_emergency_plots(dronePositions, allMetrics, routingDecisions, performance, events, cfg)
% Generate comprehensive visualizations for emergency gateway simulation

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

%% 1. Emergency Map with Drone Trajectory and Events
figure('Position', [100, 100, 1200, 800]);

% Plot drone trajectory
plot(dronePositions(:,2), dronePositions(:,1), 'b-', 'LineWidth', 2);
hold on;

% Plot start and user locations
plot(cfg.locations.start(2), cfg.locations.start(1), 'go', 'MarkerSize', 15, 'LineWidth', 3);
plot(cfg.locations.user(2), cfg.locations.user(1), 'rs', 'MarkerSize', 15, 'LineWidth', 3);

% Plot emergency events
if ~isempty(events.earthquakes)
    for i = 1:length(events.earthquakes)
        eq = events.earthquakes(i);
        plot(eq.lon, eq.lat, 'r^', 'MarkerSize', 10 + eq.magnitude*2, 'LineWidth', 2);
    end
end

if ~isempty(events.fires)
    for i = 1:length(events.fires)
        fire = events.fires(i);
        plot(fire.lon, fire.lat, 'ro', 'MarkerSize', 12, 'LineWidth', 2);
    end
end

xlabel('Longitude');
ylabel('Latitude');
title('Emergency Communication Gateway - Drone Trajectory & Events');
legend('Drone Path', 'Start', 'User/Ground Station', 'Earthquake', 'Fire', 'Location', 'best');
grid on;

if cfg.saveFigures
    saveas(gcf, sprintf('results/emergency_map_%s.png', timestamp));
    fprintf('✓ Emergency map saved\n');
end

%% 2. Protocol Selection Over Time
figure('Position', [100, 100, 1200, 600]);

protocol_names = cellfun(@(p) p.name, cfg.protocols, 'UniformOutput', false);
protocol_usage = zeros(length(protocol_names), 1);
time_vec = [];
protocol_vec = [];

for i = 1:length(routingDecisions)
    if ~isempty(routingDecisions{i})
        time_vec = [time_vec; (i-1)*cfg.dt];
        selected = routingDecisions{i}.selected_protocol;
        idx = find(strcmp(protocol_names, selected));
        protocol_vec = [protocol_vec; idx];
        protocol_usage(idx) = protocol_usage(idx) + 1;
    end
end

subplot(2,1,1);
plot(time_vec, protocol_vec, 'o-', 'LineWidth', 1.5);
yticks(1:length(protocol_names));
yticklabels(protocol_names);
xlabel('Time (s)');
ylabel('Selected Protocol');
title('AI Routing: Protocol Selection Over Time');
grid on;

subplot(2,1,2);
bar(protocol_usage);
xticklabels(protocol_names);
ylabel('Usage Count');
title('Protocol Usage Distribution');
grid on;

if cfg.saveFigures
    saveas(gcf, sprintf('results/protocol_selection_%s.png', timestamp));
    fprintf('✓ Protocol selection saved\n');
end

%% 3. Performance Metrics Dashboard
figure('Position', [100, 100, 1400, 900]);

% Delivery ratio
subplot(2,3,1);
delivery_ratio = 100 * performance.delivered_packets / max(1, performance.total_packets);
emergency_ratio = 100 * performance.emergency_delivered / max(1, performance.emergency_packets);
bar([delivery_ratio, emergency_ratio]);
xticklabels({'All Traffic', 'Emergency'});
ylabel('Delivery Ratio (%)');
title('Packet Delivery Success Rate');
ylim([0, 100]);
grid on;

% Latency distribution
subplot(2,3,2);
if ~isempty(performance.latencies)
    histogram(performance.latencies, 30, 'FaceColor', 'b', 'FaceAlpha', 0.6);
    hold on;
    if ~isempty(performance.emergency_latencies)
        histogram(performance.emergency_latencies, 30, 'FaceColor', 'r', 'FaceAlpha', 0.6);
    end
    xlabel('Latency (ms)');
    ylabel('Count');
    title('Latency Distribution');
    legend('All', 'Emergency');
    grid on;
end

% Handoff count
subplot(2,3,3);
bar(performance.handoff_count);
ylabel('Count');
title(sprintf('Protocol Handoffs: %d', performance.handoff_count));
grid on;

% Throughput over time
subplot(2,3,4);
throughput_time = [];
throughput_vals = [];
for i = 1:length(allMetrics)
    if ~isempty(allMetrics{i}) && ~isempty(routingDecisions{i})
        selected = routingDecisions{i}.selected_protocol;
        if isfield(allMetrics{i}, selected)
            throughput_time = [throughput_time; (i-1)*cfg.dt];
            throughput_vals = [throughput_vals; allMetrics{i}.(selected).throughput];
        end
    end
end
if ~isempty(throughput_time)
    plot(throughput_time, throughput_vals, 'LineWidth', 2);
    xlabel('Time (s)');
    ylabel('Throughput (Mbps)');
    title('Selected Protocol Throughput');
    grid on;
end

% RSSI comparison
subplot(2,3,5);
if ~isempty(allMetrics{end})
    rssi_vals = [];
    rssi_labels = {};
    for p = 1:length(protocol_names)
        prot = protocol_names{p};
        if isfield(allMetrics{end}, prot)
            rssi_vals = [rssi_vals; allMetrics{end}.(prot).rssi];
            rssi_labels{end+1} = prot;
        end
    end
    bar(rssi_vals);
    xticklabels(rssi_labels);
    ylabel('RSSI (dBm)');
    title('Final RSSI by Protocol');
    grid on;
end

% Emergency metrics
subplot(2,3,6);
if ~isempty(performance.emergency_latencies)
    within_threshold = sum(performance.emergency_latencies <= cfg.metrics.emergency_threshold_ms);
    pie([within_threshold, length(performance.emergency_latencies) - within_threshold]);
    title(sprintf('Emergency Packets Within %dms', cfg.metrics.emergency_threshold_ms));
    legend(sprintf('Within (%.1f%%)', 100*within_threshold/length(performance.emergency_latencies)), ...
           sprintf('Exceeded (%.1f%%)', 100*(1-within_threshold/length(performance.emergency_latencies))));
end

sgtitle('Emergency Gateway Performance Dashboard');

if cfg.saveFigures
    saveas(gcf, sprintf('results/performance_dashboard_%s.png', timestamp));
    fprintf('✓ Performance dashboard saved\n');
end

%% 4. AI Routing Scores
figure('Position', [100, 100, 1200, 600]);

score_matrix = [];
for i = 1:min(100, length(routingDecisions)) % Sample first 100 decisions
    if ~isempty(routingDecisions{i}) && isfield(routingDecisions{i}, 'all_scores')
        score_matrix = [score_matrix; routingDecisions{i}.all_scores'];
    end
end

if ~isempty(score_matrix)
    imagesc(score_matrix');
    colorbar;
    yticks(1:length(protocol_names));
    yticklabels(protocol_names);
    xlabel('Time Step');
    ylabel('Protocol');
    title('AI Routing Scores Heatmap (Higher = Better)');
end

if cfg.saveFigures
    saveas(gcf, sprintf('results/ai_routing_scores_%s.png', timestamp));
    fprintf('✓ AI routing scores saved\n');
end

end
