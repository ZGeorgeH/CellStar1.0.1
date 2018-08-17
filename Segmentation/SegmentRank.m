%     Copyright 2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function r = SegmentRank(segment, rankingParams, avgCellDiameter)
% DEPRECATED

%   Non-linear ranking function
%   r =    rankingParams.maxInnerBrightnessWeight * segment.maxInnerBrightness + ...
%          rankingParams.avgInnerBrightnessWeight * segment.avgInnerBrightness + ...
%          rankingParams.avgBorderBrightnessWeight * ((segment.avgInBorderBrightness - segment.avgOutBorderBrightness) * segment.avgOutBorderBrightness) + ...
%          - rankingParams.avgInnerDarknessWeight * segment.avgInnerDarkness + ...
%          - (rankingParams.logAreaBonus / avgCellDiameter) * log(segment.area) ...   # rankingParams.segmentationStepMalus * segment.segmentationStep ...
%      ;


%   Linear ranking function, easier to optimize
  r =    rankingParams.maxInnerBrightnessWeight * segment.maxInnerBrightness + ...
         rankingParams.avgInnerBrightnessWeight * segment.avgInnerBrightness + ...
         rankingParams.avgBorderBrightnessWeight * (segment.avgInBorderBrightness - segment.avgOutBorderBrightness) + ...
         - rankingParams.avgInnerDarknessWeight * segment.avgInnerDarkness + ...
         - rankingParams.logAreaBonus * log(segment.area^(1/avgCellDiameter)) ...
     ;

end
