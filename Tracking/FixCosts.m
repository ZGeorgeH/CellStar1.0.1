%     Copyright 2013 Kirill Batmanov
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


function costs = FixCosts(costs, nSegmentsInFirstFrame, truth1, truth2)
%FIXCOSTS Sets ground truth in costs for a single transition

  badCost = 10000;
  N1 = nSegmentsInFirstFrame;
  N2 = size(costs, 1) - N1;

  if ~isempty(truth1.connectionsFrom)
    for i = 1:numel(truth1.connectionsFrom)
      if truth1.connectionsFrom(i) == 0
        to = truth2.connectionsTo(i);
        from = N1 + to;
      else
        from = truth1.connectionsFrom(i);
        if truth2.connectionsTo(i) == 0
          to = N2 + from;
        else
          to = truth2.connectionsTo(i);
        end
      end

      costs(from, :) = badCost;
      costs(:, to) = badCost;
      costs(from, to) = 0;
    end
  end

end

