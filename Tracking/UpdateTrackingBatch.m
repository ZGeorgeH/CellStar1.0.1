%     Copyright 2013 Kirill Batmanov
%               2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function tracking = UpdateTrackingBatch(tracking, frames, parameters)
%UPDATETRACKINGBATCH Updates the tracking with for the given frames. Frames
%is a logical array indicating which frames have to be updated. The
%segmentation will be loaded from disk.

%   frames = find(frames(:));
  frames = frames(:);
  nFrames = numel(tracking.segments);
  transitions = union(frames(frames < nFrames), frames(frames > 1) - 1);
  
  trackingTruth = LoadGroundTruth(parameters);
  
  extentedFrames = union(union(frames, frames(frames > 1) - 1), frames(frames < nFrames) + 1);

  for f = extentedFrames(:)'
    tracking.segments(f) = LoadSegmentation1(f, parameters, trackingTruth(f));  
  end

  assignments = tracking.assignments(transitions);
  costs = tracking.costs(transitions);
  segments = tracking.segments;
  for t = 1:numel(transitions)
    transition = transitions(t);
    [assignments{t} costs{t}] = ComputeTransition(segments, transition, parameters);
  end
  tracking.assignments(transitions) = assignments;
  % tracking.costs(transitions) = costs;
  tracking.costs(transitions) = cell(numel(transitions), 1);
  
  picSize = segments(1).picSize;

  tracking.traces = FinalizeTracking(tracking.assignments, {tracking.segments.detections}, picSize, parameters);
  
  goodTraces = sum(tracking.traces ~= 0, 2) > parameters.tracking.minTrackLength;
  tracking.traces = tracking.traces(goodTraces,:); 
  tracking.currentTrackingVersion = tracking.currentTrackingVersion + 1;  
end

