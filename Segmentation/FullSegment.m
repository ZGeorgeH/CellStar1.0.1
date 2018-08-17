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


function fullSegment = FullSegment(star, imSize)
  % given a star with "relative" segment map cropped to a small square, 
  % it builds the full-sized segment of size imSize
  
    fullSegment = zeros(imSize);
    
    r1 = star.inPolygonXY(1);
    c1 = star.inPolygonXY(2);
    r2 = r1 + size(star.inPolygon, 1) - 1;
    c2 = c1 + size(star.inPolygon, 2) - 1;
    
    fullSegment(r1:r2, c1:c2) = star.inPolygon;
end
