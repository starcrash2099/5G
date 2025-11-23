function pos = drone_sim(t, cfg)
% returns drone position at time t (seconds) as [x,y] in km
R = 0.6; % km radius
period = 160; % seconds per round
omega = 2*pi/period;
x = R * cos(omega*t) + cfg.drone.initPos(1);
y = R * sin(omega*t) + cfg.drone.initPos(2);
pos = [x, y];
end
