%     Copyright 2013 Kirill Batmanov
%               2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function goodChildren = GetGoodChildren(detections, traces, picSize, parameters)
%GETGOODCHILDREN Gets the list of potential children

  goodChildren = [];

  scale = parameters.segmentation.avgCellDiameter / 35;

  borderDistance = 20 / scale;
  maxNewbornSize = parameters.lineage.maxNewbornSize * 0.25 * parameters.segmentation.avgCellDiameter^2;
  maxChildSize   = parameters.lineage.maxChildSize   * 0.25 * parameters.segmentation.avgCellDiameter^2;

  sizeTraces = GetSizeTraces(detections, traces);
  pointTraces = GetPointTraces(detections, traces);
  minTrackFrames = max(parameters.lineage.minAttachedFrames, 1);
  children = GetWellTrackedCells(pointTraces, picSize, borderDistance, minTrackFrames);

  nCells = size(traces, 1);
  starts = zeros(nCells, 1);
  for i = 1:nCells
      starts(i) = find(~isnan(sizeTraces(i,:)), 1, 'first');
  end

  if isempty(children)
      return;
  end
  
  % remove the children who were not tracked well from the moment of their
  % appearance
  children = children(children(:, 2) == starts(children(:,1)), :);

  onBorder = pointTraces(:, :, 1) < borderDistance | pointTraces(:, :, 1) > picSize(1) - borderDistance |...
      pointTraces(:, :, 2) < borderDistance | pointTraces(:, :, 2) > picSize(2) - borderDistance;
  sizeTraces(onBorder) = nan;
  traceLength = size(traces, 2);
  nChildren = size(children, 1);
  sizesAligned = nan(nChildren, traceLength);
  for i = 1:nChildren
      sizesAligned(i,1:(traceLength - children(i,2) + 1)) = sizeTraces(children(i,1),children(i,2):end);
  end
  
  if isempty(children)
      return;
  end

  iGoodChildren = children(:,2) > 1 & min(~isnan(sizesAligned(:,1:minTrackFrames)),[], 2) &...
      max(sizesAligned(:,1:minTrackFrames), [], 2) < maxChildSize & ...
      sizesAligned(:,1) < maxNewbornSize;

  goodChildren = children(iGoodChildren,:);

end
