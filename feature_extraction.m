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
x = miraudio('/Users/ibrahimtahir/Desktop/DCDS_Infants_Attention_Project/Video Data/ZooMus_115_Performance.wav');

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
xf = mirframe(x,'Length',0.05,'Hop',0.025);


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


%% -------------------------------------------------
% 5. VERIFY ALIGNMENT
%% -------------------------------------------------
length(rmsVals)
length(brightVals)
length(roughVals)


%% -------------------------------------------------
% 6. BUILD TIME VECTOR
%% -------------------------------------------------

% Total number of frames
% Count how may RMS values exist
numFrames = length(rmsVals);
numFrames

%Total number of samples in audio
waveform = mirgetdata(x);
totalSamples = length(waveform);
totalSamples

% Compute hop size in samples
hopSamples = totalSamples / numFrames;
 
% Convert hop to seconds
hopSeconds = hopSamples / sr;


% Create time vector
times = (0:numFrames-1) * hopSeconds;

% Convert to milliseconds (for Python later)
times_ms = times * 1000;

%% -------------------------------------------------
% 7. PREPARE TABLE FOR EXPORT
%% -------------------------------------------------

% Convert everything to column vectors
times_ms   = times_ms';
rmsVals    = rmsVals';
brightVals = brightVals';
roughVals  = roughVals';


% Create table
featureTable = table(times_ms, rmsVals, brightVals, roughVals);
 
% Export CSV
writetable(featureTable,'ZooMus_115_features_raw.csv');
 
% % Plot RMS over time
% figure;
% plot(times, values);
% xlabel('Time (seconds)');
% ylabel('RMS');
% title('Frame-based RMS over time');
