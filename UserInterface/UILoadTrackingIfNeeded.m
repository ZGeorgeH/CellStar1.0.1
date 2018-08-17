%     Copyright 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function UILoadTrackingIfNeeded()
   global csui;
   
   parameters = csui.session.parameters;
   
   trackingFile = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'tracking.mat');
   
   if ~isfield(csui, 'trackingBuf') || ~isfield(csui.trackingBuf, 'tracking')
       csui.trackingBuf.tracking = [];
       tmpVar = CSLoad('tracking', trackingFile);
       if isempty(tmpVar)
           csui.trackingBuf.tracking = [];
           PrintMsg(parameters.debugLevel, 1, 'Unable to load tracking...');
       else
           csui.trackingBuf.tracking = tmpVar.tracking;
       end
   end
   
   if ~isfield(csui.trackingBuf, 'groundTruth')
       gtFile = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'groundTruth.mat');
       if exist(gtFile, 'file')
           tmpGtLoad = CSLoad('trackinggroundtruth', gtFile, 'trackingGroundTruth');
           if isfield(tmpGtLoad, 'trackingGroundTruth')
               csui.trackingBuf.groundTruth = tmpGtLoad.trackingGroundTruth.tracking;
           end
           if isempty(tmpGtLoad)
               PrintMsg(parameters.debugLevel, 1, 'Unable to load tracking ground truth...');
           end
       end
   end

   if ~isfield(csui.trackingBuf, 'groundTruth')
       csui.trackingBuf.groundTruth = [];
   end

   if IsSubField(csui, {'trackingBuf', 'tracking', 'traces'}) && ...
            (size(csui.trackingBuf.tracking.traces, 2) ~= length(csui.session.parameters.files.imagesFiles))
        msg = 'Tracking does not correspond to input files: maybe several sessions were created in the same folder? Tracking will be now reset.';
        disp(msg);
        warndlg(msg, 'Loaded tracking is not valid');
        csui.trackingBuf.tracking = [];
        if exist(trackingFile, 'file')
           delete(trackingFile);
        end
        
        % FIXME
        % Code duplication with DeleteTracking and InvalidateTracking
        nFrames = length(csui.session.parameters.files.imagesFiles);
        DeleteImage('tracking', 1:nFrames);
        ClearImageBuffer('tracking', 1:nFrames);
        ClearImageBuffer('trackingMasked', 1:nFrames);
end
   
end
