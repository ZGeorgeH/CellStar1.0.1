%     Copyright 2012, 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function segImage = ImageFromSegmentation(segments, baseImage, snakes)
    if isempty(segments)
        segImage = baseImage;
        return;
    end
    if isempty(baseImage)
        baseImage = zeros(size(segments));
    end
    
    nsegs = max(segments(:));
    
    baseImage = repmat(baseImage, [1 1 3]);
    if nsegs == 0
        segImage = baseImage;
        return
    end
    
    transparency = repmat(segments == 0, [1 1 3]);
    
    white = nsegs + 1;
    almostblack = nsegs + 2;
    black = nsegs + 3;
   
    borders = false(size(segments));
    borders(2:end, 1:end) = segments(1:end-1, 1:end) ~= segments(2:end, 1:end);
    borders(1:end, 2:end) = borders(1:end, 2:end) | segments(1:end, 1:end-1) ~= segments(1:end, 2:end);
    
    for i = 1:nsegs
      cx(i) = round(snakes{i}.segmentProps.centroidX);
      cy(i) = round(snakes{i}.segmentProps.centroidY);
    end
    clinidx = sub2ind(size(segments), cy, cx);
    centroidsIm1 = false(size(segments));
    centroidsIm1(clinidx) = true;
    centroidsIm2 = ImageDilate(centroidsIm1, 2);
%     centroidsIm3 = ImageDilate(centroidsIm2, 2);
%     segments(logical(centroidsIm3)) = almostblack;
%     segments(logical(centroidsIm2)) = white;

    segments(logical(centroidsIm2)) = almostblack;
    segments(borders) = almostblack;
    segments(centroidsIm1) = white;
    
    cmap = hot(double(nsegs + round(nsegs * 0.5) + 3));
    cmap = cmap(round(nsegs * 0.5)+1:end, :);
    cmap(white, :) = [1 1 1];
    cmap(almostblack, :) = [0.001 0.001 0.001];
    cmap(black, :) = [0 0 0];
    for i = 1:nsegs
        [isgt, ignoregt] = StarGroundTruth(snakes{i});
        if isgt
            if ignoregt
                greenColor = 0.6;
            else
                greenColor = 1;
            end
            cmap(i, :) = [0.001 greenColor 0.001];
        end
    end
    
    segments(segments == 0) = black;
    segImage = ind2rgb(segments - 1, cmap);
    segImage(transparency) = baseImage(transparency);
    
    % it is possible to regulate transparency with a parameter here
    % segImage(~transparency) = 0.75 * segImage(~transparency) + 0.25 * baseImage(~transparency);
end