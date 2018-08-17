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


function trackingTruth = LoadGroundTruth(parameters)
%LOADGROUNDTRUTH Loads the ground truth for tracking, if it's allowed
  nFrames = size(parameters.files.imagesFiles(:), 1);   
  trackingTruth(1:nFrames) = struct('connectionsTo', zeros(0,2), 'connectionsFrom', zeros(0,2));

  if parameters.tracking.loadGroundTruth
    gtFile = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'groundTruth.mat');
    if exist(gtFile, 'file')
        tmpVar = CSLoad('trackinggroundtruth', gtFile);
        trackingGroundTruth = tmpVar.trackingGroundTruth;
        if ~isempty(trackingGroundTruth.tracking)
            trackingGroundTruth.tracking(trackingGroundTruth.tracking(:,1) == 0,1) = trackingGroundTruth.tracking(trackingGroundTruth.tracking(:,1) == 0,4) - 1;
            trackingGroundTruth.tracking(trackingGroundTruth.tracking(:,4) == 0,4) = trackingGroundTruth.tracking(trackingGroundTruth.tracking(:,4) == 0,1) + 1;
            for i = 1:nFrames
              mentioned1 = trackingGroundTruth.tracking(:,1) == i;
              mentioned2 = trackingGroundTruth.tracking(:,4) == i;

              trackingTruth(i).connectionsTo = trackingGroundTruth.tracking(mentioned2, 5:6);
              trackingTruth(i).connectionsFrom = trackingGroundTruth.tracking(mentioned1, 2:3);
            end
        end
    end
  end

end

