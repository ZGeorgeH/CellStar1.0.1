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


function randSeeds = RandSeeds(howmanytimes, mradius, seeds)
    randSeeds = struct([]);
    for j = 1:howmanytimes
         newSeeds = seeds;
         angles = rand(size(newSeeds)) * 2 * pi;
         radius = rand(size(newSeeds)) * mradius;
         for i = 1:size(seeds(:), 1)
            newSeeds(i).x = newSeeds(i).x + radius(i) * cos(angles(i));
            newSeeds(i).y = newSeeds(i).y + radius(i) * sin(angles(i));
            newSeeds(i).from = [ newSeeds(i).from '_rand' ];
         end
         randSeeds = [ randSeeds newSeeds ];
    end
end