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


function imd = ImageDilate2(im, radius, varargin)
  if ~isempty(varargin)
      shape = varargin{1};
  else
      shape = 'circle';
  end
  imd = zeros(size(im));
  z = BuildShape(radius, shape);
  [~, c1] = find(im, 1, 'first');
  [~, c2] = find(im, 1, 'last');
  [~, r1] = find(im', 1, 'first');
  [~, r2] = find(im', 1, 'last');
  if min(size(c1)) > 0
      c1 = max(1, c1 - radius*2 - 2);
      r1 = max(1, r1 - radius*2 - 2);
      c2 = min(size(im, 2), c2 + radius*2 + 2);
      r2 = min(size(im, 1), r2 + radius*2 + 2);
      imred =  im(int16(r1:r2), int16(c1:c2));
      imdred = imdilate(double(imred), double(z));
      imd(int16(r1:r2), int16(c1:c2)) = imdred;
  end
end
