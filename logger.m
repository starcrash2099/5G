function logger(action, data, cfg)
% Comprehensive logging system with timestamps
% Actions: 'init', 'log', 'save', 'finalize'

persistent log_data log_file;

switch action
    case 'init'
        % Initialize log structure
        log_data = struct();
        log_data.entries = [];
        log_data.start_time = datetime('now');
        log_data.config = cfg;
        
        % Create log filename with timestamp
        timestamp = datestr(now, 'yyyymmdd_HHMMSS');
        log_file = sprintf('logs/simulation_%s.mat', timestamp);
        
        % Create logs directory
        if ~exist('logs', 'dir')
            mkdir('logs');
        end
        
        fprintf('Logger initialized. Log file: %s\n', log_file);
        
    case 'log'
        % Add entry to log
        entry = data;
        entry.timestamp = datetime('now');
        entry.elapsed_seconds = seconds(entry.timestamp - log_data.start_time);
        
        log_data.entries = [log_data.entries; entry];
        
    case 'save'
        % Periodic save
        if ~isempty(log_data)
            save(log_file, 'log_data', '-v7.3');
        end
        
    case 'finalize'
        % Final save with summary
        log_data.end_time = datetime('now');
        log_data.total_duration = log_data.end_time - log_data.start_time;
        
        % Generate summary statistics
        log_data.summary = generate_summary(log_data);
        
        save(log_file, 'log_data', '-v7.3');
        
        % Also save human-readable text log
        text_file = strrep(log_file, '.mat', '.txt');
        write_text_log(text_file, log_data);
        
        fprintf('Log finalized and saved to:\n  %s\n  %s\n', log_file, text_file);
end
end

function summary = generate_summary(log_data)
% Generate summary statistics from log data

summary = struct();
summary.total_entries = length(log_data.entries);

if summary.total_entries == 0
    return;
end

% Extract protocol names
proto_names = fieldnames(log_data.entries(1).metrics);

for i = 1:length(proto_names)
    pname = proto_names{i};
    
    % Collect all values for this protocol (with error handling)
    rssi_vals = [];
    sinr_vals = [];
    tput_vals = [];
    dist_vals = [];
    
    for j = 1:length(log_data.entries)
        try
            if isfield(log_data.entries(j), 'metrics') && ...
               isfield(log_data.entries(j).metrics, pname)
                rssi_vals(end+1) = log_data.entries(j).metrics.(pname).rssi_dBm;
                sinr_vals(end+1) = log_data.entries(j).metrics.(pname).sinr_dB;
                tput_vals(end+1) = log_data.entries(j).metrics.(pname).throughput_mbps;
                if i == 1  % Only collect distance once
                    dist_vals(end+1) = log_data.entries(j).metrics.(pname).distance_m;
                end
            end
        catch
            % Skip entries with missing data
            continue;
        end
    end
    
    if ~isempty(rssi_vals)
        summary.(pname) = struct(...
            'avg_rssi_dBm', mean(rssi_vals), ...
            'min_rssi_dBm', min(rssi_vals), ...
            'max_rssi_dBm', max(rssi_vals), ...
            'avg_sinr_dB', mean(sinr_vals), ...
            'avg_throughput_mbps', mean(tput_vals), ...
            'max_throughput_mbps', max(tput_vals) ...
        );
    end
    
    if i == 1 && ~isempty(dist_vals)
        summary.distance = struct(...
            'avg_m', mean(dist_vals), ...
            'min_m', min(dist_vals), ...
            'max_m', max(dist_vals) ...
        );
    end
end
end

function write_text_log(filename, log_data)
% Write human-readable text log

fid = fopen(filename, 'w');

fprintf(fid, '=== AeroSat Simulation Log ===\n');
fprintf(fid, 'Campaign: %s\n', log_data.config.CAMPAIGN_NAME);
fprintf(fid, 'Start Time: %s\n', datestr(log_data.start_time));
fprintf(fid, 'End Time: %s\n', datestr(log_data.end_time));
fprintf(fid, 'Duration: %s\n\n', char(log_data.total_duration));

fprintf(fid, '--- Summary Statistics ---\n');
proto_names = fieldnames(log_data.summary);
proto_names = proto_names(~ismember(proto_names, {'total_entries', 'distance'}));

for i = 1:length(proto_names)
    pname = proto_names{i};
    s = log_data.summary.(pname);
    fprintf(fid, '\n%s:\n', pname);
    fprintf(fid, '  Avg RSSI: %.2f dBm (min: %.2f, max: %.2f)\n', ...
        s.avg_rssi_dBm, s.min_rssi_dBm, s.max_rssi_dBm);
    fprintf(fid, '  Avg SINR: %.2f dB\n', s.avg_sinr_dB);
    fprintf(fid, '  Avg Throughput: %.2f Mbps (max: %.2f)\n', ...
        s.avg_throughput_mbps, s.max_throughput_mbps);
end

if isfield(log_data.summary, 'distance')
    fprintf(fid, '\nDistance: Avg %.1fm (min: %.1fm, max: %.1fm)\n', ...
        log_data.summary.distance.avg_m, ...
        log_data.summary.distance.min_m, ...
        log_data.summary.distance.max_m);
end

fprintf(fid, '\n--- Detailed Entries ---\n');
fprintf(fid, 'Total Entries: %d\n\n', log_data.summary.total_entries);

fclose(fid);
end
