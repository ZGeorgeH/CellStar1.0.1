%     Copyright 2014, 2015 Cristian Versari
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

function compressedSeeds = EncodeSeeds(seeds)
    % This is done to reduce memory consumption.
    compressedSeeds = zeros([3 length(seeds)]);
    for i = length(seeds):-1:1
        compressedSeeds(3, i) = EncodeDecodeSeedOrigin(seeds(i).from);
        compressedSeeds(2, i) = seeds(i).y;
        compressedSeeds(1, i) = seeds(i).x;
    end
end
