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


% From CellSerpent code

function [sx, sy] = ClusterSeeds(sx, sy, threshold)
    % cluster maxima (very inefficiently)
    D = distancematrix(sx, sy);
    while (sum((D(:) < threshold) & (D(:) > 0)) > 0)
        % throw out smallest entry
        ind = find(D);
        Dmin = min(D(ind));
        k = find(D == Dmin,1)-1;
        i = mod(k,length(sx));
        j = round((k-i)/length(sx));
        
        % link
        i = i+1; j = j+1;
        sx(i) = (sx(i) + sx(j))/2;
        sy(i) = (sy(i) + sy(j))/2;
        ind = [1:j-1 j+1:length(sx)]';
        sx = sx(ind);
        sy = sy(ind);
        
        % new distance matrix
        D = distancematrix(sx, sy);
        %imagesc(D); drawnow;
    end
end

function D = distancematrix(sx, sy)
    N = length(sx);    
    Dx = repmat(sx,N,1) - repmat(sx',1,N);
    Dy = repmat(sy,N,1) - repmat(sy',1,N);
    D = sqrt(Dx.*Dx + Dy.*Dy);
end

