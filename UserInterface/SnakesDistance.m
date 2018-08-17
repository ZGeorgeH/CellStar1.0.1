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


function distances = SnakesDistance(GTsnakes, snakes)
    distances = cellfun(@SnakeDistance, GTsnakes, snakes);
end

function distance = SnakeDistance(GTSnake, snake)
    rmin = min(GTSnake.inPolygonXY(1), snake.inPolygonXY(1));
    cmin = min(GTSnake.inPolygonXY(2), snake.inPolygonXY(2));
    rmax = max(GTSnake.inPolygonXY(1) + size(GTSnake.inPolygon, 1), ...
               snake.inPolygonXY(1) + size(snake.inPolygon, 1));
    cmax = max(GTSnake.inPolygonXY(2) + size(GTSnake.inPolygon, 2), ...
               snake.inPolygonXY(2) + size(snake.inPolygon, 2));
    
    a1 = zeros(rmax - rmin + 1, cmax - cmin + 1);
    a2 = a1;
    
    r1 = GTSnake.inPolygonXY(1) - rmin + 1;
    c1 = GTSnake.inPolygonXY(2) - cmin + 1;
    r2 = snake.inPolygonXY(1) - rmin + 1;
    c2 = snake.inPolygonXY(2) - cmin + 1;
    
    a1(r1:r1+size(GTSnake.inPolygon, 1)-1, ...
       c1:c1+size(GTSnake.inPolygon, 2)-1) = GTSnake.inPolygon;
    a2(r2:r2+size(snake.inPolygon, 1)-1, ...
       c2:c2+size(snake.inPolygon, 2)-1) = snake.inPolygon;
   
    normalizedPixelDifference = nnz(xor(a1, a2)) / nnz(GTSnake.inPolygon);
   
    distance = normalizedPixelDifference;
end
