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


function fPolar = GetPolarTransform(starsParameters, avgCellDiameter, debugLevel)
    % FIXME: global + threads does not work well for octave
    persistent fromPolar;

    N =                starsParameters.points;
    distance =         starsParameters.maxSize * avgCellDiameter;
    step =             max(starsParameters.step * avgCellDiameter, 0.2);% not less than a fifth of pixel length

    steps = 1 + int16 (round ((distance + 2) / step));
    maxR = min(1 + int16 (round ((distance) / step)), steps - 1);
    R = double (1:steps)' * step;
    t = linspace (0,2*pi,N+1);
    t = t(1:end-1);

    if (isempty(fromPolar)) || (length(R) ~= size(fromPolar.x, 1)) || (length(t) ~= size(fromPolar.x, 2))
    
        PrintMsg(debugLevel, 3, 'StarMultiVect: initializing polar coordinates transforms');
        % compute the transform from polar coordinates to cartesian
        sint = repmat (sin(t), [length(R) 1]);
        cost = repmat (cos(t), [length(R) 1]);
        RR = repmat (R, [1 length(t)]);
        fromPolar.N = N;
        fromPolar.distance = distance;
        fromPolar.step = step;
        fromPolar.steps = steps;
        fromPolar.maxR = maxR;
        fromPolar.R = R;
        fromPolar.t = t;
        fromPolar.x = RR .* cost;
        fromPolar.y = RR .* sint;

        % toPolar
        halfedge = ceil(fromPolar.R(end) + 2);
        center = halfedge + 1;
        edge = center + halfedge;
        
        fromPolar.halfedge = halfedge;
        fromPolar.center = center;
        fromPolar.edge = edge;
        
        dotvoronoi = zeros(edge);

        px = center + fromPolar.x;
        py = center + fromPolar.y;
        index = sub2ind([edge edge], round(py(:)), round(px(:)));
        dotvoronoi(index) = (1:numel(px))';

        for i = 1:center
            ndv = imdilate(dotvoronoi, ones(3));
            mask = (dotvoronoi == 0) & (ndv ~= 0);
            dotvoronoi(mask) = ndv(mask);
        end
        c = BuildShape(halfedge, 'circle');
        dotvoronoi(~c) = 0;
        dotvoronoi(center, center) = 0;

        toPolar = cell(size(index));

        for a = 1:length(fromPolar.t)
            mask = zeros(edge);
            for r = 1:length(fromPolar.R)
                idx = sub2ind(size(px), r, a);
                mask(dotvoronoi == idx) = 1;
                toPolar{idx} = find(mask)';
            end
        end

        fromPolar.dotvoronoi = dotvoronoi;
        fromPolar.toPolar = toPolar;
    end

    fPolar = fromPolar;
end
