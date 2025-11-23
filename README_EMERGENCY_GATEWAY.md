# AI-Enabled Drone-Based Emergency Communication Gateway

## Overview
Complete emergency communication system with:
- **Virtual drone simulation** (MATLAB)
- **Real-world data integration** via public APIs (no login required)
- **AI-based intelligent routing**
- **Multi-protocol support** (WiFi, LTE, 5G, Satellite)
- **Emergency traffic prioritization**
- **Adaptive protocol handoff**

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Emergency Gateway                         │
├─────────────────────────────────────────────────────────────┤
│  Real-World Data (No API Keys)                              │
│  ├─ Open-Meteo: Weather conditions                          │
│  ├─ Celestrak: Satellite TLE/visibility                     │
│  ├─ USGS: Earthquake events                                 │
│  └─ NASA EONET: Fires, storms                               │
├─────────────────────────────────────────────────────────────┤
│  Virtual Drone Simulation (MATLAB)                          │
│  ├─ Circular flight pattern                                 │
│  ├─ Real GPS coordinates                                    │
│  └─ Dynamic altitude/speed                                  │
├─────────────────────────────────────────────────────────────┤
│  AI Routing Engine                                          │
│  ├─ ML-based protocol selection                             │
│  ├─ Feature extraction (RSSI, SINR, weather, distance)      │
│  ├─ Traffic-type aware routing                              │
│  └─ Adaptive handoff logic                                  │
├─────────────────────────────────────────────────────────────┤
│  Emergency Traffic Handler                                  │
│  ├─ QoS prioritization                                      │
│  ├─ Traffic classification                                  │
│  ├─ Video compression in emergency mode                     │
│  └─ Queue management                                        │
├─────────────────────────────────────────────────────────────┤
│  Multi-Protocol Support                                     │
│  ├─ WiFi 2.4GHz / 5GHz                                      │
│  ├─ LTE Band 7                                              │
│  ├─ 5G NR                                                   │
│  └─ Satellite (Starlink-like)                               │
└─────────────────────────────────────────────────────────────┘
```

## Key Features

### 1. Real-World Data Integration (No Login Required)
- **Weather**: Open-Meteo API for temperature, humidity, wind
- **Satellite**: Celestrak TLE data for orbital visibility
- **Emergency Events**: USGS earthquakes, NASA EONET fires/storms
- **No API keys needed** - all public endpoints

### 2. AI-Based Intelligent Routing
- ML predictor trained on synthetic + real data
- Features: distance, RSSI, SINR, weather impact, congestion
- Traffic-type aware (voice, data, video, telemetry)
- Emergency mode protocol boosting

### 3. Emergency Traffic Prioritization
Priority levels:
1. Emergency voice (VoIP)
2. Emergency data (text, images)
3. Video (compressed in emergency mode)
4. Telemetry (sensor data)
5. Normal traffic

### 4. Adaptive Protocol Handoff
- Continuous monitoring of all protocols
- Automatic switching when better option available (>30% improvement)
- Handoff tracking and metrics

### 5. Performance Metrics
- Packet delivery ratio (overall and emergency)
- Latency distribution and percentiles
- Emergency packets within threshold (500ms)
- Protocol usage statistics
- Handoff count

## Files

### Core Simulation
- `main_emergency.m` - Main emergency gateway simulation
- `config_emergency.m` - Emergency configuration
- `drone_sim_realworld.m` - Virtual drone movement

### AI & Routing
- `ai_routing_engine.m` - Intelligent protocol selection
- `emergency_traffic_handler.m` - QoS and prioritization
- `predictor_train.m` - Train ML model

### Real-World Data APIs
- `get_real_weather.m` - Open-Meteo weather API
- `get_satellite_visibility.m` - Celestrak TLE data
- `get_emergency_events.m` - USGS + NASA EONET events

### Channel Models
- `channel_model_multiprotocol.m` - Multi-protocol propagation
- `sat_emulator.m` - Satellite link emulation

### Visualization
- `generate_emergency_plots.m` - Comprehensive plots
- `logger.m` - Data logging

### Legacy (Basic Simulation)
- `main_realworld.m` - Basic real-world simulation
- `config_realworld.m` - Basic configuration

## Usage

### Quick Start
```matlab
% In MATLAB:
main_emergency
```

### Train ML Predictor (Optional)
```matlab
predictor_train(cfg);
```

### Configuration
Edit `config_emergency.m`:
```matlab
cfg.locations.start = [28.6139, 77.2090]; % Your location
cfg.simTime = 600; % Simulation duration (seconds)
cfg.emergency.enabled = true; % Enable emergency mode
cfg.ai.enabled = true; % Enable AI routing
```

## Output

### Logs
- `logs/simulation_TIMESTAMP.mat` - MATLAB data
- `logs/simulation_TIMESTAMP.txt` - Human-readable log

### Visualizations
- `emergency_map_TIMESTAMP.png` - Drone trajectory + events
- `protocol_selection_TIMESTAMP.png` - AI routing decisions
- `performance_dashboard_TIMESTAMP.png` - Comprehensive metrics
- `ai_routing_scores_TIMESTAMP.png` - Routing score heatmap

## Performance Metrics

The system tracks:
- **Delivery Ratio**: % of packets successfully delivered
- **Emergency Delivery**: % of emergency packets delivered
- **Latency**: Mean, median, distribution
- **Emergency Latency**: Latency for emergency traffic
- **Threshold Compliance**: % within 500ms threshold
- **Protocol Handoffs**: Number of adaptive switches

## API Endpoints Used (No Login)

### Weather
```
https://api.open-meteo.com/v1/forecast?latitude=LAT&longitude=LON&current=temperature_2m,relative_humidity_2m,wind_speed_10m,cloud_cover,precipitation
```

### Satellite TLE
```
https://celestrak.com/NORAD/elements/gp.php?GROUP=starlink&FORMAT=tle
```

### Earthquakes
```
https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson
```

### Natural Events (Fires, Storms)
```
https://eonet.gsfc.nasa.gov/api/v3/events?status=open&limit=100
```

## Emergency Scenarios

The system automatically detects and responds to:
- **Earthquakes** within search radius
- **Wildfires** from NASA FIRMS
- **Storms** from NASA EONET
- **Network outages** (simulated based on emergency zones)

## Future Enhancements

- Real SGP4 orbit propagation for satellite visibility
- OpenStreetMap integration for population density
- M-Lab historical data for congestion patterns
- Real hardware deployment (Raspberry Pi + SDR)
- Multi-drone coordination

## Requirements

- MATLAB R2019b or later
- Statistics and Machine Learning Toolbox
- Internet connection (for API calls)

## Notes

- **No API keys required** - all data sources are public
- **Operator telemetry** (cell tower congestion) is simulated - real data requires operator access
- **Satellite backhaul** uses Celestrak TLE + simulated link - real telemetry requires vendor partnership
- This is standard practice for academic/research proof-of-concept systems

## Citation

If using this for research/academic purposes, please cite:
```
AI-Enabled Drone-Based Emergency Communication Gateway
with Satellite Backhaul and Intelligent Routing
[Your Name/Institution]
2025
```

## License

[Specify your license]
