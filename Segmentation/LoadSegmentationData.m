%     Copyright 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [segments, snakes, allSeeds, currentImage, fluorescence, segmentsConnectivity] = LoadSegmentationData(fileName, gtFileName, debugLevel)
    segments = [];
    snakes = {};
    allSeeds = struct([]);
    currentImage = struct();
    fluorescence = [];
    segmentsConnectivity = [];

    PrintMsg(debugLevel, 4, [ 'Trying to preload segmentation data from ' fileName ' ...']);
    try
         loadvar = CSLoad('segmentation', fileName);
         if isfield(loadvar, 'snakes')
             snakes = loadvar.snakes;
         end
         if isfield(loadvar, 'intermediateImages')
             currentImage = loadvar.intermediateImages.currentImage;
         end
         if isfield(loadvar, 'segments')
             segments = loadvar.segments;
         end
         if isfield(loadvar, 'allSeeds')
             allSeeds = loadvar.allSeeds;
         end
         if isfield(loadvar, 'fluorescence')
             fluorescence = loadvar.fluorescence;
         end
         if isfield(loadvar, 'segmentsConnectivity')
             segmentsConnectivity = loadvar.segmentsConnectivity;
         end

    %          if parameters.segmentation.transform.clip.apply && ~IsSubField(parameters.segmentation.transform, {'originalImDim'})
    %              parameters.segmentation.transform.originalImDim = loadvar.parameters.segmentation.transform.originalImDim;
    %          end

         clear('loadvar');
         
         PrintMsg(debugLevel, 4, [ 'Loaded ' num2str(size(snakes(:), 1)) ' snakes and ' num2str(max(segments(:))) ' segments.' ]);
    catch
         PrintMsg(debugLevel, 2, [ 'Warning: could not load data from ' fileName ' ...']);
    end

    if isempty(snakes)
        try
            loadvar = CSLoad('segmentationgroundtruth', gtFileName);
            snakes = loadvar.gtSnakes;
        catch
            % do nothing here...
        end
    end

end