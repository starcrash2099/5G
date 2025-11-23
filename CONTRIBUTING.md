# Contributing to AI Emergency Communication Gateway

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## 🤝 How to Contribute

### Reporting Bugs
1. Check if the bug has already been reported in [Issues](https://github.com/priyamganguli/drone-emergency-gateway/issues)
2. If not, create a new issue with:
   - Clear title and description
   - Steps to reproduce
   - Expected vs actual behavior
   - MATLAB version and OS
   - Error messages or screenshots

### Suggesting Enhancements
1. Open an issue with tag `enhancement`
2. Describe the feature and its benefits
3. Provide examples of how it would work
4. Discuss implementation approach

### Pull Requests
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 Coding Standards

### MATLAB Style Guide
- Use descriptive variable names (`droneAltitude_m` not `da`)
- Add units to variable names (`speed_mps`, `distance_km`)
- Comment all functions with header block
- Use consistent indentation (4 spaces)
- Keep functions under 200 lines when possible

### Function Header Template
```matlab
function output = my_function(input1, input2)
%% ========================================================================
% MY_FUNCTION - Brief description
% ========================================================================
%
% DESCRIPTION:
%   Detailed description of what the function does
%
% INPUTS:
%   input1 - Description of input1
%   input2 - Description of input2
%
% OUTPUTS:
%   output - Description of output
%
% EXAMPLE:
%   result = my_function(10, 20);
%
% AUTHOR: Your Name
% DATE: YYYY-MM-DD
% ========================================================================

% Implementation here
end
```

### Code Comments
- Add comments for complex logic
- Explain WHY, not just WHAT
- Use section headers for major blocks:
```matlab
%% STEP 1: Initialize Variables
% ========================================================================
```

## 🧪 Testing

### Before Submitting PR
1. Run `test_apis` to verify API connectivity
2. Run `main_emergency` to ensure simulation works
3. Check that visualizations are generated
4. Verify no MATLAB errors or warnings
5. Test with different configurations

### Adding Tests
- Add test scripts to `tests/` directory
- Name tests clearly: `test_ai_routing.m`
- Include expected outputs in comments

## 📚 Documentation

### Update Documentation When:
- Adding new features
- Changing configuration options
- Modifying API calls
- Adding new files

### Documentation Files to Update:
- `README.md` - Main documentation
- `FILE_DESCRIPTIONS.md` - File descriptions
- `QUICKSTART.md` - If setup changes
- Code comments - Always

## 🎯 Priority Areas for Contribution

### High Priority
- [ ] Hardware deployment guide (Raspberry Pi + SDR)
- [ ] Multi-drone coordination
- [ ] Real operator API integration examples
- [ ] Performance optimization
- [ ] Additional ML models (LSTM, deep learning)

### Medium Priority
- [ ] More visualization options
- [ ] Additional traffic types
- [ ] Enhanced weather models
- [ ] Network slicing for 5G
- [ ] Mesh networking between drones

### Low Priority
- [ ] GUI for configuration
- [ ] Real-time dashboard
- [ ] Mobile app integration
- [ ] Cloud deployment scripts

## 🔧 Development Setup

### Prerequisites
```matlab
% Check MATLAB version
ver

% Check required toolboxes
ver('stats')  % Statistics and Machine Learning Toolbox
```

### Initial Setup
```bash
git clone https://github.com/priyamganguli/drone-emergency-gateway.git
cd drone-emergency-gateway
```

```matlab
% In MATLAB
test_apis  % Verify API connectivity
main_emergency  % Run full simulation
```

## 📋 Checklist for Contributors

Before submitting PR, ensure:
- [ ] Code follows MATLAB style guide
- [ ] All functions have header comments
- [ ] Complex logic is commented
- [ ] No hardcoded paths (use relative paths)
- [ ] Tested on your system
- [ ] No new errors or warnings
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] PR description explains changes

## 🐛 Debugging Tips

### Common Issues
1. **API fails**: Check internet, run `test_apis`
2. **ML model missing**: Run `predictor_train(cfg)`
3. **Slow simulation**: Reduce `cfg.simTime` or increase `cfg.dt`
4. **Plot errors**: Check that results/ directory exists

### Debug Mode
```matlab
% Enable verbose logging
cfg.log.detailed = true;

% Add breakpoints in code
dbstop if error
```

## 📞 Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue
- **Security**: Email [priyam.ganguli@example.com]
- **General**: Check README.md and FILE_DESCRIPTIONS.md

## 🎓 Academic Contributions

If using this for research:
1. Cite the project (see README.md)
2. Share your results (open an issue or PR)
3. Contribute improvements back
4. Add your paper to "Used By" section

## 📜 Code of Conduct

### Our Standards
- Be respectful and inclusive
- Welcome newcomers
- Accept constructive criticism
- Focus on what's best for the project
- Show empathy towards others

### Unacceptable Behavior
- Harassment or discrimination
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information
- Unprofessional conduct

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in academic papers (if applicable)

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

## 🚀 Quick Contribution Guide

### Adding a New Protocol
1. Edit `config_emergency.m`:
```matlab
cfg.protocols{end+1} = struct(...
    'name', 'NewProtocol', ...
    'freq', 28e9, ...
    'txPower_dBm', 30, ...
    'bandwidth_MHz', 400, ...
    'type', 'terrestrial');
```

2. Update `channel_model_multiprotocol.m` if needed
3. Test with `main_emergency`
4. Update documentation

### Adding a New API
1. Create `get_new_api.m`:
```matlab
function data = get_new_api(lat, lon)
% Fetch data from new API
url = sprintf('https://api.example.com?lat=%.4f&lon=%.4f', lat, lon);
try
    response = webread(url);
    data = parse_response(response);
catch
    warning('API call failed');
    data = [];
end
end
```

2. Add to `test_apis.m`
3. Integrate into `main_emergency.m`
4. Document in README.md

### Improving AI Model
1. Modify `predictor_train.m`:
   - Add more features
   - Try different algorithms
   - Increase training samples
2. Retrain: `predictor_train(cfg)`
3. Test performance improvement
4. Document changes

---

Thank you for contributing! 🎉

**Questions?** Open an issue or discussion on GitHub.
