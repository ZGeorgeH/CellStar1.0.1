%     Copyright 2012, 2013, 2014 Kirill Batmanov
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


function SaveTracking(tracking, parents, parameters)
  
  disp('Saving the tracking');

  trackingFolder = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder);

  if ~exist(trackingFolder, 'file')
      mkdir(trackingFolder);
  end

  nFrames = size(tracking.traces, 2);    

  %h = findobj('name', 'Tracking');
  %if(isempty(h))
  %  figure('name', 'Tracking', 'Visible', 'off');
  %end
  
  traces = tracking.traces;
  
  parfor i = 1:nFrames
    TrackingPic(traces, i, parents, parameters, [], true, true, []);
  end
  
  CSSave(fullfile(trackingFolder, 'tracking.mat'), 'tracking');
end