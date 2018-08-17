%     Copyright 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [segments, snakes, allSeeds] = SegmentOneImage(currentImage, oldAllSeeds, oldSnakes, parameters)
  allSeeds = oldAllSeeds;
  snakes = oldSnakes;

%   if (~isfield(currentImage, { 'segments' }) || (size(parameters.segmentation.snakes.initialSnakes(:), 1) > 0))
  [snakes, currentImage.segments] = FilterSnakes(currentImage, parameters, snakes);
%   end

  for currentStep = 1:parameters.segmentation.steps
    PrintMsg(parameters.debugLevel, 2, [ 'Performing segmentation step ' num2str(currentStep) '...' ]);
    newSeeds = FindSeeds(currentImage, parameters, snakes, allSeeds, currentStep);
    if (size(newSeeds(:), 1) > 0)
      allSeeds = [ allSeeds newSeeds ];
      newSnakes = GrowSeeds(newSeeds, currentImage, parameters);
      [snakes, currentImage.segments] = FilterSnakes(currentImage, parameters, [snakes newSnakes]);
      PrintMsg(parameters.debugLevel, 3, [ num2str(size(snakes(:), 1)) ' snakes settled so far...' ]);
    else
        if currentStep > 1
            PrintMsg(parameters.debugLevel, 2, 'No new seeds, interrupting...');
            break
        end
    end
  end
  
  segments = currentImage.segments;
end
