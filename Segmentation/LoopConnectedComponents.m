%     Copyright 2012, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [c, init, fin] = LoopConnectedComponents(v)
  c = zeros([0 0]);
  init = zeros([0 0]);
  fin = zeros([0 0]);
  if (sum(v(:)) > 0)
      c(1) = 0;
      fin(1) = 1;
      current = 1;
      for i=1:size(v(:), 1)
        if v(i)
          c(current) = c(current) + 1;
          fin(current) = i;
        else
            if (c(current) ~= 0)
                current = current + 1;
                c(current) = 0;
                fin(current) = i;
            end
        end
      end
      if (size(c(:), 1) > 1)
          if (c(end) == 0)
              c = c(1:end-1);
              fin = fin(1:end-1);
          end
          if v(1) && v(end)
             c(1) = c(1) + c(end);
             c = c(1:end-1);
             fin = fin(1:end-1);
          end
      end
      init = mod((fin - c), size(v(:), 1)) + 1;
  end
end