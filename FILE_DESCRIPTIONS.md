# 📁 File Descriptions

Complete guide to all files in the AI Emergency Communication Gateway project.

---

## 🎯 Main Simulation Files

### `main_emergency.m`
**Purpose**: Main emergency gateway simulation with AI routing and real-world data  
**What it does**:
- Loads configuration and initializes logger
- Fetches real-world data (weather, satellites, disasters)
- Runs 10-minute drone simulation with circular flight pattern
- Uses AI to select best protocol every second
- Tracks performance metrics (delivery ratio, latency, handoffs)
- Generates comprehensive visualizations

**How to run**: `main_emergency` in MATLAB

---

### `config_emergency.m`
**Purpose**: Configuration file for emergency gateway simulation  
**What it contains**:
- Location settings (Delhi, India by default)
- Drone parameters (altitude: 150m, speed: 20 m/s, radius: 5km)
- Protocol definitions (WiFi 2.4/5GHz, LTE, 5G, Satellite)
- AI routing settings (model path, handoff threshold)
- Emergency mode parameters (auto-detect, priority boost)
- Traffic patterns (voice, data, video, telemetry rates)
- API settings (weather, events, satellite)

**How to customize**: Edit values in this file before running simulation

---

### `main_realworld.m`
**Purpose**: Basic real-world simulation (simpler version)  
**What it does**:
- Similar to main_emergency.m but without emergency features
- Good for testing basic functionality
- Uses real weather and satellite data
- Simpler visualization

**How to run**: `main_realworld` in MATLAB

---

### `config_realworld.m`
**Purpose**: Configuration for basic real-world simulation  
**What it contains**: Simplified version of config_emergency.m

---

### `main.m`
**Purpose**: Legacy basic simulation (no real-world data)  
**What it does**: Original simple simulation for testing core functionality

---

### `config.m`
**Purpose**: Legacy configuration file  
**What it contains**: Basic simulation parameters

---

## 🤖 AI & Routing

### `ai_routing_engine.m`
**Purpose**: Core AI routing engine for intelligent protocol selection  
**What it does**:
1. Extracts features: [distance, RSSI, SINR, weather, congestion]
2. Predicts throughput using ML model (ensemble regression)
3. Applies traffic-type specific scoring:
   - Voice: 40% latency + 40% reliability + 20% throughput
   - Data: 50% throughput + 50% reliability
   - Video: 100% throughput
   - Telemetry: 100% reliability
4. Boosts satellite score by 50% in emergency mode
5. Selects best protocol
6. Checks if handoff needed (>30% improvement threshold)

**Inputs**: Metrics for all protocols, traffic type, emergency mode, ML model  
**Output**: Decision struct with selected protocol, score, handoff recommendation

---

### `emergency_traffic_handler.m`
**Purpose**: QoS and traffic prioritization  
**What it does**:
1. Classifies traffic by type (voice, data, video, telemetry)
2. Assigns priority levels (1-5, lower = higher priority)
3. Sorts packets by priority
4. Drops lowest priority packets if queue > 1000
5. Compresses video by 60% in emergency mode
6. Marks emergency packets for special handling

**Priority Levels**:
1. Emergency Voice (VoIP)
2. Emergency Data (text, images)
3. Video
4. Telemetry
5. Normal

---

### `predictor_train.m`
**Purpose**: Train ML model for throughput prediction  
**What it does**:
1. Generates 10,000+ training scenarios
2. Simulates channel conditions for each scenario
3. Trains ensemble regression model (bagged trees)
4. Saves model to `models/predictor_model.mat`

**How to run**: 
```matlab
config_emergency;
global cfg;
predictor_train(cfg);
```

---

## 🌍 Real-World Data APIs

### `get_real_weather.m`
**Purpose**: Fetch weather data from Open-Meteo API  
**What it does**:
- Calls Open-Meteo API (no key required)
- Returns temperature, humidity, wind speed, cloud cover, precipitation
- Used to calculate signal attenuation

**API**: `https://api.open-meteo.com/v1/forecast`  
**Returns**: Struct with weather data

---

### `get_satellite_visibility.m`
**Purpose**: Fetch satellite orbital data from Celestrak  
**What it does**:
- Downloads TLE (Two-Line Element) data from Celestrak
- Calculates satellite visibility at given location
- Returns elevation, azimuth, visibility status

**API**: `https://celestrak.com/NORAD/elements/gp.php?GROUP=starlink&FORMAT=tle`  
**Returns**: Struct with satellite data

---

### `get_emergency_events.m`
**Purpose**: Fetch real-time disaster data  
**What it does**:
- Queries USGS for earthquakes (last 24 hours)
- Queries NASA EONET for fires and storms
- Filters events within search radius (default 100km)
- Returns list of nearby disasters

**APIs**:
- USGS: `https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson`
- NASA EONET: `https://eonet.gsfc.nasa.gov/api/v3/events`

**Returns**: Struct with earthquakes, fires, storms arrays

---

### `test_apis.m`
**Purpose**: Test connectivity to all APIs  
**What it does**:
- Tests Open-Meteo weather API
- Tests Celestrak satellite TLE
- Tests USGS earthquake API
- Tests NASA EONET events API
- Prints success/failure for each

**How to run**: `test_apis` in MATLAB  
**Expected**: All 4 APIs should return ✓ SUCCESS

---

## 🚁 Simulation Core

### `drone_sim.m`
**Purpose**: Basic drone movement simulation  
**What it does**:
- Simulates circular flight pattern
- Returns [x, y, z] coordinates in meters
- Simple version without GPS coordinates

---

### `drone_sim_realworld.m`
**Purpose**: Real-world drone simulation with GPS  
**What it does**:
- Circular flight pattern around start location
- Uses real GPS coordinates (latitude, longitude)
- Configurable altitude, speed, radius
- Returns [lat, lon, alt] at each timestep

**Algorithm**:
```
angle = (speed / radius) * time
lat = start_lat + radius * cos(angle) / 111.32
lon = start_lon + radius * sin(angle) / (111.32 * cos(start_lat))
alt = configured_altitude
```

---

### `channel_model.m`
**Purpose**: Basic wireless channel model  
**What it does**:
- Calculates path loss (free space)
- Computes RSSI, SINR, throughput
- Simple version for single protocol

---

### `channel_model_multiprotocol.m`
**Purpose**: Multi-protocol channel model with weather  
**What it does**:
1. Calculates distance between drone and user (Haversine formula)
2. Computes frequency-dependent path loss for each protocol
3. Applies weather-based attenuation:
   - Rain attenuation (ITU-R P.838)
   - Humidity absorption
   - Cloud cover effects
4. Calculates RSSI, SINR, throughput for each protocol
5. Returns metrics struct with all protocols

**Protocols Supported**:
- WiFi 2.4GHz (2.4 GHz, 20 MHz BW)
- WiFi 5GHz (5.8 GHz, 40 MHz BW)
- LTE Band 7 (2.6 GHz, 10 MHz BW)
- 5G NR (3.5 GHz, 100 MHz BW)
- Satellite (12 GHz, 250 MHz BW)

**Formulas**:
```
Path Loss = 20*log10(distance) + 20*log10(frequency) + 20*log10(4π/c)
RSSI = TxPower + TxGain + RxGain - PathLoss - WeatherLoss
SINR = RSSI - Noise - Interference
Throughput = Bandwidth * log2(1 + SINR) * efficiency
```

---

### `sat_emulator.m`
**Purpose**: Satellite link emulation  
**What it does**:
- Simulates Starlink-like satellite link
- Adds latency (25ms ± 5ms jitter)
- Simulates packet loss (0.1%)
- Models Doppler shift
- Checks visibility constraints

**Parameters**:
- Latency: 25ms (one-way)
- Jitter: 5ms
- Loss probability: 0.001 (0.1%)
- Frequency: 12 GHz (Ku-band)

---

## 📊 Visualization & Logging

### `generate_plots.m`
**Purpose**: Generate basic visualization plots  
**What it does**:
- Creates 6 subplots showing simulation results
- Saves to results/ directory

---

### `generate_emergency_plots.m`
**Purpose**: Generate comprehensive emergency visualizations  
**What it does**:
1. **Emergency Map**: Drone trajectory with GPS coordinates, emergency event markers
2. **Protocol Selection**: Timeline showing AI routing decisions over time
3. **Performance Dashboard**: 6 subplots with:
   - Delivery ratio over time
   - Latency distribution (histogram)
   - Emergency vs normal latency (box plot)
   - Protocol usage (pie chart)
   - Throughput over time
   - Handoff events timeline
4. **AI Routing Scores**: Heatmap showing protocol scores over time

**Output**: 4 PNG files saved to results/ directory

---

### `logger.m`
**Purpose**: Comprehensive logging system  
**What it does**:
- **'init'**: Initialize logger, create log file
- **'log'**: Add entry to log with timestamp
- **'save'**: Periodic save to disk
- **'finalize'**: Generate summary statistics, save MAT + TXT

**Actions**:
```matlab
logger('init', [], cfg);           % Initialize
logger('log', entry, cfg);         % Log entry
logger('save', [], cfg);           % Save
logger('finalize', [], cfg);       % Finalize
```

**Output Files**:
- `logs/simulation_YYYYMMDD_HHMMSS.mat` - MATLAB data structure
- `logs/simulation_YYYYMMDD_HHMMSS.txt` - Human-readable summary

**Summary Statistics**:
- Per-protocol: avg/min/max RSSI, avg SINR, avg/max throughput
- Distance: avg/min/max distance to user
- Total entries logged

---

## 📚 Documentation

### `README.md`
**Purpose**: Main project documentation (this file)  
**What it contains**:
- Project overview and features
- System architecture diagram
- Quick start guide
- Installation instructions
- Usage examples
- Configuration guide
- API documentation
- Performance benchmarks
- Troubleshooting

---

### `EXECUTIVE_SUMMARY.md`
**Purpose**: Academic summary for presentations/papers  
**What it contains**:
- Project objectives and approach
- Key innovations
- System architecture
- Performance results
- Technical implementation details
- Academic contribution
- Demonstration scenario

---

### `PROJECT_STATUS.md`
**Purpose**: Implementation status checklist  
**What it contains**:
- Completed features (all ✅)
- File descriptions
- What's available vs what's simulated
- How to run guide
- Performance expectations

---

### `QUICKSTART.md`
**Purpose**: 5-minute setup guide  
**What it contains**:
- Prerequisites
- Installation steps
- First run instructions
- Expected output

---

### `README_EMERGENCY_GATEWAY.md`
**Purpose**: Detailed emergency gateway documentation  
**What it contains**:
- System architecture
- Feature descriptions
- API endpoints
- Usage examples
- Configuration options

---

### `CHECKLIST.md`
**Purpose**: Development checklist  
**What it contains**:
- Feature implementation status
- Testing checklist
- Documentation checklist

---

### `FILE_DESCRIPTIONS.md`
**Purpose**: This file - complete guide to all files

---

## 📂 Output Directories

### `logs/`
**Purpose**: Simulation logs  
**Contents**:
- `simulation_YYYYMMDD_HHMMSS.mat` - MATLAB data
- `simulation_YYYYMMDD_HHMMSS.txt` - Text summary

---

### `results/`
**Purpose**: Generated visualizations  
**Contents**:
- `emergency_map_*.png` - Drone trajectory with events
- `protocol_selection_*.png` - AI routing timeline
- `performance_dashboard_*.png` - Metrics dashboard
- `ai_routing_scores_*.png` - Routing scores heatmap

---

### `models/`
**Purpose**: Trained ML models  
**Contents**:
- `predictor_model.mat` - Pre-trained ensemble regression model

---

## 🔧 Helper Functions

### `haversine_distance(lat1, lon1, lat2, lon2)`
**Purpose**: Calculate distance between GPS coordinates  
**Formula**: Great circle distance using Haversine formula  
**Returns**: Distance in kilometers

---

## 📊 Data Structures

### Configuration Struct (`cfg`)
```matlab
cfg.CAMPAIGN_NAME           % Simulation name
cfg.simTime                 % Duration (seconds)
cfg.dt                      % Time step (seconds)
cfg.locations.start         % [lat, lon] drone start
cfg.locations.user          % [lat, lon] user location
cfg.locations.radius_km     % Flight radius
cfg.drone.altitude_m        % Altitude
cfg.drone.speed_mps         % Speed
cfg.protocols               % Cell array of protocol structs
cfg.emergency.enabled       % Emergency mode flag
cfg.ai.enabled              % AI routing flag
cfg.ai.model_path           % Path to ML model
```

### Metrics Struct
```matlab
metrics.WiFi_24GHz.distance_km
metrics.WiFi_24GHz.rssi
metrics.WiFi_24GHz.sinr
metrics.WiFi_24GHz.throughput
metrics.WiFi_24GHz.weather_impact
metrics.WiFi_24GHz.congestion
% ... (same for all protocols)
```

### Decision Struct
```matlab
decision.selected_protocol      % Best protocol name
decision.score                  % Confidence score
decision.predicted_throughput_mbps
decision.handoff_recommended    % Boolean
decision.handoff_reason         % String explanation
decision.all_scores             % Scores for all protocols
decision.all_protocols          % Protocol names
```

### Performance Struct
```matlab
performance.total_packets
performance.delivered_packets
performance.emergency_packets
performance.emergency_delivered
performance.handoff_count
performance.latencies           % Array of latencies (ms)
performance.emergency_latencies % Array of emergency latencies
```

---

## 🚀 Execution Flow

1. **Load Configuration** (`config_emergency.m`)
2. **Initialize Logger** (`logger('init')`)
3. **Fetch Real-World Data**:
   - Weather (`get_real_weather.m`)
   - Emergency events (`get_emergency_events.m`)
   - Satellite visibility (`get_satellite_visibility.m`)
4. **Load AI Model** (`predictor_model.mat`)
5. **Simulation Loop** (600 iterations for 10 minutes):
   - Get drone position (`drone_sim_realworld.m`)
   - Calculate channel metrics (`channel_model_multiprotocol.m`)
   - Generate traffic packets
   - Prioritize traffic (`emergency_traffic_handler.m`)
   - AI routing decision (`ai_routing_engine.m`)
   - Simulate packet delivery
   - Log metrics (`logger('log')`)
6. **Finalize** (`logger('finalize')`)
7. **Generate Visualizations** (`generate_emergency_plots.m`)

---

## 📝 Key Algorithms

### AI Routing
```
For each protocol:
  features = [distance, RSSI, SINR, weather, congestion]
  throughput = ML_predict(features)
  score = traffic_aware_scoring(throughput, features, traffic_type)
  if emergency_mode and protocol == satellite:
    score *= 1.5
selected = argmax(score)
if score[selected] > score[current] * 1.3:
  handoff()
```

### Traffic Prioritization
```
Priority levels:
  1. Emergency voice
  2. Emergency data
  3. Video
  4. Telemetry
  5. Normal
Sort packets by priority
Drop lowest if queue > 1000
Compress video 60% in emergency mode
```

### Channel Model
```
PathLoss = 20*log10(d) + 20*log10(f) + 20*log10(4π/c) + X_shadow
WeatherLoss = rain_attenuation + humidity_absorption
RSSI = TxPower + Gains - PathLoss - WeatherLoss
SINR = (RSSI - Noise) / Noise
Throughput = BW * log2(1 + SINR) * efficiency
```

---

## 🎓 For Developers

### Adding a New Protocol
1. Edit `config_emergency.m`:
```matlab
cfg.protocols{end+1} = struct(...
    'name', 'NewProtocol', ...
    'freq', 28e9, ...  % 28 GHz
    'txPower_dBm', 30, ...
    'bandwidth_MHz', 400, ...
    'type', 'terrestrial');
```

2. Update `channel_model_multiprotocol.m` if special handling needed

### Adding a New Traffic Type
1. Edit `emergency_traffic_handler.m`:
```matlab
PRIORITY.new_type = 3;  % Priority level
```

2. Update `ai_routing_engine.m` scoring:
```matlab
case 'new_type'
    score = custom_scoring_function(features);
```

### Training Custom ML Model
```matlab
config_emergency;
global cfg;
predictor_train(cfg);  % Generates models/predictor_model.mat
```

---

## 🐛 Common Issues

### API Connection Fails
- Check internet connection
- Verify API URLs are accessible
- Run `test_apis` to diagnose

### ML Model Not Found
- Run `predictor_train(cfg)` to generate model
- Or disable AI: `cfg.ai.enabled = false;`

### Simulation Runs Slowly
- Reduce `cfg.simTime` (e.g., 300 instead of 600)
- Increase `cfg.dt` (e.g., 2.0 instead of 1.0)
- Reduce `cfg.log.save_interval`

---

## 📞 Support

For issues or questions:
1. Check this file for function descriptions
2. Read comments in source files
3. Review `README.md` for usage examples
4. Open GitHub issue

---

**Last Updated**: November 23, 2025  
**Version**: 1.0  
**Total Files**: 30+
