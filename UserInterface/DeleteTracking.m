%     Copyright 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function DeleteTracking()
   % remove tracking ONLY from disk, not from memory!
   
   global csui;
   % let us make sure that tracking is loaded,
   % otherwise we may delete it before having the last version in memory
   UILoadTrackingIfNeeded();
   parameters = csui.session.parameters;
   trackingFile = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'tracking.mat');
   if exist(trackingFile, 'file')
       delete(trackingFile);
   end
end
