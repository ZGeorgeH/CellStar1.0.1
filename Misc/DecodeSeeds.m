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

function seeds = DecodeSeeds(compressedSeeds)
    % gets the n-th seed in the "compressed seed matrix" allSeeds.
    % This is done to reduce memory consumption.
    
    seeds = struct('x', {}, 'y', {}, 'from', {});
    
    for i = size(compressedSeeds, 2):-1:1
        seeds(i).x = compressedSeeds(1, i);
        seeds(i).y = compressedSeeds(2, i);
        seeds(i).from = EncodeDecodeSeedOrigin(compressedSeeds(3, i));
    end
end
