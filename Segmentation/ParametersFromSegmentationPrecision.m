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


function parameters = ParametersFromSegmentationPrecision(oldParameters, segmentationPrecision)
  parameters = oldParameters;

  sfrom = @(fstep) max(segmentationPrecision - fstep, 0);
    
  % Number of macro-step for segmentation:
  segmentationPrecision = min(20, segmentationPrecision);
  if segmentationPrecision <= 0
     parameters.segmentation.steps = 0;
  elseif segmentationPrecision <= 6
     parameters.segmentation.steps = 1;
  else
     parameters.segmentation.steps = min(10, segmentationPrecision - 5);
  end
  
  parameters.segmentation.stars.points = 8 + max(segmentationPrecision - 2, 0) * 4;
  
  parameters.segmentation.stars.parameterLearningRingResize = min(max(0, 1 - (segmentationPrecision - 5) / 10.0), 1);
  
  parameters.segmentation.maxFreeBorder = max(0.4, 1 * 16 / max(16, parameters.segmentation.stars.points)) ; % now in ParametersFromSegmentationPrecision()
    
  % 1: seeds from cell border, size(sizeWeight) = 1
  % 2: add seeds from contentexcludingcurrsegments, size(sizeWeight) = 1
  % 3: increase size(sizeWeight) = 2
  % 4: increase steps = 2, add seeds from centroids
  % 5: increase steps = 3
  % 6: increase size(sizeWeight) = 3
  % 7: increase seedsfromCentroidsRandom = 1
  % 8: increase seedsfromcontentExcludingcurrSegmentsRandom = 1
    
  parameters.segmentation.seeding.from.houghTransform                        = (segmentationPrecision == 1);
  parameters.segmentation.seeding.from.cellBorder                            = (segmentationPrecision >= 2);
  parameters.segmentation.seeding.from.cellBorderRandom                      = sfrom(14);         % from segmentationPrecision > 11, with max = 4 if segmentationPrecision = 15
  parameters.segmentation.seeding.from.cellContent                           = (segmentationPrecision >= 11); % from segmentationPrecision >= 2
  parameters.segmentation.seeding.from.cellContentRandom                     = min(4, sfrom(12));  % from segmentationPrecision > 6, with max = 4 if segmentationPrecision > 9
  parameters.segmentation.seeding.from.cellBorderRemovingCurrSegments        = (segmentationPrecision >= 11); % from segmentationPrecision > 11
  parameters.segmentation.seeding.from.cellBorderRemovingCurrSegmentsRandom  = min(4, sfrom(16)); % from segmentationPrecision > 11, with max = 4 if segmentationPrecision = 10
  parameters.segmentation.seeding.from.cellContentRemovingCurrSegments       = (segmentationPrecision >= 7);   % from segmentationPrecision >= 3
  parameters.segmentation.seeding.from.cellContentRemovingCurrSegmentsRandom = min(4, sfrom(12));  % from segmentationPrecision > 4, with max = 4 if segmentationPrecision > 11
  parameters.segmentation.seeding.from.snakesCentroids                       = (segmentationPrecision >= 9);   % from segmentationPrecision >= 4
  parameters.segmentation.seeding.from.snakesCentroidsRandom                 = min(4, sfrom(14));  % from segmentationPrecision > 5, with max = 4 if segmentationPrecision > 9
  parameters.segmentation.seeding.from.mouseclick                            = false;
  parameters.segmentation.seeding.from.mouseclickRandom                      = 10;

  parameters.segmentation.stars.step = 0.0067 * max(1, (1 + (15 - segmentationPrecision) / 2 )) ; % in units of "avgCellDiameter"

  if segmentationPrecision <= 9
      sizeWeightMultiplier = 1;
  elseif segmentationPrecision <= 11
      sizeWeightMultiplier = [0.8 1.25];
  elseif segmentationPrecision <= 13
      sizeWeightMultiplier = [0.6 1 1.6];
  elseif segmentationPrecision <= 15
      sizeWeightMultiplier = [0.5 0.8 1.3 2];
  elseif segmentationPrecision <= 17
      sizeWeightMultiplier = [0.35 0.5 0.8 1.3 2 3];
  else
      sizeWeightMultiplier = [0.25 0.35 0.5 0.8 1.3 2 3 5 8];
  end
  parameters.segmentation.stars.sizeWeight = mean(parameters.segmentation.stars.sizeWeight) * sizeWeightMultiplier / mean(sizeWeightMultiplier); % let's preserve the mean of the current sizeWeight
  
  parameters.segmentation.foreground.pickyDetection = (segmentationPrecision > 8); % takes longer...
  
  parameters.tracking.iterations = max(1, segmentationPrecision * 5 - 25);
  
end
