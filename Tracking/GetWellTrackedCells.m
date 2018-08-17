%     Copyright 2013 Kirill Batmanov
%               2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function good = GetWellTrackedCells(pointTraces, picSize, borderDistance, minTrackFrames)
%GETWELLTRACKEDCELLS Returns the list of cells for which tracking is considered
%good

  onBorder = pointTraces(:, :, 1) < borderDistance | pointTraces(:, :, 1) > picSize(1) - borderDistance |...
      pointTraces(:, :, 2) < borderDistance | pointTraces(:, :, 2) > picSize(2) - borderDistance;

  tracked = ~isnan(pointTraces(:, :, 1));
  tracked(onBorder) = false;

  goodCells = find(sum(tracked, 2) > minTrackFrames);
  starts = zeros(size(goodCells));
  for i = 1:numel(starts)
      starts(i) = find(tracked(goodCells(i),:), 1, 'first');
  end

  good = [goodCells starts];

end

