%     Copyright 2014, 2015 Cristian Versari, Kirill Batmanov
%
%     This file is part of CellStar.
%
%     CellStar is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     CellStar is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with CellStar.  If not, see <http://www.gnu.org/licenses/>.

function outputStructure = CSLoad(fileType, fileName, varargin)
    % This function must be used in the place of built-in load() when dealing with
    % .mat (or equivalent) files, in order to get compatibility with
    % structure formats in previous CellStar versions.
    % Parameters:
    % - fileType is a string representing the type of the file.
    % - fileName: the .mat (or equivalent) file name from which variables
    %   are loaded
    % - further parameters: the names of the variables in string format,
    %   exactly as for the load() built-in function. If none is provided,
    %   all the variables in the file are loaded in the outputStructure.
    
    defaultParams = DefaultParameters();
    cellStarVersion = defaultParams.cellStarVersion;
    
    if exist(fileName, 'file')
        try
          if strcmp(defaultParams.hostLanguage, 'octave')
             inputFileStructure = load(fileName);
          else
             inputFileStructure = load(fileName, '-mat');
          end
        catch
           outputStructure = [];
           return
        end
    else
       outputStructure = [];
       return
    end
    %catch
    %    outputStructure = [];
    %    return
    %end
    
    % in the case of missing version in the file
    if (~isfield(inputFileStructure, 'cellStarVersion'))
        inputFileStructure.cellStarVersion = 0;
    end
    
    if (inputFileStructure.cellStarVersion < cellStarVersion)
        disp(' ');
        disp('Trying to update input files to newer CellStar version, I hope you have backups for your data...');
        switch lower(fileType)
            case 'parameters'
                upToDateStructure = UpdateParametersVersion(inputFileStructure, cellStarVersion);
            case 'segmentation'
                upToDateStructure = UpdateSegmentationVersion(inputFileStructure, cellStarVersion);
            case 'segmentationgroundtruth'
                upToDateStructure = UpdateSegmentationGTVersion(inputFileStructure, cellStarVersion);
            case 'tracking'
                upToDateStructure = UpdateTrackingVersion(inputFileStructure, cellStarVersion);
            case 'trackinggroundtruth'
                upToDateStructure = UpdateTrackingGTVersion(inputFileStructure, cellStarVersion);
            case 'session'
                upToDateStructure = UpdateSessionVersion(inputFileStructure, cellStarVersion);
            otherwise
                disp(['Input file type ' fileType ' not (yet?) supported.']);
        end
    else
        if (inputFileStructure.cellStarVersion > cellStarVersion)
            disp('The file cannot be loaded because this version of CellStar seems outdated. Upgrade it!');
            outputStructure = [];
            return
        else
            upToDateStructure = inputFileStructure;
        end
    end
    
    if isempty(varargin)
        fields = fieldnames(upToDateStructure);
    else
        fields = varargin;
    end
    
    for i = 1:length(fields)
        if isfield(upToDateStructure, fields{i})
            outputStructure.(fields{i}) = upToDateStructure.(fields{i});
        end
    end
end

function upToDateStructure = UpdateSegmentationVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;

    if (upToDateStructure.cellStarVersion < 1.001) && (numel(upToDateStructure.segmentsConnectivity) ~= 1)
        
        connectivity = upToDateStructure.segmentsConnectivity;
        
        segmentsConnectivity.reachable = reshape(cat(1, arrayfun(@(x)any(x.reachable), connectivity(:))), size(connectivity));
        segmentsConnectivity.neighbors = reshape(cat(1, arrayfun(@(x)any(x.neighbors), connectivity(:))), size(connectivity));
        segmentsConnectivity.distance = nan(size(connectivity));
        segmentsConnectivity.channelMaxBrightness = nan(size(connectivity));
        if ~isempty(segmentsConnectivity.neighbors)
            segmentsConnectivity.distance(segmentsConnectivity.neighbors) =  cat(1, connectivity(segmentsConnectivity.neighbors).distance);
            segmentsConnectivity.channelMaxBrightness(segmentsConnectivity.neighbors) =  cat(1, connectivity(segmentsConnectivity.neighbors).channelMaxBrightness);
        end
        
        segmentsConnectivity.channel = cell(size(connectivity));
        segmentsConnectivity.channelLength = reshape(cat(1, arrayfun(@(x)~isempty(x.channelLength), connectivity(:))), size(connectivity));
        if ~isempty(connectivity)
            segmentsConnectivity.channel(:) = {connectivity.channel};
            segmentsConnectivity.channelLength(segmentsConnectivity.channelLength) = [connectivity(segmentsConnectivity.channelLength).channelLength];
        end
    
        upToDateStructure.segmentsConnectivity = segmentsConnectivity;
        
        upToDateStructure.cellStarVersion = 1.001;
    end
    
    if (upToDateStructure.cellStarVersion < 1.002)
        if iscell(upToDateStructure.allSeeds) % this is to fix an early bug
          goodSeeds = [];
          for i = 1:numel(upToDateStructure.allSeeds)
            if isfield(upToDateStructure.allSeeds{i}, 'seed')
              goodSeeds = [goodSeeds upToDateStructure.allSeeds{i}.seed];
            else
              goodSeeds = [goodSeeds upToDateStructure.allSeeds{i}];
            end
          end
          upToDateStructure.allSeeds = goodSeeds;
        end
        
        upToDateStructure.allSeeds = EncodeSeeds(upToDateStructure.allSeeds);
        upToDateStructure.cellStarVersion = 1.002;
    end
    
    upToDateStructure.cellStarVersion = cellStarVersion;
end

function upToDateStructure = UpdateSessionVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;

    if ~IsSubField(upToDateStructure, {'session', 'log'})
        upToDateStructure.session.log = {};
    end
        
    upToDateStructure.session.log{end+1, 1} = ...
        ['% Updating session file version from ' num2str(upToDateStructure.cellStarVersion) ' to ' num2str(cellStarVersion) ];
    
    if (upToDateStructure.cellStarVersion < 1.001) && ...
            ~IsSubField(inputFileStructure, {'session', 'parameters', 'files'}) && ...
            IsSubField(inputFileStructure, {'session', 'parameters', 'segmentation', 'files'})
        upToDateStructure.session.parameters.files = upToDateStructure.session.parameters.segmentation.files;
        upToDateStructure.session.parameters.files.addNumericIdToOutputFileNames = upToDateStructure.session.parameters.segmentation.addNumericIdToOutputFileNames;
        upToDateStructure.session.parameters.files.destinationDirectory = upToDateStructure.session.parameters.destinationDirectory;
        upToDateStructure.session.parameters.segmentation.ranking = upToDateStructure.session.parameters.ranking;
    end
    
    disp('Upgrading session version: resetting key bindigs to default...');
    upToDateStructure.session.keys = KeyBindings();
    
    
    upToDateStructure.cellStarVersion = cellStarVersion;
end

function upToDateStructure = UpdateSegmentationGTVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;
    upToDateStructure.cellStarVersion = cellStarVersion;
end

function upToDateStructure = UpdateTrackingVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;
    
    if (upToDateStructure.cellStarVersion < 1.002)
    
        upToDateStructure.tracking.segments = MakeTrackingStruct();
        upToDateStructure.tracking.segments(numel(inputFileStructure.tracking.segments)) = MakeTrackingStruct();

        fields = fieldnames(upToDateStructure.tracking.segments);
        for i = 1:length(fields)
            if isfield(inputFileStructure.tracking.segments, fields{i})
                for j = 1:numel(inputFileStructure.tracking.segments)
                    upToDateStructure.tracking.segments(j).(fields{i}) = ...
                        inputFileStructure.tracking.segments(j).(fields{i});
                end
            end
        end

        if IsSubField(inputFileStructure, {'tracking', 'segments'}) && ...
                ~IsSubField(inputFileStructure, {'tracking', 'segments', 'tags'})
            for i = 1:length(inputFileStructure.tracking.segments)
                upToDateStructure.tracking.segments(i).tags = ...
                    zeros([1 size(inputFileStructure.tracking.segments(i).detections, 1)]);
            end
            upToDateStructure.cellStarVersion = 1.002;
        end
        
        
    end
    
    upToDateStructure.cellStarVersion = cellStarVersion;
end

function upToDateStructure = UpdateTrackingGTVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;
    upToDateStructure.cellStarVersion = cellStarVersion;
end

function upToDateStructure = UpdateParametersVersion(inputFileStructure, cellStarVersion)
    upToDateStructure = inputFileStructure;
    upToDateStructure.cellStarVersion = cellStarVersion;
end
