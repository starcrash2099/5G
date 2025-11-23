function events = get_emergency_events(lat, lon, radius_km)
% Fetches real emergency events from USGS and NASA EONET (no API key)
% Returns: nearby earthquakes, fires, storms

events = struct();
events.earthquakes = [];
events.fires = [];
events.storms = [];
events.total_count = 0;

% 1. USGS Earthquakes (last 24 hours)
try
    url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson';
    eq_data = webread(url, weboptions('Timeout', 10));
    
    if isfield(eq_data, 'features') && ~isempty(eq_data.features)
        % Filter by distance
        for i = 1:min(length(eq_data.features), 50) % limit to 50
            coords = eq_data.features(i).geometry.coordinates;
            eq_lon = coords(1);
            eq_lat = coords(2);
            
            % Calculate distance (haversine approximation)
            dist_km = haversine_distance(lat, lon, eq_lat, eq_lon);
            
            if dist_km <= radius_km
                eq = struct();
                eq.lat = eq_lat;
                eq.lon = eq_lon;
                eq.magnitude = eq_data.features(i).properties.mag;
                eq.place = eq_data.features(i).properties.place;
                eq.time = eq_data.features(i).properties.time;
                eq.distance_km = dist_km;
                events.earthquakes = [events.earthquakes; eq];
            end
        end
    end
    fprintf('Found %d earthquakes within %d km\n', length(events.earthquakes), radius_km);
catch ME
    warning('Failed to fetch USGS data: %s', ME.message);
end

% 2. NASA EONET (Natural events - fires, storms)
try
    url = 'https://eonet.gsfc.nasa.gov/api/v3/events?status=open&limit=100';
    eonet_data = webread(url, weboptions('Timeout', 10));
    
    if isfield(eonet_data, 'events') && ~isempty(eonet_data.events)
        for i = 1:length(eonet_data.events)
            event = eonet_data.events(i);
            if ~isempty(event.geometry)
                coords = event.geometry(1).coordinates;
                ev_lon = coords(1);
                ev_lat = coords(2);
                
                dist_km = haversine_distance(lat, lon, ev_lat, ev_lon);
                
                if dist_km <= radius_km
                    ev = struct();
                    ev.lat = ev_lat;
                    ev.lon = ev_lon;
                    ev.title = event.title;
                    ev.category = event.categories(1).title;
                    ev.distance_km = dist_km;
                    
                    if contains(lower(ev.category), 'fire')
                        events.fires = [events.fires; ev];
                    elseif contains(lower(ev.category), 'storm')
                        events.storms = [events.storms; ev];
                    end
                end
            end
        end
    end
    fprintf('Found %d fires, %d storms within %d km\n', ...
        length(events.fires), length(events.storms), radius_km);
catch ME
    warning('Failed to fetch NASA EONET data: %s', ME.message);
end

events.total_count = length(events.earthquakes) + length(events.fires) + length(events.storms);
events.has_emergency = events.total_count > 0;

end

function dist = haversine_distance(lat1, lon1, lat2, lon2)
% Calculate distance between two points in km
R = 6371; % Earth radius in km
dlat = deg2rad(lat2 - lat1);
dlon = deg2rad(lon2 - lon1);
a = sin(dlat/2)^2 + cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * sin(dlon/2)^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
dist = R * c;
end
