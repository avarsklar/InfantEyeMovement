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

% Extract baby ID from filename
filename = 'ZooMus_116_step5_looking_data.csv';

tokens = regexp(filename, 'ZooMus_(\d+)_', 'tokens');
babyID = str2double(tokens{1}{1});

looking=readmatrix(filename);

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



%% -------------------------------------------------
% 6. BUILD TIME VECTOR
%% -------------------------------------------------

numFrames = length(rmsVals);
times = (0:numFrames-1) * 0.5;
times = times(:);   % make it a column



%% -------------------------------------------------
% 7. PREPARE TABLE FOR EXPORT
%% -------------------------------------------------


% Convert everything to column vectors
times   = times(:);
rmsVals    = rmsVals(:);
brightVals = brightVals(:);
roughVals  = roughVals(:);
fluxVals   = fluxVals(:);
pitchVals  = pitchVals(:);
looking_binary=looking(:,3); %looks at 

% adjust lengths 
min_len = min([length(times), ...
               length(rmsVals), ...
               length(brightVals), ...
               length(roughVals), ...
               length(fluxVals), ...
               length(pitchVals), ...
               length(looking_binary)]);

%trim everything 
times = times(1:min_len);
rmsVals= rmsVals(1:min_len);
brightVals= brightVals(1:min_len);
roughVals = roughVals(1:min_len);
fluxVals = fluxVals(1:min_len);
pitchVals= pitchVals(1:min_len);
looking_binary= looking_binary(1:min_len);

% ------------------------------
% 5-second pre-look averages
% ------------------------------

window_size = 10;   % 10 frames = 5 seconds

look_events = find(looking_binary == 1);

avg_rms = [];
avg_bright = [];
avg_rough = [];
avg_flux = [];
avg_pitch = [];

for i = 1:length(look_events)

    idx = look_events(i);

    if idx > window_size   % make sure enough previous frames exist
        window = (idx - window_size):(idx - 1);

        avg_rms(end+1)    = mean(rmsVals(window));
        avg_bright(end+1) = mean(brightVals(window));
        avg_rough(end+1)  = mean(roughVals(window));
        avg_flux(end+1)   = mean(fluxVals(window));
        avg_pitch(end+1) = mean(pitchVals(window), 'omitnan'); %ignore silence
    end
end

%average total values
overall_rms    = mean(avg_rms);
overall_bright = mean(avg_bright);
overall_rough  = mean(avg_rough);
overall_flux   = mean(avg_flux);
overall_pitch = mean(avg_pitch, 'omitnan'); %ignore silence



eventTable = table(babyID, overall_rms, overall_bright, ...
                   overall_rough, overall_flux, overall_pitch, ...
                   'VariableNames', ...
                   {'Baby','RMS','Brightness','Roughness','Flux','Pitch'});

% Export CSV
writetable(eventTable,'ZooMus_116_look_avgs.csv');