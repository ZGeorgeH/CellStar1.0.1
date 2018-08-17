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


function parents = GetParentCandidates(children, traces, detections, segments, parameters)
%GETPARENTCANDIDATES Computes reasonable parents for given children

scale = parameters.segmentation.avgCellDiameter / 35;
borderDistance = 0;
maturationTime = parameters.lineage.minBuddingDelay;
matureSize = parameters.lineage.minParentSize * 0.25 * parameters.segmentation.avgCellDiameter^2;
minAttachedFrames = max(parameters.lineage.minAttachedFrames, 1);

nCells = size(traces, 1);
starts = zeros(nCells, 1);
for i = 1:nCells
    starts(i) = find(traces(i,:), 1, 'first');
end

picSize = segments(1).picSize;
pointTraces = GetPointTraces(detections, traces);
sizeTraces = GetSizeTraces(detections, traces);
goodCells = GetWellTrackedCells(pointTraces, picSize, borderDistance, minAttachedFrames);

onBorder = pointTraces(:, :, 1) < borderDistance | pointTraces(:, :, 1) > picSize(1) - borderDistance |...
    pointTraces(:, :, 2) < borderDistance | pointTraces(:, :, 2) > picSize(2) - borderDistance;
traces(onBorder) = nan;

nChildren = size(children, 1);
parents = cell(nChildren, 1);
for i = 1:nChildren
  birth = children(i,2);
  parentTraces = goodCells((starts(goodCells(:,1)) < birth - maturationTime) |...
    starts(goodCells(:,1)) == 1 | sizeTraces(goodCells(:,1), birth) >= matureSize ,1);
  
  parentsWhoAreGoodChildren = intersect(parentTraces, children(:,1));
  pwagcBirths = arrayfun(@(p) children(children(:,1)==p,2), parentsWhoAreGoodChildren);
  pwagc1stBud = birth - pwagcBirths;
  badCandidates = parentsWhoAreGoodChildren(pwagc1stBud < maturationTime);
  parentTraces = setdiff(parentTraces, badCandidates);
  
  for t = (0:(minAttachedFrames - 1)) + children(i,2)
      childDetection = traces(children(i,1),t);
      parentTraces = parentTraces(traces(parentTraces, t) ~= 0);

      neighbors = segments(t).neighbors;
      %disp([i t]);
      neighborDetections = find(neighbors(childDetection,:));
      numNeighbors = length(neighborDetections);
      neighborTraces = zeros(numNeighbors, 1);
      for j = 1:numNeighbors
          nt = find(traces(:,t) == neighborDetections(j));
          if length(nt) == 1
              neighborTraces(j) = nt;
          end
      end

      parentTraces = intersect(parentTraces, neighborTraces);
      nParents = numel(parentTraces);

      if nParents == 0
          break;
      end
  end

  parents{i} = parentTraces;
end

end

