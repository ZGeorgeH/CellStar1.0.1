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


function assignmentCost = TrackingCost2(features1, features2, picSize, parameters)
%TRACKINGCOST2 Computes costs of different assignments of the observations
%between two successive frames in a simple fail-safe way

  scale = parameters.segmentation.avgCellDiameter / 35;

  N1 = size(features1, 1);
  N2 = size(features2, 1);
  Tot = N1 + N2;

  badCost = 10000;
  missedCost = 15;
  weights = [1 25 0]';
  weights = weights / sum(weights) * 26;
  largeSize = 500 / scale^2;

  assignmentCost = zeros(Tot);
  assignmentCost(N1+1:end,N2+1:end) = 0;
  assignmentCost(1:N1, N2+1:end) = (1 - eye(N1)) * badCost + missedCost;
  assignmentCost(N1+1:end, 1:N2) = (1 - eye(N2)) * badCost + missedCost;
  assignmentCost(IsReliable(features1, picSize),N2+1:end) = 40;
  assignmentCost(N1+1:end,IsReliable(features2, picSize)) = 40;

  for f1 = 1:N1
      for f2 = 1:N2
          dist = norm(features1(f1, 1:2) - features2(f2, 1:2)) / scale;
          area1 = features1(f1, 3); area2 = features2(f2, 3);
          areaChange = 1 - min(area1, area2) / max(area1, area2);
          if area1 > largeSize || area2 > largeSize
            ecc1 = features1(f1, 4); ecc2 = features2(f2, 4);
            eccChange = abs(ecc1 - ecc2);
          else
            eccChange = 0;
          end
          
          assignmentCost(f1, f2) = [dist areaChange eccChange] * weights;
      end
  end

end

