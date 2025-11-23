# 🚀 Complete Setup Guide

Step-by-step guide to set up and run the AI Emergency Communication Gateway.

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [First Run](#first-run)
4. [Configuration](#configuration)
5. [Running Simulations](#running-simulations)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Setup](#advanced-setup)

---

## 1. Prerequisites

### Required Software
- **MATLAB R2019b or later**
  - Download from: https://www.mathworks.com/products/matlab.html
  - Student license available

- **MATLAB Toolboxes**:
  - Statistics and Machine Learning Toolbox
  - (Optional) Parallel Computing Toolbox for faster training

### System Requirements
- **OS**: Windows, macOS, or Linux
- **RAM**: 4GB minimum, 8GB recommended
- **Disk Space**: 500MB for project + logs
- **Internet**: Required for API calls

### Check Your Setup
```matlab
% In MATLAB Command Window:

% Check MATLAB version
ver

% Check required toolbox
ver('stats')

% Should show: Statistics and Machine Learning Toolbox Version X.X
```

---

## 2. Installation

### Option A: Clone from GitHub
```bash
# Using Git
git clone https://github.com/priyamganguli/drone-emergency-gateway.git
cd drone-emergency-gateway
```

### Option B: Download ZIP
1. Go to: https://github.com/priyamganguli/drone-emergency-gateway
2. Click "Code" → "Download ZIP"
3. Extract to your desired location

### Verify Installation
```bash
# Check files are present
ls -la

# Should see:
# main_emergency.m
# config_emergency.m
# ai_routing_engine.m
# etc.
```

---

## 3. First Run

### Step 1: Open MATLAB
```bash
# Navigate to project directory
cd /path/to/drone-emergency-gateway

# Start MATLAB
matlab
```

### Step 2: Test API Connectivity
```matlab
% In MATLAB Command Window:
test_apis
```

**Expected Output:**
```
Testing Real-World APIs (No Login Required)
============================================

[1/4] Testing Open-Meteo Weather API...
✓ SUCCESS: Weather data received
  Temperature: 24.1°C
  Humidity: 41%
  Wind Speed: 1.8 m/s

[2/4] Testing Celestrak Satellite TLE...
✓ SUCCESS: TLE data received
  Satellites found: 3241

[3/4] Testing USGS Earthquake API...
✓ SUCCESS: Earthquake data received
  Events (24h): 127

[4/4] Testing NASA EONET Events API...
✓ SUCCESS: Natural events received
  Active events: 412

============================================
✓ All APIs working! Ready to run simulation.
```

**If APIs Fail:**
- Check internet connection
- Verify firewall allows MATLAB to access internet
- Try again (APIs may be temporarily down)

### Step 3: Run First Simulation
```matlab
% Run emergency gateway simulation (10 minutes)
main_emergency
```

**Expected Duration:** 2-5 minutes (depending on your computer)

**Expected Output:**
```
╔════════════════════════════════════════════════════════════╗
║  AI Emergency Communication Gateway Simulation             ║
╚════════════════════════════════════════════════════════════╝

Campaign: AI-Emergency-Gateway
Location: [28.6139, 77.2090] (Delhi, India)
Simulation Time: 600 seconds
Protocols: WiFi_24GHz WiFi_5GHz LTE_Band7 NR_5G Satellite

--- Fetching Real-World Data ---
Weather: 24.1°C, 41% humidity, 1.8m/s wind
Emergency Events: 0 total
Satellite: STARLINK-1008 (Visible: 1)

--- Running Emergency Gateway Simulation ---
Progress: 10% 20% 30% 40% 50% 60% 70% 80% 90% 100% Complete!

╔════════════════════════════════════════════════════════════╗
║  Performance Metrics                                       ║
╚════════════════════════════════════════════════════════════╝
Total Packets: 6000
Delivered: 5520 (92.0%)
Emergency Packets: 3600
Emergency Delivered: 3467 (96.3%)
Protocol Handoffs: 12

✓ Results saved to logs/ and results/
```

### Step 4: View Results
```matlab
% Navigate to results folder
cd results

% List generated plots
ls -la

% Open a plot
open emergency_map_*.png  % macOS/Linux
% or
system('start emergency_map_*.png')  % Windows
```

**Generated Files:**
- `logs/simulation_YYYYMMDD_HHMMSS.mat` - Simulation data
- `logs/simulation_YYYYMMDD_HHMMSS.txt` - Summary
- `results/emergency_map_*.png` - Drone trajectory
- `results/protocol_selection_*.png` - AI decisions
- `results/performance_dashboard_*.png` - Metrics
- `results/ai_routing_scores_*.png` - Routing scores

---

## 4. Configuration

### Basic Configuration

Edit `config_emergency.m` to customize simulation:

#### Change Location
```matlab
% Example: San Francisco, USA
cfg.locations.start = [37.7749, -122.4194];  % Drone start
cfg.locations.user = [37.8044, -122.2712];   % User location
cfg.locations.radius_km = 5.0;               % Flight radius
```

#### Change Simulation Duration
```matlab
cfg.simTime = 300;  % 5 minutes instead of 10
cfg.dt = 1.0;       % 1-second time steps
```

#### Change Drone Parameters
```matlab
cfg.drone.altitude_m = 200;  % Higher altitude
cfg.drone.speed_mps = 25;    % Faster speed
```

#### Enable/Disable Features
```matlab
cfg.emergency.enabled = true;      % Emergency mode
cfg.emergency.auto_detect = true;  % Auto-detect disasters
cfg.ai.enabled = true;             % AI routing
cfg.ai.adaptive_handoff = true;    % Protocol switching
cfg.sat.enabled = true;            % Satellite backhaul
```

### Advanced Configuration

#### Add Custom Protocol
```matlab
cfg.protocols{end+1} = struct(...
    'name', 'mmWave_28GHz', ...
    'freq', 28e9, ...           % 28 GHz
    'txPower_dBm', 30, ...
    'bandwidth_MHz', 400, ...   % 400 MHz bandwidth
    'type', 'terrestrial');
```

#### Adjust Traffic Patterns
```matlab
cfg.traffic.emergency_voice_kbps = 64;   % VoIP bitrate
cfg.traffic.emergency_data_kbps = 128;   % Data bitrate
cfg.traffic.video_kbps = 2500;           % Video bitrate
cfg.traffic.packet_rate_hz = 10;         % Packets per second
```

#### Modify AI Settings
```matlab
cfg.ai.model_path = 'models/predictor_model.mat';
cfg.ai.handoff_threshold = 0.3;  % 30% improvement for handoff
```

---

## 5. Running Simulations

### Quick Simulations

#### Test Run (1 minute)
```matlab
% Edit config_emergency.m
cfg.simTime = 60;  % 1 minute

% Run
main_emergency
```

#### Different Scenarios

**Scenario 1: Urban Emergency**
```matlab
% Delhi, India (high population density)
cfg.locations.start = [28.6139, 77.2090];
cfg.emergency.enabled = true;
main_emergency
```

**Scenario 2: Rural Coverage**
```matlab
% Remote area
cfg.locations.start = [35.0, -110.0];
cfg.drone.altitude_m = 200;  % Higher for more coverage
cfg.sat.enabled = true;      % Rely on satellite
main_emergency
```

**Scenario 3: Disaster Response**
```matlab
% Area with recent earthquake
cfg.locations.start = [37.7749, -122.4194];  % San Francisco
cfg.emergency.enabled = true;
cfg.emergency.auto_detect = true;
main_emergency
```

### Batch Simulations

Run multiple simulations with different parameters:

```matlab
% Create batch script: run_batch.m
locations = {
    [28.6139, 77.2090],   % Delhi
    [37.7749, -122.4194], % San Francisco
    [35.6762, 139.6503],  % Tokyo
    [51.5074, -0.1278]    % London
};

for i = 1:length(locations)
    config_emergency;
    global cfg;
    cfg.locations.start = locations{i};
    fprintf('\n=== Running simulation %d/%d ===\n', i, length(locations));
    main_emergency;
end
```

---

## 6. Troubleshooting

### Common Issues

#### Issue 1: API Connection Fails
**Symptoms:**
```
Error: Unable to fetch weather data
```

**Solutions:**
1. Check internet connection
2. Verify firewall settings
3. Try different network
4. Check API status: https://status.open-meteo.com

#### Issue 2: ML Model Not Found
**Symptoms:**
```
⚠️  AI Predictor not found, using heuristics
```

**Solutions:**
```matlab
% Train the model
config_emergency;
global cfg;
predictor_train(cfg);

% Should create: models/predictor_model.mat
```

#### Issue 3: Simulation Runs Slowly
**Symptoms:**
- Takes >10 minutes to complete
- MATLAB becomes unresponsive

**Solutions:**
```matlab
% Reduce simulation time
cfg.simTime = 300;  % 5 minutes

% Increase time step
cfg.dt = 2.0;  % 2-second steps

% Reduce logging frequency
cfg.log.save_interval = 20;  % Log every 20 steps
```

#### Issue 4: Out of Memory
**Symptoms:**
```
Error: Out of memory
```

**Solutions:**
```matlab
% Clear workspace
clear all; close all; clc;

% Reduce simulation time
cfg.simTime = 300;

% Disable detailed logging
cfg.log.detailed = false;
```

#### Issue 5: Plots Not Generated
**Symptoms:**
- No PNG files in results/

**Solutions:**
```matlab
% Check results directory exists
if ~exist('results', 'dir')
    mkdir('results');
end

% Enable figure saving
cfg.saveFigures = true;

% Run plot generation manually
generate_emergency_plots(dronePositions, allMetrics, ...
    routingDecisions, performance, events, cfg);
```

### Debug Mode

Enable verbose output:
```matlab
% Edit config_emergency.m
cfg.log.detailed = true;
cfg.visualizeEvery = 1;  % Visualize every step (slow!)

% Add breakpoints in code
dbstop if error

% Run simulation
main_emergency
```

### Getting Help

1. **Check Documentation**:
   - README.md
   - FILE_DESCRIPTIONS.md
   - Code comments

2. **Search Issues**:
   - GitHub Issues: https://github.com/priyamganguli/drone-emergency-gateway/issues

3. **Ask for Help**:
   - Open new GitHub Issue
   - Include error messages
   - Describe what you tried

---

## 7. Advanced Setup

### Training Custom ML Model

```matlab
% Load configuration
config_emergency;
global cfg;

% Train with more samples (takes longer)
% Edit predictor_train.m:
% num_samples = 20000;  % Instead of 10000

% Train model
predictor_train(cfg);

% Model saved to: models/predictor_model.mat
```

### Parallel Processing

Speed up training with Parallel Computing Toolbox:

```matlab
% Check if toolbox available
ver('parallel')

% Enable parallel pool
parpool('local', 4);  % Use 4 cores

% Train model (will use parallel processing)
predictor_train(cfg);

% Close pool when done
delete(gcp('nocreate'));
```

### Custom Visualization

Create your own plots:

```matlab
% Load simulation data
load('logs/simulation_YYYYMMDD_HHMMSS.mat');

% Extract data
times = [log_data.entries.time];
protocols = {log_data.entries.protocol};

% Create custom plot
figure;
plot(times, ...);
title('My Custom Plot');
saveas(gcf, 'results/custom_plot.png');
```

### Integration with Other Tools

#### Export to Python
```matlab
% Save data for Python analysis
data = struct();
data.times = times;
data.metrics = metrics;
save('export_data.mat', 'data', '-v7');

% In Python:
# import scipy.io
# data = scipy.io.loadmat('export_data.mat')
```

#### Export to CSV
```matlab
% Convert log to CSV
T = struct2table(log_data.entries);
writetable(T, 'simulation_data.csv');
```

---

## 🎓 Next Steps

After successful setup:

1. **Explore Different Scenarios**
   - Try different locations
   - Vary drone parameters
   - Test emergency vs normal mode

2. **Analyze Results**
   - Compare protocol performance
   - Study AI routing decisions
   - Evaluate emergency prioritization

3. **Customize System**
   - Add new protocols
   - Modify AI scoring
   - Integrate new APIs

4. **Contribute**
   - Report bugs
   - Suggest features
   - Submit improvements

---

## 📞 Support

- **Documentation**: README.md, FILE_DESCRIPTIONS.md
- **Issues**: https://github.com/priyamganguli/drone-emergency-gateway/issues
- **Discussions**: https://github.com/priyamganguli/drone-emergency-gateway/discussions
- **Email**: priyam.ganguli@example.com

---

## ✅ Setup Checklist

- [ ] MATLAB R2019b+ installed
- [ ] Statistics and Machine Learning Toolbox available
- [ ] Project files downloaded
- [ ] `test_apis` runs successfully
- [ ] `main_emergency` completes without errors
- [ ] Results generated in logs/ and results/
- [ ] Configuration customized for your needs
- [ ] Documentation reviewed

---

**Congratulations! You're ready to use the AI Emergency Communication Gateway!** 🎉

For questions or issues, please open a GitHub Issue or Discussion.
