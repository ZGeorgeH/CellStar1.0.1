%     Copyright 2008, 2009, 2010, 2011 Kristian Bredies (kristian.bredies@uni-graz.at),
%               2010, 2011 Florian Leitner (florian.leitner@student.tugraz.at)%     
%               2012, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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

function v = FindMaxima(u)
    % returns local maxima
    R = [(u(:,1:end-1) > u(:,2:end)) zeros(size(u,1),1)];
    L = [zeros(size(u,1),1) (u(:,2:end) > u(:,1:end-1))];
    U = [(u(1:end-1,:) > u(2:end,:)); zeros(1,size(u,2))];
    D = [zeros(1,size(u,2)); (u(2:end,:) > u(1:end-1,:))];
    v = double(R.*L.*U.*D);
end
