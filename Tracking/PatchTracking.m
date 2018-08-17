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


function tracking = PatchTracking(tracking, frame, segmentation, segmentsMap, newSegments, parameters)
%PATCHTRACKING Applies a quick fix to the traces. The result is not the
%same as the final tracking

  fileName = parameters.files.imagesFiles{frame};
  truth = struct('connectionsTo', [], 'connectionsFrom', []); % this function doesn't take ground truth into account
  tracking.segments(frame) = LoadSegmentation2(fileName, segmentation, truth);

  nFrames = numel(tracking.segments);
  newTraces = tracking.traces;
  
  deletedSegments = find(segmentsMap == 0);
  if ~isempty(deletedSegments)
    for i = deletedSegments(:)'
      id = find(tracking.traces(:,frame) == i);
      if ~isempty(id)
        if frame < nFrames
          secondHalf = zeros(1, nFrames);
          secondHalf((frame+1):nFrames) = tracking.traces(id,(frame+1):nFrames);
          newTraces = [newTraces; secondHalf];
          newTraces(id,(frame+1):nFrames) = 0;
        end
        newTraces(id,frame) = 0;
      end
    end
  end
  
  keptSegments = find(segmentsMap(:));
  if ~isempty(keptSegments)
    for i = keptSegments(:)'
      id = find(tracking.traces(:,frame) == i);
      if ~isempty(id)
        newTraces(id,frame) = segmentsMap(i);
      end    
    end
  end
  
  % now we add the new segments as single-frame traces
  if ~isempty(newSegments)
    for i = newSegments(:)'
      trace = zeros(1, nFrames);
      trace(frame) = i;
      newTraces = [newTraces; trace];
    end
  end
  
  tracking.traces = newTraces;
  
  % let's see if we can join some traces
  if frame > 1
    tracking = TryJoin(tracking, frame - 1, parameters);
  end
  if frame < nFrames
    tracking = TryJoin(tracking, frame, parameters);
  end
  
  tracking.traces(sum(tracking.traces, 2) == 0, :) = [];

  tracking.currentTrackingVersion = tracking.currentTrackingVersion + 1;  
  
  if ~isempty(setdiff(tracking.traces(:, frame), unique(segmentation.segments(:))))
      disp('ERROR!');
      keyboard
  end
end

function tracking = TryJoin(tracking, frame, parameters)
  lost = find(tracking.traces(:,frame) ~= 0 & tracking.traces(:,frame+1) == 0);
  appeared = find(tracking.traces(:,frame) == 0 & tracking.traces(:,frame+1) ~= 0);
  if isempty(appeared) || isempty(lost)
    return
  end
  
  lostCenters = tracking.segments(frame).detections(tracking.traces(lost,frame),1:2);
  appearedCenters = tracking.segments(frame+1).detections(tracking.traces(appeared,frame+1),1:2);
  tracesToDrop = [];
  for i = 1:size(lostCenters, 1)
    distances = sqrt(sum((appearedCenters - repmat(lostCenters(i,:), size(appearedCenters, 1), 1)) .^ 2, 2));
    [closestDist closestIdx] = min(distances);
    if closestDist < parameters.segmentation.avgCellDiameter / 2
      before = lost(i);
      after = appeared(closestIdx);
      tracking.traces(before,(frame+1):end) = tracking.traces(after,(frame+1):end);
      appeared(closestIdx) = [];
      tracesToDrop = [tracesToDrop after];      
      if isempty(appeared)
        break
      end
      appearedCenters(closestIdx,:) = [];
    end
  end
  
  tracking.traces(tracesToDrop,:) = [];
end