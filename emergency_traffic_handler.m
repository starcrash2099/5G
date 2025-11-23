function [prioritized_queue, stats] = emergency_traffic_handler(traffic_queue, emergency_mode)
%% ========================================================================
% EMERGENCY_TRAFFIC_HANDLER - QoS and Traffic Prioritization
% ========================================================================
%
% DESCRIPTION:
%   Implements Quality of Service (QoS) for emergency communications.
%   Classifies traffic by type and assigns priority levels to ensure
%   critical emergency packets are delivered first.
%
% INPUTS:
%   traffic_queue    - Array of packet structs with fields:
%                      .id: Packet identifier
%                      .timestamp: Creation time
%                      .type: Traffic type (optional, will classify if missing)
%                      .size_bytes: Packet size
%                      .port: Network port (optional, for classification)
%   emergency_mode   - Boolean: true if emergency mode active
%
% OUTPUTS:
%   prioritized_queue - Sorted array of packets (highest priority first)
%   stats            - Struct with statistics:
%                      .total_packets: Total packets processed
%                      .emergency_count: Number of emergency packets
%                      .dropped_count: Packets dropped due to queue limit
%                      .voice_count, .data_count, etc.: Per-type counts
%
% PRIORITY LEVELS (1 = highest, 5 = lowest):
%   1. Emergency Voice (VoIP) - Real-time, <500ms latency required
%   2. Emergency Data (text, images) - High priority, <1s latency
%   3. Video - Can buffer, needs high throughput
%   4. Telemetry - Sensor data, needs reliability
%   5. Normal - Best effort
%
% QoS POLICIES:
%   - Queue limit: 1000 packets (drops lowest priority if exceeded)
%   - Video compression: 60% size reduction in emergency mode
%   - Emergency packets marked for special handling
%
% EXAMPLE:
%   [queue, stats] = emergency_traffic_handler(packets, true);
%   fprintf('Emergency packets: %d\n', stats.emergency_count);
%
% AUTHOR: PRIYAM GANGULI
% DATE: November 23, 2025
% ========================================================================

stats = struct();
stats.total_packets = length(traffic_queue);
stats.emergency_count = 0;
stats.dropped_count = 0;

if isempty(traffic_queue)
    prioritized_queue = [];
    return;
end

% Priority levels (lower = higher priority)
PRIORITY = struct(...
    'emergency_voice', 1, ...
    'emergency_data', 2, ...
    'video', 3, ...
    'telemetry', 4, ...
    'normal', 5);

% Assign priority to each packet
for i = 1:length(traffic_queue)
    pkt = traffic_queue(i);
    
    % Classify traffic type if not already classified
    if ~isfield(pkt, 'type')
        pkt.type = classify_traffic(pkt);
    end
    
    % Assign priority
    if isfield(PRIORITY, pkt.type)
        pkt.priority = PRIORITY.(pkt.type);
    else
        pkt.priority = PRIORITY.normal;
    end
    
    % Mark emergency packets
    if emergency_mode && (pkt.priority <= 2)
        pkt.is_emergency = true;
        stats.emergency_count = stats.emergency_count + 1;
    else
        pkt.is_emergency = false;
    end
    
    traffic_queue(i) = pkt;
end

% Sort by priority (ascending)
[~, sort_idx] = sort([traffic_queue.priority]);
prioritized_queue = traffic_queue(sort_idx);

% Apply QoS policies
MAX_QUEUE_SIZE = 1000;
if length(prioritized_queue) > MAX_QUEUE_SIZE
    % Drop lowest priority packets
    prioritized_queue = prioritized_queue(1:MAX_QUEUE_SIZE);
    stats.dropped_count = length(traffic_queue) - MAX_QUEUE_SIZE;
end

% Compression for video in emergency mode
if emergency_mode
    for i = 1:length(prioritized_queue)
        if strcmp(prioritized_queue(i).type, 'video')
            % Simulate compression (reduce size by 60%)
            prioritized_queue(i).size_bytes = prioritized_queue(i).size_bytes * 0.4;
            prioritized_queue(i).compressed = true;
        end
    end
end

stats.voice_count = sum(strcmp({prioritized_queue.type}, 'emergency_voice'));
stats.data_count = sum(strcmp({prioritized_queue.type}, 'emergency_data'));
stats.video_count = sum(strcmp({prioritized_queue.type}, 'video'));
stats.telemetry_count = sum(strcmp({prioritized_queue.type}, 'telemetry'));

end

function type = classify_traffic(packet)
% Simple traffic classifier based on packet characteristics

if isfield(packet, 'port')
    % Port-based classification
    if packet.port == 5060 || packet.port == 5061 % SIP
        type = 'emergency_voice';
    elseif packet.port == 80 || packet.port == 443 % HTTP/HTTPS
        if packet.size_bytes > 10000
            type = 'video';
        else
            type = 'emergency_data';
        end
    elseif packet.port == 1883 || packet.port == 8883 % MQTT
        type = 'telemetry';
    else
        type = 'normal';
    end
elseif isfield(packet, 'size_bytes')
    % Size-based heuristic
    if packet.size_bytes < 500
        type = 'telemetry';
    elseif packet.size_bytes < 5000
        type = 'emergency_data';
    else
        type = 'video';
    end
else
    type = 'normal';
end
end
