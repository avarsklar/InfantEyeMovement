%% -------------------------------------------------
% 1. SETUP
%% -------------------------------------------------
% deletes all varaibles currently stored in MATLAB's workpsace
clear
% clears the command window text
clc

%% -------------------------------------------------
% 2. LOAD AUDIO
%% -------------------------------------------------

% Creates a MIR audio object x

x=miraudio('/Users/avasklar/Documents/MATLAB/ZooMus_100_Performance.wav');
looking=readmatrix('ZooMus_116_step5_looking_data.csv');

% Check sampling rate: How many samples per second
sr = get(x,'Sampling');
% extract the numeric value from the cell
sr = sr{1};
sr


%% -------------------------------------------------
% 3. FRAME AUDIO
%% -------------------------------------------------
% Divides the continuous waveform into overlapping chunks.
% Each frame spans 50 ms
% Each next frame starts 25 ms later
xf = mirframe(x,'Length',.5,'Hop',.5);


%% -------------------------------------------------
% 4. EXTRACT FEATURES (PER FRAME)
%% -------------------------------------------------

% ---- RMS (Loudness) ----
% Compute RMS for each frame
l = mirrms(xf); 
% Extract numeric RMS values
rmsVals = mirgetdata(l);

% ---- Brightness (Spectral Centroid) ----
b = mircentroid(xf);
brightVals = mirgetdata(b);

% ---- Roughness ----
r = mirroughness(xf);
roughVals = mirgetdata(r);

% ---- Spectral Flux ----
spec = mirspectrum(xf);
f = mirflux(spec);
fluxVals = mirgetdata(f);
fluxVals = fluxVals(:);   % force column vector
fluxVals = [0; fluxVals];

% ---- Pitch ----
p = mirpitch(x,'Frame',0.5,0.5);
pitchVals = mirgetdata(p);
pitchVals = pitchVals(1,:);

% ---- Tempo (BPM)----
t = mirtempo(x);
tempoVal = mirgetdata(t);


%% -------------------------------------------------
% 6. BUILD TIME VECTOR
%% -------------------------------------------------

numFrames = length(rmsVals);
times = (0:numFrames-1) * 0.5;
times = times(:);   % make it a column

%% -------------------------------------------------
% 5. VERIFY ALIGNMENT
%% -------------------------------------------------
size(times)
size(rmsVals)
size(brightVals)
size(roughVals)
size(fluxVals)
size(pitchVals)
size(looking)

%% -------------------------------------------------
% 7. PREPARE TABLE FOR EXPORT
%% -------------------------------------------------

% adjust lengths 
min_len=min(length(times), length(looking));

% Convert everything to column vectors
times   = times(:);
rmsVals    = rmsVals(:);
brightVals = brightVals(:);
roughVals  = roughVals(:);
fluxVals   = fluxVals(:);
pitchVals  = pitchVals(:);
looking_binary=looking(:,2);

%trim everything 
times = times(1:min_len);
rmsVals= rmsVals(1:min_len);
brightVals= brightVals(1:min_len);
roughVals = roughVals(1:min_len);
fluxVals = fluxVals(1:min_len);
pitchVals= pitchVals(1:min_len);
looking_binary= looking_binary(1:min_len);




% Create basic table
featureTable = table(times, looking_binary, rmsVals, brightVals, roughVals, fluxVals, pitchVals);
 
% Export CSV
writetable(featureTable,'ZooMus_115_features_raw.csv');