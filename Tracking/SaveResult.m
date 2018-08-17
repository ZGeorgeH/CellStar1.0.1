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


function SaveResult(tracking, name, parameters)
%SAVERESULT Saves tracking and segmentation in a single file for benchmarks
%or other processing

% File format:
%	Header line(required but to be ignored): 
%       Frame_number, Cell_number, Cell_colour, Position_X, Position_Y, Unique_cell_number
%	Line for every cell:
%		<frame_number>, 
%       <cell_number = segment number>,
%       <segment_gt_flag = -1 if no ground truth, 0 if ground truth, 1 if disabled ground truth>,
%       <center_position_x = centroid x>,
%       <center_position_y = centroid y>,
%       <unique_cell_number = tracking label>

  points = GetPointTraces({tracking.segments.detections}, tracking.traces);
  tags = GetTagTraces({tracking.segments.tags}, tracking.traces);
  rows = nnz(~isnan(points(:,:,1)));
  data = zeros(rows, 6);
  nFrames = size(tracking.traces, 2);
  filled = 0;
  for f = 1:nFrames
    present = find(~isnan(points(:,f,1)));
    nPresent = numel(present);
    data(filled + (1:nPresent),:) = [repmat(f, nPresent, 1) (1:nPresent)' tags(present,f) points(present,f,1) points(present,f,2) present];
    filled = filled + nPresent;
  end
  
  fileName = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, name);
  dlmwrite(fileName, 'Frame_number, Cell_number, Cell_colour, Position_X, Position_Y, Unique_cell_number', '');  
  dlmwrite(fileName, data, '-append');

end



function tagTraces = GetTagTraces(tags, traces)
    %GETPOINTTRACES Computes the traces of tags of segments

    nFrames = numel(tags);
    nTracked = size(traces, 1);
    tagTraces = nan(nTracked, nFrames);

    for i = 1:nFrames
        tracked = traces(:,i) ~= 0;
        if ~isempty(tags{i})
            tagTraces(tracked,i) = tags{i}(traces(tracked,i));
        end
    end

end

