%     Copyright 2012, 2013 Kirill Batmanov
%     Copyright 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function motions = ComputeDetailedMotion(detections, traces)
%COMPUTEDETAILEDMOTION Stores all motion data available in the traces for
%further processing

nFeatures = size(detections{1}, 2);
nFrames = size(traces, 2);
motions = cell(nFrames - 1, 1);

for i = 1:nFrames-1
    tracked = find(traces(:, i) ~= 0 & traces(:, i + 1) ~= 0);
    
    nTracked = numel(tracked);
    f1 = zeros(nTracked, 2);
    f2 = f1;
    
    for j = 1:nTracked
        f1(j, :) = detections{i}(traces(tracked(j), i), 1:2);
        f2(j, :) = detections{i+1}(traces(tracked(j), i+1), 1:2);        
    end
    
    moves = f2 - f1;
    if false
        ns = createns(f1);
    else
        ns = f1;
    end
    motions{i} = {f1 moves ns};
end

end

