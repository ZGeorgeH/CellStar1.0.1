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


function assignmentCost = TrackingCostLocalized(features1, features2, motions, picSize, parameters)
%TRACKINGCOSTLOCALIZED Computes the tracking cost taking the neighbor movements
%into account

  scale = parameters.segmentation.avgCellDiameter / 35;

  N1 = size(features1, 1);
  N2 = size(features2, 1);
  Tot = N1 + N2;

  if isempty(features1)
      big1 = [];
  else
      big1 = features1(:,3) > 200 / scale^2;
  end

  if isempty(features2)
      big2 = [];
  else
      big2 = features2(:,3) > 200 / scale^2;
  end

  reliable1 = IsReliable(features1, picSize);
  reliable2 = IsReliable(features2, picSize);

  badCost = 10000;
  missedCost = 15;
  weights = [1 30 0]';
  weights = weights / sum(weights) * 31;
  largeSize = 500 / scale^2;
  
  assignmentCost = zeros(Tot);
  assignmentCost(N1+1:end,N2+1:end) = 0;
  assignmentCost(1:N1, N2+1:end) = (1 - eye(N1)) * badCost + missedCost;
  assignmentCost(N1+1:end, 1:N2) = (1 - eye(N2)) * badCost + missedCost;
  assignmentCost(N1+1:end, big2 & reliable2) = assignmentCost(N1+1:end, big2 & reliable2) * 2;
  assignmentCost(big1 & reliable1, N2+1:end) = assignmentCost(big1 & reliable1, N2+1:end) * 2;

  if isempty(features1) || isempty(features2)
      return;
  end

  if exist('knnsearch')
      [neighbors dist] = knnsearch(motions{3}, features1(:, 1:2), 'K', 6);
  else
      [neighbors dist] = KNNSimple(motions{3}, features1(:, 1:2), 'K', 6);
  end
  % Use kNearestNeighbors for Octave, if knnsearch is not implemented
  % available from 
  % http://www.mathworks.com/matlabcentral/fileexchange/15562-k-nearest-neighbors/content/kNearestNeighbors.m
  % [neighbors dist] = kNearestNeighbors(motions{3}, features1(:, 1:2), 6);
  goodNeighbors = dist > 0 & dist < 30 / scale;

  for f1 = 1:N1
      for f2 = 1:N2             
          diff = features2(f2, :) - features1(f1, :);
  %        diff(3:end) = diff(3:end) - globalMotion(3:end);
          move = diff(1:2);
          neighborMoves = motions{2}(neighbors(f1, goodNeighbors(f1, :)), :);
          if ~isempty(neighborMoves)
              % if we don't add 0s to compensated moves, the uncompensated
              % move of the cell will not be taken into account. This means
              % that if there are no neighbors of the cell which stay in
              % the old place, this cell will also not be allowed to stay
              compensatedMoves = repmat(move, size(neighborMoves, 1), 1) - neighborMoves;
  %            compensatedMoves = repmat(move, size(neighborMoves, 1) + 1, 1) - [0 0; neighborMoves];
              distances = compensatedMoves.^2;
              distances = sqrt(distances(:,1) + distances(:,2));
              [~, shortest] = min(distances);
              diff(1:2) = compensatedMoves(shortest, :);
          end

          dist = norm(diff(1:2)) / scale;
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

