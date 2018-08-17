%     Copyright 2013 Kirill Batmanov
%               2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function tracking = ComputeFullTracking(parameters)
%COMPUTEFULLTRACKING Computes tracking for every frame

  trackingFolder = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder);
  if ~exist(trackingFolder, 'file')
     mkdir(trackingFolder);
  end
  
  tracking = struct();

  disp('Loading segmentation');
  tracking.segments = LoadSegmentation(parameters);
  
  % extend the segmentation with the copies of the last frame
  %tracking.segments(numel(tracking.segments)+(1:parameters.tracking.minTrackLength)) = tracking.segments(end);

  nFrames = numel(tracking.segments);
  nTransitions = nFrames - 1;
  assignments = cell(nTransitions, 1);
  costs = cell(nTransitions, 1);
  disp('Tracking frame ...../.....');
  parfor i = 1:nTransitions
    fprintf([repmat('\b', 1, 12) num2str(i, '%05d') '/' num2str(nTransitions, '%05d') '\n']);
    [assignments{i} costs{i}] = ComputeTransition(tracking.segments, i, parameters);
  end
  
  tracking.assignments = assignments;
  % tracking.costs = costs;
  tracking.costs = cell(numel(assignments), 1);
  
  disp('Finalizing tracking');

  tracking.traces = FinalizeTracking(assignments, {tracking.segments.detections},...
    tracking.segments(1).picSize, parameters);
  
  tracking.currentTrackingVersion = 1;
  versions = zeros(nFrames, 1);
  save(fullfile(trackingFolder, 'versions.mat'), 'versions');
    
  SaveTracking(tracking, [], parameters);
end

