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


function costs = GetLocalizedPrimitiveTracks(detections, motions, picSize, parameters)
% Returns the frame by frame cell assignment cost matrices
    nFrames = numel(detections);
    nFeatures = size(detections{1}, 2);

    nTransitions = nFrames - 1;
    costs = cell(nTransitions, 1);
    
    %disp('Computing costs...');
    for i = 1:nTransitions  
        costs{i} = TrackingCostLocalized(detections{i}, detections{i+1}, motions{i}, picSize, parameters);
    end
end