function decision = ai_routing_engine(metrics, traffic_type, emergency_mode, predictor_model)
%% ========================================================================
% AI_ROUTING_ENGINE - Intelligent Protocol Selection Using Machine Learning
% ========================================================================
%
% DESCRIPTION:
%   Core AI routing engine that selects the optimal wireless protocol based
%   on real-time conditions, traffic type, and emergency status. Uses machine
%   learning to predict throughput and applies traffic-aware scoring.
%
% INPUTS:
%   metrics          - Struct containing metrics for each protocol:
%                      .distance_km: Distance to user (km)
%                      .rssi: Received Signal Strength Indicator (dBm)
%                      .sinr: Signal-to-Interference-plus-Noise Ratio (dB)
%                      .weather_impact: Weather attenuation factor (0-1)
%                      .congestion: Network congestion level (0-1)
%   traffic_type     - String: 'emergency_voice', 'emergency_data', 
%                      'video', 'telemetry', or 'normal'
%   emergency_mode   - Boolean: true if emergency mode active
%   predictor_model  - Pre-trained ML model (ensemble regression) or []
%
% OUTPUT:
%   decision         - Struct containing:
%                      .selected_protocol: Name of best protocol
%                      .score: Confidence score (0-1)
%                      .predicted_throughput_mbps: Expected throughput
%                      .handoff_recommended: Boolean for protocol switch
%                      .handoff_reason: Explanation if handoff needed
%
% ALGORITHM:
%   1. Extract features for each protocol [distance, RSSI, SINR, weather, congestion]
%   2. Predict throughput using ML model (or heuristic fallback)
%   3. Apply traffic-type specific scoring weights:
%      - Voice: Prioritize low latency + reliability
%      - Data: Balance throughput + reliability
%      - Video: Maximize throughput
%      - Telemetry: Maximize reliability
%   4. Boost satellite score by 50% in emergency mode
%   5. Select protocol with highest score
%   6. Check if handoff needed (>30% improvement threshold)
%
% EXAMPLE:
%   decision = ai_routing_engine(metrics, 'emergency_voice', true, model);
%   fprintf('Selected: %s\n', decision.selected_protocol);
%
% AUTHOR: PRIYAM GANGULI
% DATE: November 23, 2025
% ========================================================================

decision = struct();
decision.timestamp = datetime('now');

%% STEP 1: Extract Protocol Names and Initialize Feature Matrix
% ========================================================================
% Get list of available protocols from metrics struct
% Remove 'current_protocol' field if present (not a protocol)
if isfield(metrics, 'current_protocol')
    temp_metrics = rmfield(metrics, 'current_protocol');
    protocols = fieldnames(temp_metrics);
else
    protocols = fieldnames(metrics);
end

num_protocols = length(protocols);

% Initialize feature matrix: [distance, RSSI, SINR, weather, congestion]
% Each row represents one protocol, columns are features for ML model
features = zeros(num_protocols, 5);
protocol_names = cell(num_protocols, 1);

%% STEP 2: Build Feature Vectors for Each Protocol
% ========================================================================
% Extract 5 key features that influence protocol performance:
% 1. Distance (km) - affects path loss
% 2. RSSI (dBm) - received signal strength
% 3. SINR (dB) - signal quality vs interference
% 4. Weather impact (0-1) - rain/humidity attenuation
% 5. Congestion (0-1) - network load
for i = 1:num_protocols
    prot_name = protocols{i};
    protocol_names{i} = prot_name;
    
    % Get metrics for this protocol
    if isfield(metrics, prot_name)
        prot_metrics = metrics.(prot_name);
        
        % Extract features for ML model input
        if isstruct(prot_metrics)
            features(i, 1) = prot_metrics.distance_km;      % Distance to user
            features(i, 2) = prot_metrics.rssi;             % Signal strength
            features(i, 3) = prot_metrics.sinr;             % Signal quality
            features(i, 4) = prot_metrics.weather_impact;   % Weather factor (0-1)
            features(i, 5) = prot_metrics.congestion;       % Network load (0-1)
        else
            % Fallback if metrics are not in expected format
            features(i, :) = [1, -100, -10, 0.5, 0.5];
        end
    end
end

%% STEP 3: Predict Throughput Using ML Model or Heuristic
% ========================================================================
% Use trained ML model (ensemble regression) to predict throughput
% Fallback to heuristic if model unavailable or prediction fails
% Heuristic: Throughput decreases exponentially with distance and weather
if ~isempty(predictor_model)
    try
        % ML prediction: trained on 10,000+ scenarios
        predicted_throughput = predict(predictor_model, features);
    catch
        % Fallback: exponential decay with distance, weather penalty
        predicted_throughput = max(0.01, 10 * exp(-features(:,1)/1.5) .* (1 - 0.3*features(:,4)));
    end
else
    % Heuristic-based prediction when no model available
    % Formula: Base throughput * distance_decay * weather_penalty
    predicted_throughput = max(0.01, 10 * exp(-features(:,1)/1.5) .* (1 - 0.3*features(:,4)));
end

%% STEP 4: Apply Traffic-Type Specific Scoring
% ========================================================================
% Different traffic types have different requirements:
% - Voice: Low latency + high reliability (real-time)
% - Data: Balanced throughput + reliability
% - Video: High throughput (can buffer)
% - Telemetry: High reliability (small packets)
switch traffic_type
    case 'emergency_voice'
        % Emergency VoIP: Prioritize low latency and reliability
        % Weights: 40% latency, 40% reliability, 20% throughput
        latency_score = 1 ./ (1 + features(:,1));           % Closer = lower latency
        reliability_score = (features(:,3) + 30) / 40;      % SINR normalized to 0-1
        score = 0.4 * latency_score + 0.4 * reliability_score + ...
                0.2 * predicted_throughput/max(predicted_throughput);
        
    case 'emergency_data'
        % Emergency text/images: Balance throughput and reliability
        % Weights: 50% throughput, 50% reliability
        throughput_score = predicted_throughput / max(predicted_throughput);
        reliability_score = (features(:,3) + 30) / 40;
        score = 0.5 * throughput_score + 0.5 * reliability_score;
        
    case 'video'
        % Video streaming: Prioritize high throughput (can buffer)
        % Weights: 100% throughput
        score = predicted_throughput;
        
    case 'telemetry'
        % Sensor data: Low bandwidth, prioritize reliability
        % Weights: 100% reliability (SINR)
        reliability_score = (features(:,3) + 30) / 40;
        score = reliability_score;
        
    otherwise
        % Default: Use predicted throughput as score
        score = predicted_throughput;
end

%% STEP 5: Emergency Mode Boost for Satellite
% ========================================================================
% In emergency scenarios, satellite provides critical backup when
% terrestrial infrastructure may be damaged. Boost satellite score by 50%
% to prefer it over terrestrial options when conditions are similar.
if emergency_mode
    for i = 1:num_protocols
        if contains(protocol_names{i}, 'SAT', 'IgnoreCase', true)
            score(i) = score(i) * 1.5; % 50% boost for satellite in emergency
        end
    end
end

%% STEP 6: Select Best Protocol and Build Decision Structure
% ========================================================================
% Choose protocol with highest score and package all decision info
[best_score, best_idx] = max(score);
decision.selected_protocol = protocol_names{best_idx};
decision.score = best_score;
decision.predicted_throughput_mbps = predicted_throughput(best_idx);
decision.all_scores = score;
decision.all_protocols = protocol_names;
decision.traffic_type = traffic_type;
decision.emergency_mode = emergency_mode;

%% STEP 7: Adaptive Handoff Logic
% ========================================================================
% Check if we should switch from current protocol to a better one
% Handoff threshold: New protocol must be >30% better to avoid ping-pong
% This hysteresis prevents frequent switching that wastes resources
decision.handoff_recommended = false;
if isfield(metrics, 'current_protocol')
    current_prot = metrics.current_protocol;
    current_idx = find(strcmp(protocol_names, current_prot));
    if ~isempty(current_idx)
        % Handoff if new protocol is significantly better (>30% improvement)
        if best_score > score(current_idx) * 1.3
            decision.handoff_recommended = true;
            decision.handoff_reason = sprintf('Better protocol available: %s (%.1f%% improvement)', ...
                decision.selected_protocol, (best_score/score(current_idx) - 1)*100);
        end
    end
end

end
