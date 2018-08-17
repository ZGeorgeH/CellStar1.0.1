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


function segments2 = LoadSegmentation2(fileName, segmentationResult, segmentsTruth)
%LOADSEGMENTATION2 Loads segmentation for a single frame, given the segmentation result struct

  dets = GetDetections(segmentationResult);
  tags = cellfun(@GetSegmentTag, segmentationResult.snakes)';
  connectivity = segmentationResult.segmentsConnectivity;
  
  segments2 = MakeTrackingStruct();
  segments2.detections = dets{1};
  segments2.tags = tags;
  segments2.fileName = fileName;
  segments2.picSize = size(segmentationResult.segments);
  segments2.truth = segmentsTruth;  
  
  if isempty(connectivity)
      return
  end
  
  neighbors = connectivity.neighbors;
  distance = nan(size(neighbors));
  distance(neighbors) = connectivity.distance(neighbors);
  channelMaxBrightness = nan(size(neighbors));
  if ~isempty(connectivity.channelMaxBrightness)
      channelMaxBrightness(neighbors) = connectivity.channelMaxBrightness(neighbors);
  end

  segments2.neighbors = neighbors;
  segments2.distance = distance;
  segments2.channelMaxBrightness = channelMaxBrightness;
end

function tag = GetSegmentTag(s)
    [isGT, ignoreGT] = StarGroundTruth(s);
    if ~isGT
        tag = -1;
    else
        if ~ignoreGT
            tag = 0;
        else
            tag = 1;
        end
    end
end
