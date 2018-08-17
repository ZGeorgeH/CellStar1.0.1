%     Copyright 2013, 2014 Kirill Batmanov
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


function [assignments1, costs1] = ...
  ComputeTransition(segments, transition, parameters)
%COMPUTETRANSITION Updates costs and assignments for the specified transition

  picSize = segments(1).picSize;
  costs1 = TrackingCost2(segments(transition).detections, ...
        segments(transition + 1).detections, picSize, parameters);
  costs1 = FixCosts(costs1, size(segments(transition).detections, 1),...
    segments(transition).truth, segments(transition + 1).truth);  
  assignments1 = munkres(costs1);
  for i = 1:parameters.tracking.iterations
    detections = {segments(transition:(transition + 1)).detections};
    traces = FinalizeTracking({assignments1}, detections, picSize, parameters);
    localMotions = ComputeDetailedMotion(detections, traces);
    if iscell(costs1)
        oldCosts(:, :, end+1) = costs1{1};
    else
        oldCosts = costs1;
    end
    costs1 = GetLocalizedPrimitiveTracks(detections, localMotions, picSize, parameters);
    costs1{1} = FixCosts(costs1{1}, size(segments(transition).detections, 1),...
      segments(transition).truth, segments(transition + 1).truth);

    % not really in matrix style...
    epsilon = 0;
    for j = size(oldCosts, 3):-1:1
        anyUpdate(j) = all(all(oldCosts(:, :, j) - costs1{1} <= epsilon));
        if anyUpdate(j)
            break
        end
    end
    
    if any(anyUpdate)
        PrintMsg(parameters.debugLevel, 4, ['No updates to costs w.r.t. iteration ' num2str(find(anyUpdate, 1)) ', breaking tracking loop at iteration ' num2str(i) ' .........................']);
        break
    end
    assignments1 = munkres(costs1{1});
    if (i == parameters.tracking.iterations)
        PrintMsg(parameters.debugLevel, 4, ['Maximum number of iterations reached, breaking tracking loop at iteration ' num2str(i) ' .........................']);
    end
  end
end

