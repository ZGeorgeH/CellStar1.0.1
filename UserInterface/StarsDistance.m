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


function distance = StarsDistance(allGTSnakes, gTSeeds, intermediateImages, parameters, varargin)
  persistent currBestDistance;
  global csui;
  
  distances = StarsVectDistance(allGTSnakes, gTSeeds, intermediateImages, parameters);
  distance = norm(distances) / sqrt(length(distances));
  if ~isempty(varargin)
      if varargin{1} || isempty(currBestDistance)
          currBestDistance = distance;
      elseif (currBestDistance > distance)

          PrintMsg(parameters.debugLevel, 3, ['New best: ' num2str(distance) ]);
          
          s = parameters.segmentation.stars;

          origSW = csui.session.parameters.segmentation.stars.sizeWeight;
          
          s.sizeWeight = OptimizeStarParametersSetSizeWeight(origSW, s.sizeWeight);
          
          csui.session.parameters.segmentation.stars = s;

          currBestDistance = distance;
          
      end
  end
end
