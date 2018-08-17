%     Copyright 2012, 2013, 2014, 2015 Cristian Versari
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

function snake = CalcSnakeProperties(noPropsSnake, currentImage, rankingParams, avgCellDiameter, fromPolar)
    snake = noPropsSnake;
    
    %[X,Y] = meshgrid(1:size(currentImage.brighter,2), 1:size(currentImage.brighter,1));

    %inSnake = inpolygon(X, Y, snake.x, snake.y);
    %snake.x
    %snake.y
    
    epsilon = 10^-8;
    
    if isempty(fromPolar)
        % Slow, accurate method
        [segment, snake.inPolygon, snake.inPolygonXY] = OptInPolygon(size(currentImage.brighter), snake.x, snake.y);
        
        segmentProps.area = sum(segment(:)) + epsilon;

        approxRadius = sqrt(segmentProps.area / pi);
        borderRadius = max(min(approxRadius, 3), 2);

        outBorder = ImageDilate(segment, borderRadius) - segment;
        inBorder =  ImageDilate(outBorder, borderRadius) & segment;

        outBorderArea = sum(outBorder(:)) + epsilon;
        inBorderArea =  sum(inBorder(:)) + epsilon;
        
    else
        % Fast, rough method
        [segment, snake.inPolygon, snake.inPolygonXY] = ...
            StarInPolygon( ...
               size(currentImage.brighter), ...
               snake.polarCoordinateBoundary, ...
               snake.x, ...
               snake.y, ...
               snake.seed.x, ...
               snake.seed.y, ...
               fromPolar);

        segmentProps.area = sum(segment(:)) + epsilon;

        approxRadius = sqrt(segmentProps.area / pi);
        minR = 0.055 * avgCellDiameter;
        maxR = 0.1 * avgCellDiameter;
        borderRadius = max(min(approxRadius, maxR), minR);
        dilation = round(borderRadius / fromPolar.step);

        dilatedBoundary = min(snake.polarCoordinateBoundary + dilation, length(fromPolar.R));
        erodedBoundary = max(snake.polarCoordinateBoundary - dilation, 1);

        [dilated, ~, ~] = ...
            StarInPolygon( ...
               size(currentImage.brighter), ...
               dilatedBoundary, ...
               snake.x, ...
               snake.y, ...
               snake.seed.x, ...
               snake.seed.y, ...
               fromPolar);

        [eroded, ~, ~] = ...
            StarInPolygon( ...
               size(currentImage.brighter), ...
               erodedBoundary, ...
               snake.x, ...
               snake.y, ...
               snake.seed.x, ...
               snake.seed.y, ...
               fromPolar);

        outBorder = dilated - segment;
        inBorder =  segment - eroded;

        outBorderArea = nnz(outBorder) + epsilon;
        inBorderArea =  nnz(inBorder) + epsilon;
    end
    
    outBorder = logical(outBorder);
    inBorder = logical(inBorder);
    
    tmp = currentImage.originalClean(outBorder);
    segmentProps.avgOutBorderBrightness = sum(tmp(:)) / outBorderArea;
    segmentProps.maxOutBorderBrightness = max(tmp(:));
    tmp = currentImage.originalClean(inBorder);
    segmentProps.avgInBorderBrightness = sum(tmp(:)) / inBorderArea;
    tmp = currentImage.brighter(segment);
    segmentProps.avgInnerBrightness = sum(tmp(:)) / segmentProps.area;
    if ~isempty(tmp)
        segmentProps.maxInnerBrightness = max(tmp(:));
    else
        segmentProps.maxInnerBrightness = 0;
    end

    tmp = currentImage.cellContentMask(segment);
    segmentProps.avgInnerDarkness = sum(tmp(:)) / segmentProps.area;
    segmentProps.centroidX = sum(sum(segment, 1) .* (1:size(segment, 2)))/sum(segment(:));
    segmentProps.centroidY = sum(sum(segment, 2)' .* (1:size(segment, 1)))/sum(segment(:));
%     tmpCentroid = regionprops(segment, 'Centroid', 'Area');
%     if length(tmpCentroid) > 1
%         idx = find([tmpCentroid.Area] == max([tmpCentroid.Area]), 1);
%     else
%         idx = 1;
%     end
%     segmentProps.centroidX = tmpCentroid(idx).Centroid(1);
%     segmentProps.centroidY = tmpCentroid(idx).Centroid(2);    

    segmentProps.rank = SegmentRank(segmentProps, rankingParams, avgCellDiameter);

    snake.segmentProps = segmentProps;
    
    fbEntropy = 0;
    if isfield(snake, 'finalEdgepoints')
        [fb, ~, ~] = LoopConnectedComponents(1 - snake.finalEdgepoints);
        if min(size(fb)) ~= 0
            % fbEntropy = fb * log(fb)';
            fbEntropy = (fb * fb') / size(snake.x(:), 1)^2;
        end
        snake.maxContiguousFreeBorder = max(fb);
        snake.freeBorderEntropy = fbEntropy;
    end
    
    if StarGroundTruth(noPropsSnake)
        snake.rank = -now();
        if ~isfield(snake, 'groundTruthIgnore')
             snake.groundTruthIgnore = true;
        end
    else
        %   Linear ranking function, easier to optimize.
        %   If you change this function, you have to change the
        %   corresponding code in OptimizeStarParameters()
        snake.rank = StarRank(snake, rankingParams, avgCellDiameter);
    end
end
