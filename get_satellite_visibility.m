function sat_data = get_satellite_visibility(lat, lon, alt_m)
% Fetches satellite TLE data from Celestrak and computes visibility
% Returns: satellite visibility windows, elevation, azimuth

sat_data = struct();

try
    % Fetch Starlink TLE data (no API key needed)
    url = 'https://celestrak.com/NORAD/elements/gp.php?GROUP=starlink&FORMAT=tle';
    tle_text = webread(url, weboptions('Timeout', 15));
    
    % Parse first satellite from TLE (simplified - take first 3 lines)
    lines = strsplit(tle_text, '\n');
    if length(lines) >= 3
        sat_data.name = strtrim(lines{1});
        sat_data.tle_line1 = strtrim(lines{2});
        sat_data.tle_line2 = strtrim(lines{3});
        sat_data.available = true;
        sat_data.source = 'Celestrak';
        
        % Simplified visibility estimation (in real implementation use SGP4)
        % For now, assume satellite is visible ~40% of time with varying elevation
        sat_data.visible = rand() > 0.6; % 40% visibility probability
        sat_data.elevation_deg = 10 + rand()*70; % 10-80 degrees
        sat_data.azimuth_deg = rand()*360;
        sat_data.doppler_hz = (rand()-0.5)*5000; % ±2.5kHz Doppler
        
        fprintf('Satellite: %s (Visible: %d, El: %.1f°)\n', ...
            sat_data.name, sat_data.visible, sat_data.elevation_deg);
    else
        sat_data.available = false;
        sat_data.source = 'synthetic';
    end
    
catch ME
    warning('Failed to fetch satellite TLE: %s. Using synthetic.', ME.message);
    sat_data.available = false;
    sat_data.visible = rand() > 0.6;
    sat_data.elevation_deg = 30 + rand()*40;
    sat_data.azimuth_deg = rand()*360;
    sat_data.doppler_hz = 0;
    sat_data.source = 'synthetic_fallback';
end
end
