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


function avgCellSize = DetectAvgCellSize(parameters)
    avgCellSize = -1;
    %parameters = oldParameters;

    currImFileName = cell2mat(parameters.files.imagesFiles(1));
    [tmpMatrix, originalImDim] = ReadImage(currImFileName, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
    
    if ~IsSubField(parameters, {'segmentation', 'transform', 'originalImDim'})
        parameters.segmentation.transform.originalImDim = originalImDim;
    end

    [currentImage, ~] = GetImages(ImageNormalize(imresize(tmpMatrix(:,:,1), 2)), parameters);

    tmpParameters = parameters;
    tmpParameters.segmentation.stars.step = parameters.segmentation.stars.step * 2;
    tmpParameters.segmentation.stars.sizeWeight = parameters.segmentation.stars.sizeWeight * 0.5;
    tmpParameters.segmentation.stars.points = 24;
    %tmpParameters = ParametersFromAvgCellDiameter(tmpParameters, 32);
    tmpParameters.segmentation.avgCellDiameter = 32;
    tmpParameters = ParametersFromSegmentationPrecision(tmpParameters, 1);
    %tmpParameters.segmentation.seeding.from.cellBorder = true;
    
    
    steps = round(log2(min(size(currentImage.original))) * 2 - 12);
    
    if parameters.debugLevel >= 2
      fprintf('%d steps', steps);
    end
    for i = 1:steps
      if parameters.debugLevel >= 2
          fprintf('.');
      end
      
      if i > 1
          [currentImage, ~] = GetImages(ImageNormalize(imresize(currentImage.original, 2^-0.5)), parameters);
      end

      allSeeds = struct([]);
      snakes = struct([]);
      
      tmpParameters.segmentation.seeding.from.cellBorder = false;
      tmpParameters.segmentation.seeding.from.houghTransform = true;
      newSeeds = FindSeeds(currentImage, tmpParameters, snakes, allSeeds, 1);
      if min(size(newSeeds)) == 0
        PrintMsg(parameters.debugLevel, 4, 'Could not find seeds with Hough transform, trying from cell border...');
        tmpParameters.segmentation.seeding.from.cellBorder = true;
        tmpParameters.segmentation.seeding.from.houghTransform = false;
        newSeeds = FindSeeds(currentImage, tmpParameters, snakes, allSeeds, 1);
      end 
      
      if min(size(newSeeds)) > 0
          newSnakes = GrowSeeds(newSeeds, currentImage, tmpParameters);

          snakerank = zeros(size(newSnakes));
          for j = 1:size(newSnakes(:))
               oldsp = newSnakes{j};
               snakerank(j) = oldsp.rank;
          end

          bestRank(i) = min(snakerank(:));
          bestSnakeIdx = find(snakerank == min(snakerank));
          bestArea(i) = newSnakes{bestSnakeIdx(1)}.segmentProps.area * 2^(i-3);

          %disp([ 'Max: ' num2str(max(snakerank(:))) ' ' num2str  ] );
      else
          bestRank(i) = 0;
          bestArea(i) = 0;
      end
    end
    if parameters.debugLevel >= 2
      fprintf('\n');
    end
  
%     bestRank
%     bestArea
%     bestArea(bestRank < threshold)

    threshold = min(bestRank) + (max(bestRank) - min(bestRank)) * 0.1;
    selection = bestRank <= threshold;
    mmean = mean(bestArea(selection));
    for i = 1:10
      selection = selection & (bestArea > ((0.25 + 0.5 * i/10) * mmean)) & (bestArea < ((4 - 2.6 * i/10) * mmean));
      if sum(selection(:)) == 0
          break
      end
      mmean = mean(bestArea(selection));
    end
    if sum(selection(:)) == 0
        PrintMsg(parameters.debugLevel, 0, 'Autodetection failed...');
    else
        PrintMsg(parameters.debugLevel, 4, ['Areas: ' num2str(bestArea)]);
        PrintMsg(parameters.debugLevel, 4, ['Ranks: ' num2str(bestRank)]);
        PrintMsg(parameters.debugLevel, 4, ['Selected: ' num2str(selection)]);
        avgCellSize = sqrt(mmean * 1.2 * 4 / pi);
    end
end



function [currentImage, background] = GetImages(image, parameters)
    currentImage.original = image;
    currentImage.originalClean = currentImage.original;
    currentImage.foregroundMask = ones(size(currentImage.original));
    currentImage.cellContentMask = ones(size(currentImage.original));
    background = ones(size(currentImage.original)) .* mean(currentImage.original(:));
    currentImage.cleanBlurred = currentImage.original;
    currentImage.brighter = BackgroundSubtract(currentImage.original, background, 1, parameters.debugLevel, parameters.interfaceMode);
    currentImage.darker = BackgroundSubtract(currentImage.original, background, -1, parameters.debugLevel, parameters.interfaceMode);
    currentImage.segments = zeros(size(currentImage.original));
end




% function avgCellSize = DetectAvgCellSize2(parameters)
%     %avgCellSize = -1;
%     %parameters = oldParameters;
% 
%     currImFileName = cell2mat(parameters.files.imagesFiles(1));
%     tmpMatrix = ReadImage(currImFileName, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
%     images = GetImages(ImageNormalize(tmpMatrix(:,:,1)));
% 
%     %avgCellDiameter = round(2.^(4:.5:log2(min(size(images.currentImage.original)/4))));
%     avgCellDiameter = round(2.^(4:.5:log2(min(size(images.currentImage.original)/4))));
%     
%     tmpParameters = parameters;
%     tmpParameters.segmentation.stars.step = parameters.segmentation.stars.step * 2;
%     tmpParameters.segmentation.stars.sizeWeight = parameters.segmentation.stars.sizeWeight * 0.5;
%     tmpParameters.segmentation.stars.points = 24;
%     
%     
%     if parameters.debugLevel >= 2
%       fprintf('%d steps', size(avgCellDiameter, 2));
%     end
%     for i = 1:size(avgCellDiameter, 2)
%       if parameters.debugLevel >= 2
%           fprintf('.');
%       end
%       %tmpParameters = ParametersFromAvgCellDiameter(tmpParameters, avgCellDiameter(i));
%       tmpParameters.segmentation.avgCellDiameter = avgCellDiameter(i);
%       tmpParameters = ParametersFromSegmentationPrecision(tmpParameters, 1);
% 
%       allSeeds = struct([]);
%       snakes = struct([]);
%       newSeeds = FindSeeds(images, tmpParameters, snakes, allSeeds, 1);
%       %newSnakes = GrowSeeds(newSeeds, images, tmpParameters, 1);
%       
% %       snakerank = zeros(size(newSnakes));
% %       for j = 1:size(newSnakes(:))
% %            oldsp = newSnakes{j};
% %            snakerank(j) = oldsp.rank;
% %       end
% %       
% %       bestRank(i) = min(snakerank(:));
% %       bestSnakeIdx = find(snakerank == min(snakerank));
% %       bestArea(i) = newSnakes{bestSnakeIdx(1)}.segmentProps.area;
%       
%       %disp([ 'Max: ' num2str(max(snakerank(:))) ' ' num2str  ] );
%     end
%     if parameters.debugLevel >= 2
%       fprintf('\n');
%     end
%   
% %     bestRank
% %     bestArea
% %     bestArea(bestRank < threshold)
% 
%     threshold = min(bestRank) + (max(bestRank) - min(bestRank)) * 0.1;
%     avgCellSize = sqrt(mean(bestArea(bestRank < threshold)) * 4 / pi);
%     
% end
