%     Copyright 2012, 2015 Cristian Versari
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

function s = BuildShape(size, shape)
% Horrible partial implementation of strel Matlab function, which is
% currently not present in Octave
  s = zeros([0,0]);
  switch shape
      case 'circle'
        [x,y] = meshgrid((-1 * size):size,(-1 * size):size);
        s = (x .* x + y .* y) <= (size * size);
      case 'square'
        s = zeros([size * 2 + 1, size * 2 + 1]) + 1; 
  end
end