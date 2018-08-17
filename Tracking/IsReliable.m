%     Copyright 2012, 2013 Kirill Batmanov
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


function isReliable = IsReliable(detections, picSize)
%ISRELIABLE Checks if the detection(s) are reliable

  if isempty(detections)
      isReliable = [];
      return;
  end

  centers = detections(:,1:2);
  distancesToBorders = min(min(centers, ...
      repmat(picSize, size(detections, 1), 1) - centers),[],2);
  breakAreas = detections(:,3);
  isReliable = distancesToBorders > 30 & breakAreas > 150;

end

