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


function segments1 = LoadSegmentation1(frame, parameters, trackingTruth)
%LOADSEGMENTATION1 Loads segmentation for a single frame, given the image file
  
  fileName = parameters.files.imagesFiles{frame};
  fileNames = OutputFileNames(fileName, parameters);
  segmentationFile = fileNames.segmentation;

  if (exist(segmentationFile, 'file') == 2)
      segmentationResult = CSLoad('segmentation', segmentationFile, 'segments', 'segmentsConnectivity', 'snakes');
  else
      segmentationResult.segments = [];
      segmentationResult.segmentsConnectivity = [];
      segmentationResult.snakes = {};
  end
  
  segmentsTruth = struct(...
    'connectionsTo', PointsToSegments(segmentationResult.segments, trackingTruth.connectionsTo),...
    'connectionsFrom', PointsToSegments(segmentationResult.segments, trackingTruth.connectionsFrom));
 
  segments1 = LoadSegmentation2(fileName, segmentationResult, segmentsTruth);
end

function segs = PointsToSegments(segmentation, points)
  segs = zeros(size(points, 1), 1);
  good = points(:,1) > 0;
  if any(good)
      segs(good) = segmentation(sub2ind(size(segmentation),...
          round(points(good,2)), round(points(good,1))));
  end
end
