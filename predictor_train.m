function model = predictor_train(cfg)
% create synthetic dataset and train a regression model
N=2500;
dist = rand(N,1)*1.5; % km
rssi = -30 - 18*dist + randn(N,1)*3;
snr = 10 - 4*dist + randn(N,1)*2;
weather = rand(N,1)*0.2;
congest = rand(N,1);
X = [dist, rssi, snr, weather, congest];

% target throughput (Mbps) synth model
y = max(0.02, 8.*exp(-dist/0.9).*(1-0.4*weather).*(1-congest) + randn(N,1)*0.3);

% train ensemble regressor
model = fitrensemble(X,y,'Method','Bag','NumLearningCycles',80);

if ~exist('models','dir')
    mkdir('models');
end
save('models/predictor_model.mat','model','-v7.3');
fprintf('Predictor trained and saved to models/predictor_model.mat\n');
end
