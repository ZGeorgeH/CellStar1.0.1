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


function rankingParams = VectorToRankingParameters(v, oldRankingParams)
    rankingParams = oldRankingParams;
    rankingParams.maxInnerBrightnessWeight  = v(1);
    rankingParams.avgInnerBrightnessWeight  = v(2);
    rankingParams.avgBorderBrightnessWeight = v(3);
    rankingParams.avgInnerDarknessWeight    = v(4);
    rankingParams.logAreaBonus              = v(5);
    rankingParams.stickingWeight            = v(6);
    rankingParams.shift                     = v(7);
end
