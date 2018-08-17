%     Copyright 2013 Kirill Batmanov
%               2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function props = EllipseProps(improps)
    props = struct('MajorAxisLength', {}, 'MinorAxisLength', {}, ...
      'Eccentricity', {}, 'Orientation', {});
    if isempty(improps)
        return
    end
    n = numel(improps);
    props(n) = struct('MajorAxisLength', [], 'MinorAxisLength', [], ...
      'Eccentricity', [], 'Orientation', []);
    
    for i = 1:n
      cm00 = central_moments(improps(i), 0, 0);
      up20 = central_moments(improps(i), 2, 0) / cm00;
      up02 = central_moments(improps(i), 0, 2) / cm00;
      up11 = central_moments(improps(i), 1, 1) / cm00;

      covMat = [up20 up11 ; up11 up02];
      [~, D] = eig( covMat );
      D = sort(diag(D), 'descend');        %# sort cols high to low
      %V = V(:,order);

      %# D(1) = (up20+up02)/2 + sqrt(4*up11^2 + (up20-up02)^2)/2;
      %# D(2) = (up20+up02)/2 - sqrt(4*up11^2 + (up20-up02)^2)/2;

      props(i).MajorAxisLength = 4*sqrt(D(1));
      props(i).MinorAxisLength = 4*sqrt(D(2));
      props(i).Eccentricity = sqrt(1 - D(2)/D(1));
      %# props.Orientation = -atan(V(2,1)/V(1,1)) * (180/pi);      %# sign?
      props(i).Orientation = -atan(2*up11/(up20-up02))/2 * (180/pi);
    end
end

function cmom = central_moments(improps,i,j)
    cmom = ((improps.PixelList(:,1) - improps.Centroid(1)) .^ i)' * ...
      ((improps.PixelList(:,2) - improps.Centroid(2)) .^ j);
end
