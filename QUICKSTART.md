# Quick Start Guide

## AI Emergency Communication Gateway - 5 Minute Setup

### Step 1: Test API Connectivity (30 seconds)

Open MATLAB and run:
```matlab
test_apis
```

**Expected Output**:
```
╔════════════════════════════════════════════════════════════╗
║  Testing All Public APIs (No Login Required)              ║
╚════════════════════════════════════════════════════════════╝

1. Testing Open-Meteo Weather API...
   ✓ SUCCESS
   Temperature: 24.3°C
   Humidity: 65%
   Wind: 12.5 km/h
   Cloud Cover: 40%

2. Testing Celestrak Satellite TLE API...
   ✓ SUCCESS
   Retrieved 15000+ lines of TLE data
   First satellite: STARLINK-1007

3. Testing USGS Earthquake API...
   ✓ SUCCESS
   Found 127 earthquakes in last 24 hours
   Latest: M4.2 - 15 km NE of Tokyo, Japan

4. Testing NASA EONET Events API...
   ✓ SUCCESS
   Found 45 active natural events
   Fires: 23, Storms: 8

╔════════════════════════════════════════════════════════════╗
║  API Test Complete                                         ║
╚════════════════════════════════════════════════════════════╝
```

✅ If all 4 APIs show SUCCESS, proceed to Step 2.

❌ If any fail, check your internet connection.

---

### Step 2: Run Emergency Gateway Simulation (5 minutes)

```matlab
main_emergency
```

**What Happens**:
1. Fetches real weather from Open-Meteo
2. Checks for emergency events (USGS earthquakes, NASA fires/storms)
3. Gets satellite visibility from Celestrak
4. Simulates drone flying circular pattern
5. AI routing selects best protocol every second
6. Prioritizes emergency traffic
7. Generates 4 comprehensive visualizations
8. Saves logs and results

**Expected Output**:
```
╔════════════════════════════════════════════════════════════╗
║  AI Emergency Communication Gateway Simulation             ║
║  Drone + Multi-Protocol + Satellite + Real-World Data      ║
╚════════════════════════════════════════════════════════════╝

Campaign: AI-Emergency-Gateway
Location: [28.6139, 77.2090] (Delhi, India)
Simulation Time: 600 seconds
Protocols: WiFi_24GHz WiFi_5GHz LTE_Band7 NR_5G Satellite

--- Fetching Real-World Data ---
Weather: 18.5°C, 72% humidity, 3.2m/s wind (Source: Open-Meteo)
Emergency Events: 3 total (1 earthquakes, 2 fires, 0 storms)
Satellite: Celestrak (Visible: 1)

⚠️  EMERGENCY MODE ACTIVATED (Events detected)

✓ AI Predictor loaded

--- Running Emergency Gateway Simulation ---
Progress: 10% 20% 30% 40% 50% 60% 70% 80% 90% 100% Complete!

╔════════════════════════════════════════════════════════════╗
║  Performance Metrics                                       ║
╚════════════════════════════════════════════════════════════╝
Total Packets: 3245
Delivered: 2987 (92.0%)
Emergency Packets: 1823
Emergency Delivered: 1756 (96.3%)
Protocol Handoffs: 12
Avg Latency: 42.3 ms (median: 38.1 ms)
Emergency Latency: 31.2 ms (median: 28.5 ms)
Within 500 ms threshold: 1751/1756 (99.7%)

--- Generating Visualizations ---
✓ Emergency map saved
✓ Protocol selection saved
✓ Performance dashboard saved
✓ AI routing scores saved

╔════════════════════════════════════════════════════════════╗
║  Emergency Gateway Simulation Complete!                   ║
╚════════════════════════════════════════════════════════════╝
Results saved to logs/ and results/
```

---

### Step 3: View Results

#### Logs
- `logs/simulation_TIMESTAMP.mat` - MATLAB data (load with `load('logs/...')`)
- `logs/simulation_TIMESTAMP.txt` - Human-readable summary

#### Visualizations (in `results/` folder)
1. **emergency_map_TIMESTAMP.png**
   - Drone trajectory
   - Emergency events (earthquakes, fires)
   - Ground station location

2. **protocol_selection_TIMESTAMP.png**
   - AI routing decisions over time
   - Protocol usage distribution

3. **performance_dashboard_TIMESTAMP.png**
   - 6 subplots:
     - Delivery ratios
     - Latency distribution
     - Handoff count
     - Throughput over time
     - RSSI comparison
     - Emergency threshold compliance

4. **ai_routing_scores_TIMESTAMP.png**
   - Heatmap of routing scores
   - Shows which protocols were favored when

---

## Optional: Train Your Own ML Model

```matlab
config_emergency;
global cfg;
predictor_train(cfg);
```

This creates `models/predictor_model.mat` with a trained ensemble regressor.

---

## Customization

### Change Location
Edit `config_emergency.m`:
```matlab
cfg.locations.start = [YOUR_LAT, YOUR_LON];
cfg.locations.user = [USER_LAT, USER_LON];
```

### Change Simulation Duration
```matlab
cfg.simTime = 1200; % 20 minutes
```

### Disable Emergency Mode
```matlab
cfg.emergency.enabled = false;
cfg.emergency.auto_detect = false;
```

### Change Drone Parameters
```matlab
cfg.drone.altitude_m = 200; % Higher altitude
cfg.drone.speed_mps = 25; % Faster
cfg.locations.radius_km = 10; % Larger coverage
```

---

## Troubleshooting

### "Unrecognized function or variable"
**Solution**: Make sure you're in the correct directory:
```matlab
cd 'C:\Users\Priyam\Downloads\image_augmentation_puzzle'
```

### API timeouts
**Solution**: Check internet connection. APIs are public and don't require login.

### "predictor_model.mat not found"
**Solution**: Run `predictor_train(cfg)` first, or simulation will use heuristics (still works).

### Figures not saving
**Solution**: Check that `results/` folder exists. MATLAB will create it automatically.

---

## What Each File Does

| File | Purpose |
|------|---------|
| `main_emergency.m` | Main simulation - run this |
| `test_apis.m` | Test API connectivity |
| `config_emergency.m` | Configuration settings |
| `ai_routing_engine.m` | AI protocol selection |
| `emergency_traffic_handler.m` | Traffic prioritization |
| `get_real_weather.m` | Fetch weather (Open-Meteo) |
| `get_satellite_visibility.m` | Fetch satellite TLE (Celestrak) |
| `get_emergency_events.m` | Fetch disasters (USGS, NASA) |
| `generate_emergency_plots.m` | Create visualizations |
| `drone_sim_realworld.m` | Virtual drone movement |
| `channel_model_multiprotocol.m` | Signal propagation |
| `sat_emulator.m` | Satellite link simulation |
| `logger.m` | Data logging |

---

## Next Steps

1. ✅ Run `test_apis` - verify connectivity
2. ✅ Run `main_emergency` - full simulation
3. ✅ Check `results/` folder - view plots
4. ✅ Read `PROJECT_STATUS.md` - understand what's implemented
5. ✅ Read `README_EMERGENCY_GATEWAY.md` - full documentation

---

## Support

For issues or questions:
1. Check `PROJECT_STATUS.md` for implementation details
2. Check `README_EMERGENCY_GATEWAY.md` for architecture
3. Review MATLAB console output for error messages

---

**Estimated Time**: 5-10 minutes for complete setup and first run

**Requirements**: MATLAB R2019b+, Internet connection, Statistics Toolbox

**No API keys needed** - all data sources are public!
