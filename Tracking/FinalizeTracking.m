%     Copyright 2012, 2013 Kirill Batmanov
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


function traces = FinalizeTracking(allAssignments, detections, picSize, parameters)
%FINALIZETRACKING Uses the pairwise assignments computed by the Hungarian
%algorithm to produce the cell tracks

  %disp('Finalizing tracking...');

  nTransitions = size(allAssignments, 1);
  nCells = nTransitions + 1;
  initialCells = size(detections{1}, 1);
  traces = zeros(initialCells, nCells);
  if ~isempty(traces)
      traces(:, 1) = 1:initialCells;
  end

  for i = 1:nTransitions
    [a1 a2] = find(allAssignments{i});
    det1 = size(detections{i}, 1);
    det2 = size(detections{i+1}, 1);
    in1 = a1 <= det1;
    in2 = a2 <= det2;
    tracked = in1 & in2;
    appeared = in2 & ~in1;

    for j = find(tracked)'
        traces(traces(:,i) == a1(j), i+1) = a2(j);
    end

    if ~isempty(a2(appeared))
        traces(end+(1:nnz(appeared)), i+1) = a2(appeared)';
    end
  end
  
  longTraces = sum(traces ~= 0, 2) > parameters.tracking.minTrackLength;
  
  scale = parameters.segmentation.avgCellDiameter / 35;
  borderDistance = 20 / scale;
  pointTraces = GetPointTraces(detections, traces);
  onBorder = pointTraces(:, :, 1) < borderDistance | pointTraces(:, :, 1) > picSize(1) - borderDistance |...
    pointTraces(:, :, 2) < borderDistance | pointTraces(:, :, 2) > picSize(2) - borderDistance;
  
  nCells = size(traces, 1);
  nFrames = size(traces, 2);
  ends = arrayfun(@(i) find(~isnan(pointTraces(i,:,1)), 1, 'last'), (1:nCells)');
  
  endsOnBorder = onBorder(sub2ind(size(onBorder), (1:nCells)', ends));
    
  traces = traces(longTraces | ends == nFrames | endsOnBorder,:);
end

