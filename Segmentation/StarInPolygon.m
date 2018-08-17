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


function [boolm, smallboolm, xy] = StarInPolygon(imSize, boundary, polygonX, polygonY, seedX, seedY, fromPolar)
    % more efficient (?) and rough calculation of inpolygon for stars
    
    center = fromPolar.center;
    
    inp = false(size(fromPolar.dotvoronoi));
    
    idx = sub2ind(size(fromPolar.x), boundary, (1:length(fromPolar.t))');
    inp([fromPolar.toPolar{idx}]) = true;
    
    inp(center, center) = true;

    maxY = imSize(1);
    maxX = imSize(2);
    
    x1 = max(1, floor(min(polygonX)));
    x2 = min(maxX, ceil(max(polygonX)));
    y1 = max(1, floor(min(polygonY)));
    y2 = min(maxY, ceil(max(polygonY)));

    x1 = min(x1, maxX);
    y1 = min(y1, maxY);
    x2 = max(1, x2);
    y2 = max(1, y2);
    
    xt = round(center - seedX);
    yt = round(center - seedY);
    
    smallboolm = inp(yt + (y1:y2), xt + (x1:x2));
    
    boolm = false(imSize);
    boolm(y1:y2, x1:x2) = smallboolm;
    xy = [y1 x1];
    
%     if ~any(boolm)
%         disp('This is a bug.');
%         dbstack
%         keyboard
%     end
end
