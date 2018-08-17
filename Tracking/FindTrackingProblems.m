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


function problems = FindTrackingProblems(tracking, parameters)
    problems = {};
    
    if isempty(tracking)
        return
    end
    
    maxNewbornSize = 0.25 * parameters.segmentation.avgCellDiameter^2 * parameters.lineage.maxNewbornSize;
    borderDistance = 0.6 * parameters.segmentation.avgCellDiameter;

    sizeTraces = GetSizeTraces({tracking.segments.detections}, tracking.traces);
    pointTraces = int16(GetPointTraces({tracking.segments.detections}, tracking.traces));
    onBorder = pointTraces(:, :, 1) < borderDistance | pointTraces(:, :, 1) > tracking.segments(1).picSize(1) - borderDistance |...
        pointTraces(:, :, 2) < borderDistance | pointTraces(:, :, 2) > tracking.segments(1).picSize(2) - borderDistance;

    nCells = size(tracking.traces, 1);
    nFrames = size(tracking.traces, 2);
    starts = zeros(nCells, 1);
    ends = zeros(nCells, 1);
    for i = 1:numel(starts)
        starts(i) = find(~isnan(sizeTraces(i,:)), 1, 'first');
        ends(i) = find(~isnan(sizeTraces(i,:)), 1, 'last');    
    end

    bigNewborns = zeros(nCells, 1);
    bigLost = zeros(nCells, 1);
    for i = 1:nCells
      bigNewborns(i) = (starts(i) > 1) && (sizeTraces(i, starts(i)) > maxNewbornSize) && ~onBorder(i, starts(i));
      bigLost(i) = (ends(i) < nFrames) && (sizeTraces(i, ends(i)) > maxNewbornSize) && ~onBorder(i, ends(i));
    end

%     disp('Cells which are too large at the time of appearance:');
    for i = find(bigNewborns)'
%       fprintf('%d born on frame %d at %d:%d\n', i, starts(i), pointTraces(i, starts(i), 1), pointTraces(i, starts(i), 2));
      problems{end + 1}.frame = starts(i);
      problems{end}.trace = i;
      problems{end}.type = 'appear';
    end
    
%     disp('Cells which are too large at the time of disappearance:');
    for i = find(bigLost)'
%       fprintf('%d lost on frame %d at %d:%d\n', i, ends(i), pointTraces(i, ends(i), 1), pointTraces(i, ends(i), 2));
      problems{end + 1}.frame = ends(i);
      problems{end}.trace = i;
      problems{end}.type = 'disappear';
    end
    
    goodChildren = GetGoodChildren({tracking.segments.detections}, tracking.traces, tracking.segments(1).picSize, ...
      parameters);
    parents = GetParentCandidates(goodChildren, tracking.traces, {tracking.segments.detections}, ...
      tracking.segments, parameters);
    orphans = cellfun(@numel, parents) == 0;

%     disp('Orphan cells:');
    for i = find(orphans)'
%       fprintf('%d born on frame %d at %d:%d\n', goodChildren(i, 1), goodChildren(i, 2),...
%         pointTraces(goodChildren(i, 1), goodChildren(i, 2), 1), pointTraces(goodChildren(i, 1), goodChildren(i, 2), 2));
        problems{end + 1}.frame = goodChildren(i, 2);
        problems{end}.trace = goodChildren(i, 1);
        problems{end}.type = 'orphan';
    end
    
    traces = cellfun(@(x)x.trace, problems);
    [~, I] = sort(traces);
    problems = problems(I);
    frames = cellfun(@(x)x.frame, problems);
    [~, I] = sort(frames);
    problems = problems(I);
end
