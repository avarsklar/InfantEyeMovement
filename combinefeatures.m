%get data 
wavfile = miraudio('practice_sound.wav');
looking=readmatrix('ZooMus_116_step5_looking_data.csv');

%change samples to seconds
fs = get(wavfile,'Sampling');
fs = fs{1};
duration_seconds = 9017278 / fs;



framesize=.5;
hopsize = framesize; 

%numeric data  energy
energy=mirrms(wavfile,'Frame', framesize, hopsize);
energyCell=get(energy, 'Data');

energyCell = energyCell{1};        % unwrap outer cell
energyValues = energyCell{1};      % unwrap inner cell

energyValues = double(energyValues);
energyValues = energyValues(:);

%pick column
looking_binary=looking(:,2);

%align lengths of videos
minLength=min(length(energyValues),length(looking_binary));

energyValues  = energyValues(1:minLength);
looking_binary = looking_binary(1:minLength);


data=table(energyValues, looking_binary);

mean(energyValues(looking_binary == 1))
mean(energyValues(looking_binary == 0))


X = energyValues;
Y = looking_binary;

mdl = fitglm(X, Y, 'Distribution','binomial');


xVals = linspace(min(X), max(X), 100)';
yPred = predict(mdl, xVals);

plot(X, Y, '.')
hold on
plot(xVals, yPred, 'LineWidth',2)
ylabel('Probability of Looking')
xlabel('Energy')