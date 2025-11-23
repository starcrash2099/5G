function [deliverTime, dropped] = sat_emulator(txTime, cfg)
% returns the time at which packet will be delivered (seconds) and if dropped
lat = cfg.sat.latency_ms/1000 + (cfg.sat.jitter_ms/1000)*randn();
if lat < 0, lat = abs(lat); end

dropped = rand() < cfg.sat.loss_prob;
deliverTime = txTime + lat;
end
