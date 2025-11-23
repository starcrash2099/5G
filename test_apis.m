% Test all no-login APIs to verify they work
clear; clc;

fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  Testing All Public APIs (No Login Required)              ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n\n');

% Test location: Delhi, India
test_lat = 28.6139;
test_lon = 77.2090;

%% 1. Test Open-Meteo Weather API
fprintf('1. Testing Open-Meteo Weather API...\n');
try
    url = sprintf('https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,wind_speed_10m,cloud_cover,precipitation', ...
        test_lat, test_lon);
    weather = webread(url, weboptions('Timeout', 10));
    
    fprintf('   ✓ SUCCESS\n');
    fprintf('   Temperature: %.1f°C\n', weather.current.temperature_2m);
    fprintf('   Humidity: %d%%\n', weather.current.relative_humidity_2m);
    fprintf('   Wind: %.1f km/h\n', weather.current.wind_speed_10m);
    fprintf('   Cloud Cover: %d%%\n\n', weather.current.cloud_cover);
catch ME
    fprintf('   ✗ FAILED: %s\n\n', ME.message);
end

%% 2. Test Celestrak Satellite TLE
fprintf('2. Testing Celestrak Satellite TLE API...\n');
try
    url = 'https://celestrak.com/NORAD/elements/gp.php?GROUP=starlink&FORMAT=tle';
    tle_data = webread(url, weboptions('Timeout', 15));
    
    lines = strsplit(tle_data, '\n');
    fprintf('   ✓ SUCCESS\n');
    fprintf('   Retrieved %d lines of TLE data\n', length(lines));
    fprintf('   First satellite: %s\n\n', strtrim(lines{1}));
catch ME
    fprintf('   ✗ FAILED: %s\n\n', ME.message);
end

%% 3. Test USGS Earthquake API
fprintf('3. Testing USGS Earthquake API...\n');
try
    url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
    eq_data = webread(url, weboptions('Timeout', 10));
    
    fprintf('   ✓ SUCCESS\n');
    fprintf('   Found %d earthquakes in last 24 hours\n', length(eq_data.features));
    
    if ~isempty(eq_data.features)
        latest = eq_data.features(1);
        fprintf('   Latest: M%.1f - %s\n\n', latest.properties.mag, latest.properties.place);
    else
        fprintf('\n');
    end
catch ME
    fprintf('   ✗ FAILED: %s\n\n', ME.message);
end

%% 4. Test NASA EONET Events API
fprintf('4. Testing NASA EONET Events API...\n');
try
    url = 'https://eonet.gsfc.nasa.gov/api/v3/events?status=open&limit=20';
    eonet_data = webread(url, weboptions('Timeout', 10));
    
    fprintf('   ✓ SUCCESS\n');
    fprintf('   Found %d active natural events\n', length(eonet_data.events));
    
    % Count by category
    fires = 0;
    storms = 0;
    for i = 1:length(eonet_data.events)
        cat = eonet_data.events(i).categories(1).title;
        if contains(lower(cat), 'fire')
            fires = fires + 1;
        elseif contains(lower(cat), 'storm')
            storms = storms + 1;
        end
    end
    fprintf('   Fires: %d, Storms: %d\n\n', fires, storms);
catch ME
    fprintf('   ✗ FAILED: %s\n\n', ME.message);
end

%% Summary
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║  API Test Complete                                         ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\nAll APIs tested. If any failed, check your internet connection.\n');
fprintf('All APIs are public and require NO API KEYS.\n\n');
fprintf('Ready to run: main_emergency\n');
