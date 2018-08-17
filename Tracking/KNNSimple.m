%     Copyright 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [kneighbors distances] = KNNSimple(neighbors, points, k)
        % neighbors: N x D matrix, with N the number of neighbors and D the
        %                   dimension of the vectorial space
        % points: P x D, with P the number of points whose neighbors must
        %             be found and D same as above
        % k: how many neighbors per point must be selected
        
        N = size(neighbors, 1);
        k = min(k, N);
        D = size(neighbors, 2);
        P = size(points, 1);
        assert (D == size(points, 2), 'Wrong dimensions for points');
        differences = repmat(reshape(neighbors, 1, N, D), P, 1, 1) - ...
                              repmat(reshape(points,        P, 1, D), 1, N, 1);
        [distances, kneighbors] = sort(sum(differences.^2,  3), 2);
        distances = sqrt(distances(:, 1:k));
        kneighbors = kneighbors(:, 1:k);
end
