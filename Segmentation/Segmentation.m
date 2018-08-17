%     Copyright 2012, 2013 Kirill Batmanov
%               2012, 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function parameters = Segmentation(oldParameters)
  parameters = oldParameters;

  PrintMsg(parameters.debugLevel, 0, 'Performing segmentation.');
%   if (parameters.maxThreads > 0) && (strcmp(parameters.interfaceMode, 'interactive') || strcmp(parameters.interfaceMode, 'confirm'))
%     PrintMsg(parameters.debugLevel, 1, 'Parallel computation is enabled, so interactive visualization is disabled...');
%   end
  
  [parameters, backgroundImage] = CompleteParameters(parameters);
  
  for currIm = 1:size(parameters.files.imagesFiles(:), 1)
      clear('snakes');
      PrintMsg(parameters.debugLevel, 1, [ 'Processing image ' num2str(currIm) '...' ]);
      snakes = parameters.segmentation.snakes.initialSnakes;
      [fileSnakes, allSeeds, currentImage] = LoadPreviousSegmentation(parameters, currIm);
      snakes = [snakes fileSnakes];
      currentImage = ComputeIntermediateImages(currentImage, backgroundImage, currIm, parameters);
      
      if ((max(currentImage.brighter(:)) == 0) || (max(currentImage.darker(:)) == 0))
          PrintMsg(parameters.debugLevel, 0, 'Something wrong with transparency detection... Wrong background? Skipping image.');
      else
          PrintMsg(parameters.debugLevel, 4, [ 'Starting with ' num2str(size(snakes(:), 1)) ' snakes supplied by user or loaded from file...' ]);
          allSeeds = [ allSeeds parameters.segmentation.seeding.initialSeeds ];
          [currentImage.segments, snakes, allSeeds] = SegmentOneImage(currentImage, allSeeds, snakes, parameters);
          [segmentsConnectivity, currentImage.connectivity] = SegmentsConnectivity2(currentImage, parameters);
          
          % fluorescence matrix: each row is a fluorescence channel, each
          % column is the value of that channel for the nth segment
          PrintMsg(parameters.debugLevel, 3, 'Computing fluorescence...');
          fluorescence = ComputeFluorescence(currentImage.segments, currIm, parameters);
          PrintMsg(parameters.debugLevel, 4, 'Fluorescence done.');
          segImage = ImageFromSegmentation(currentImage.segments, currentImage.originalClean, snakes);
          ImageShow(segImage, 'Showing segmentation result...', 0, parameters.debugLevel, parameters.interfaceMode);
          fileNames = OutputFileNames(currIm, parameters);
          allSeeds = EncodeSeeds(allSeeds);
          SaveSegmentation(currentImage, segImage, snakes, fluorescence, allSeeds, segmentsConnectivity, fileNames, parameters);
      end 
  end
  
end
