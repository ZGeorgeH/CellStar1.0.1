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


function SaveSegmentation(intermediateImages, segImage, snakes, fluorescence, allSeeds, segmentsConnectivity, fileNames, parameters)
  % Save segmentation results
  PrintMsg(parameters.debugLevel, 2, [ num2str(size(snakes(:), 1)) ' snakes settled in this image, saving results...' ]);

%   if (~strcmp(parameters.files.saveIntermediate, 'none'))
%       PrintMsg(parameters.debugLevel, 2, 'Saving intermediate pictures...');
%   end

%   if (strcmp(parameters.files.saveIntermediate, 'pic') || strcmp(parameters.files.saveIntermediate, 'all'))
    ImageSave(double(intermediateImages.foregroundMask), fileNames.images.foregroundMask, parameters.segmentation.transform, parameters.debugLevel);
    ImageSave(intermediateImages.brighterOriginal, fileNames.images.brighterOriginal, parameters.segmentation.transform, parameters.debugLevel);
    ImageSave(intermediateImages.darkerOriginal, fileNames.images.darkerOriginal, parameters.segmentation.transform, parameters.debugLevel);
    ImageSave(intermediateImages.originalClean, fileNames.images.originalClean, parameters.segmentation.transform, parameters.debugLevel);
    if isfield(intermediateImages, 'connectivity')
        ImageSave(double(intermediateImages.connectivity), fileNames.images.connectivity, parameters.segmentation.transform, parameters.debugLevel);
    end
    ImageSave(double(intermediateImages.cellContentMask), fileNames.images.cellContentMask, parameters.segmentation.transform, parameters.debugLevel);
%   end

  ImageSave(segImage, fileNames.images.segmentsColor, parameters.segmentation.transform, parameters.debugLevel);

  segments = intermediateImages.segments;
  
  SaveSegmentationGroundTruth(fileNames.segmentationGroundTruth, snakes);
 
%   save(fullfile(parameters.files.destinationDirectory, 'parameters.mat'), 'parameters', matFormat);

%   if (strcmp(parameters.files.saveIntermediate, 'mat') || strcmp(parameters.files.saveIntermediate, 'all'))
%     save(fileNames.segmentation, 'intermediateImages', 'segments', 'snakes', 'fluorescence', 'allSeeds', 'segmentsConnectivity', 'parameters', matFormat);
%   else
    CSSave(fileNames.segmentation,           'segments', 'snakes', 'fluorescence', 'allSeeds', 'segmentsConnectivity', 'parameters');
%   end
end

