function [lat, lon, alt] = drone_sim_realworld(t, cfg)
% Returns drone position at time t in real-world coordinates (lat, lon, altitude)

% Circular flight pattern
period = (2 * pi * cfg.locations.radius_km * 1000) / cfg.drone.speed_mps; % seconds
omega = 2*pi/period;

% Offset in meters from center
dx = cfg.locations.radius_km * 1000 * cos(omega*t); % meters
dy = cfg.locations.radius_km * 1000 * sin(omega*t); % meters

% Convert meters to lat/lon offset (approximate)
% 1 degree latitude ≈ 111 km
% 1 degree longitude ≈ 111 km * cos(latitude)
center_lat = cfg.locations.start(1);
center_lon = cfg.locations.start(2);

lat = center_lat + (dy / 111000);
lon = center_lon + (dx / (111000 * cosd(center_lat)));
alt = cfg.drone.altitude_m;
end
