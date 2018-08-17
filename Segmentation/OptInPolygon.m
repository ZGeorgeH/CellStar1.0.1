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


function [boolm, smallboolm, xy] = OptInPolygon(maxYX, polygonX, polygonY)
% Limited and optimized version of inpolygon for our needs
  maxY = maxYX(1);
  maxX = maxYX(2);
  x1 = max(1, floor(min(polygonX)));
  x2 = min(maxX, ceil(max(polygonX)));
  y1 = max(1, floor(min(polygonY)));
  y2 = min(maxY, ceil(max(polygonY)));

  x1 = min(x1, maxX);
  y1 = min(y1, maxY);
  x2 = max(1, x2);
  y2 = max(1, y2);
  
  [X, Y] = meshgrid(x1:x2, y1:y2);

  smallboolm = inpolygon(X, Y, polygonX, polygonY);

  boolm = false(maxY, maxX);

  boolm(y1:y2, x1:x2) = smallboolm;
  
  xy = [y1 x1];
end
