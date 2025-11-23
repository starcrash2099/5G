function weather_data = get_real_weather(lat, lon, cfg)
% Fetches real-time weather data from Open-Meteo API (no API key required)
% Returns: temperature, humidity, wind_speed, cloud_cover

weather_data = struct();

if ~cfg.api.use_real_weather
    % Use synthetic weather if API not configured
    weather_data.temperature = 20 + randn()*5; % Celsius
    weather_data.humidity = 50 + randn()*20; % percent
    weather_data.wind_speed = 5 + abs(randn()*3); % m/s
    weather_data.cloud_cover = rand()*100; % percent
    weather_data.rain = rand() < 0.1; % 10% chance
    weather_data.source = 'synthetic';
    return;
end

try
    % Build Open-Meteo API URL (no API key needed)
    url = sprintf('https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&current=temperature_2m,relative_humidity_2m,wind_speed_10m,cloud_cover,precipitation', ...
        lat, lon);
    
    % Fetch data
    options = weboptions('Timeout', 10);
    data = webread(url, options);
    
    % Parse response
    weather_data.temperature = data.current.temperature_2m;
    weather_data.humidity = data.current.relative_humidity_2m;
    weather_data.wind_speed = data.current.wind_speed_10m / 3.6; % Convert km/h to m/s
    weather_data.cloud_cover = data.current.cloud_cover;
    weather_data.rain = data.current.precipitation > 0;
    weather_data.source = 'Open-Meteo';
    
    fprintf('Weather fetched: %.1f°C, %d%% humidity, %.1fm/s wind\n', ...
        weather_data.temperature, weather_data.humidity, weather_data.wind_speed);
    
catch ME
    warning('Failed to fetch weather data: %s. Using synthetic data.', ME.message);
    weather_data.temperature = 20 + randn()*5;
    weather_data.humidity = 50 + randn()*20;
    weather_data.wind_speed = 5 + abs(randn()*3);
    weather_data.cloud_cover = rand()*100;
    weather_data.rain = false;
    weather_data.source = 'synthetic_fallback';
end
end
