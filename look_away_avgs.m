%% -------------------------------------------------
% 1. SETUP
%% -------------------------------------------------

clear
clc

%% -------------------------------------------------
% 2. DEFINE FILE LOCATIONS
%% -------------------------------------------------

audioFolder = '/Users/avasklar/Library/CloudStorage/GoogleDrive-ars038@bucknell.edu/.shortcut-targets-by-id/1kOmUoLaENso5UXKur4b56iUdn1RoNMMt/Videos/Converted_files';
lookingFolder = '/Users/avasklar/Library/CloudStorage/GoogleDrive-ars038@bucknell.edu/My Drive/Fellowship/LookingData';

audioFiles = dir(fullfile(audioFolder,'*.wav'));

%% -------------------------------------------------
% BABY → VIDEO MAPPING
%% -------------------------------------------------

map = [
116 115
115 115
117 117
118 118
119 118
120 120
121 120
122 122
123 122
125 125
126 125
127 127
128 127
129 129
130 129
132 132
134 132
133 133
135 133
136 136
137 136
138 138
139 138
140 140
141 140
142 142
143 142
144 144
145 144
146 146
147 146
148 148
149 148

150 150
151 151
152 151
153 153
154 153
155 155
156 155
157 157
158 157
159 159
160 159
161 161
162 162
163 162
164 164
166 166
182 166
167 166
168 168
169 168
170 170
171 170
172 172
173 172
174 174
176 174
183 174
177 177
179 177
180 180
184 180
185 185
186 185
];

%% -------------------------------------------------
% RESULTS TABLE
%% -------------------------------------------------

results = table;

%% -------------------------------------------------
% PROCESS EACH AUDIO FILE
%% -------------------------------------------------

videoIDs = unique(map(:,2));

for v = 1:length(videoIDs)

    videoID = videoIDs(v);

    files = dir(fullfile(audioFolder, sprintf('*%d*.wav', videoID)));

    if isempty(files)
        disp(['Audio not found for video ' num2str(videoID)])
        continue
    end

    audioName = files(1).name;
    audioPath = fullfile(audioFolder, audioName);

    

    disp(['Processing video: ' audioName])

    x = miraudio(audioPath);

    rows = map(map(:,2) == videoID,:);
    babyIDs = rows(:,1);
    %% -------------------------------------------------
    % FRAME AUDIO
    %% -------------------------------------------------

    xf = mirframe(x,'Length',0.5,'Hop',0.5);

    %% -------------------------------------------------
    % EXTRACT FEATURES
    %% -------------------------------------------------

    % RMS
    l = mirrms(xf);
    rmsVals = mirgetdata(l);

    % Brightness
    b = mircentroid(xf);
    brightVals = mirgetdata(b);

    % Roughness
    r = mirroughness(xf);
    roughVals = mirgetdata(r);

    % Flux (optimized)
    f = mirflux(xf);
    fluxVals = mirgetdata(f);
    fluxVals = fluxVals(:);
    fluxVals = [0; fluxVals];

    % Pitch
    p = mirpitch(x,'Frame',0.5,0.5);
    pitchVals = mirgetdata(p);
    pitchVals = pitchVals(1,:);

    % Tempo
    t = mirtempo(x);
    tempoVals = mirgetdata(t);
    tempoVals = tempoVals(:);

    %% -------------------------------------------------
    % TIME VECTOR
    %% -------------------------------------------------

    numFrames = length(rmsVals);
    times = (0:numFrames-1)*0.5;
    times = times(:);

    %% -------------------------------------------------
    % PROCESS EACH BABY
    %% -------------------------------------------------

    for k = 1:length(babyIDs)

        babyID = babyIDs(k);

        disp(['   Baby: ' num2str(babyID)])

        %% LOAD LOOKING ONSET/OFFSET DATA

        fname = sprintf('ZooMus_%d.csv',babyID);
        filepath = fullfile(lookingFolder,fname);

        data = readtable(filepath);

        

        min_len = min([length(times), ...
               length(rmsVals), ...
               length(brightVals), ...
               length(roughVals), ...
               length(fluxVals), ...
               length(pitchVals)]);

        rmsVals2 = rmsVals(1:min_len);
        brightVals2 = brightVals(1:min_len);
        roughVals2 = roughVals(1:min_len);
        fluxVals2 = fluxVals(1:min_len);
        pitchVals2 = pitchVals(1:min_len);
        

        rmsVals2 = rmsVals2(:);
        brightVals2 = brightVals2(:);
        roughVals2 = roughVals2(:);
        fluxVals2 = fluxVals2(:);
        pitchVals2 = pitchVals2(:);
        

        

        %% -------------------------------------------------
        % PRE-LOOK WINDOWS (SIMPLE VERSION)
        %% -------------------------------------------------
        
        window_size = 10;
        
        offset_frames = round(data.Offset_ms / 500) + 1;
        offset_frames = offset_frames(offset_frames > 1);
        
        disp('Number of offset events:')
        disp(length(offset_frames))
        disp('Offset frames:')
        disp(offset_frames)
        
        avg_rms = [];
        avg_bright = [];
        avg_rough = [];
        avg_flux = [];
        avg_pitch = [];
        avg_tempo = [];
        
        for i = 1:length(offset_frames)
        
            frame = offset_frames(i);
            disp(frame)
            disp(min_len)
            
        
            if frame > 1 && frame <= min_len
        
                start_idx = max(1, frame - window_size);
                window = start_idx : frame - 1;
        
                avg_rms(end+1)     = mean(rmsVals2(window), 'omitnan');
                avg_bright(end+1)  = mean(brightVals2(window), 'omitnan');
                avg_rough(end+1)   = mean(roughVals2(window), 'omitnan');
                avg_flux(end+1)    = mean(fluxVals2(window), 'omitnan');
                avg_pitch(end+1)   = mean(pitchVals2(window), 'omitnan');
                avg_tempo(end+1) = tempoVals(1);
        
            end
        end
        %% OVERALL AVERAGES

        overall_rms = mean(avg_rms, 'omitnan');
        overall_bright = mean(avg_bright, 'omitnan');
        overall_rough = mean(avg_rough, 'omitnan');
        overall_flux = mean(avg_flux, 'omitnan');
        overall_pitch = mean(avg_pitch, 'omitnan');
        overall_tempo = mean(avg_tempo, 'omitnan');

        %% STORE RESULT

        eventTable = table(videoID, babyID, overall_rms, overall_bright, ...
                           overall_rough, overall_flux, overall_pitch, ...
                           overall_tempo, ...
                           'VariableNames', ...
                           {'Video','Baby','RMS','Brightness','Roughness','Flux','Pitch','Tempo'});

        results = [results; eventTable];

    end

    clear x xf l b r f p t

end

%% -------------------------------------------------
% EXPORT FINAL DATASET
%% -------------------------------------------------

writetable(results,'ZooMus_ALL_look_away_avgs.csv')