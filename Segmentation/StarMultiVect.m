%     Copyright 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [snake, handles] = StarMultiVect(seed, currentImage, parameters, plotContours, fromPolar)
     handles = [];

     starsparameters = parameters.segmentation.stars;

     for i = 1:size(parameters.segmentation.stars.sizeWeight(:), 1)
         starsparameters.sizeWeight = parameters.segmentation.stars.sizeWeight(i);
         currSnake = StarMultiSub(seed, currentImage, starsparameters, parameters.segmentation.avgCellDiameter, false, parameters.debugLevel, fromPolar);
         currSnake = CalcSnakeProperties(currSnake, currentImage, parameters.segmentation.ranking, parameters.segmentation.avgCellDiameter, fromPolar);
         if (i == 1)
             bestSnake = currSnake;
             bestSizeWeight = starsparameters.sizeWeight;
         else
            if bestSnake.rank > currSnake.rank
               bestSnake = currSnake;
               bestSizeWeight = starsparameters.sizeWeight;
            end
         end
     end
     
    snake = bestSnake;
    
%     UIReset
%     % inefficient...
%     if true || plotContours
%         starsparameters.sizeWeight = bestSizeWeight;
%         [~, handles] = StarMultiSub(seed, currentImage, starsparameters, parameters.segmentation.avgCellDiameter, true, parameters.debugLevel, fromPolar);
%     end
% 
%     UIReset
    
    PrintMsg(parameters.debugLevel, 4,  ...
         'Star settled, with features: ', ...
         ' area=' , snake.segmentProps.area, ...
         ' avgOutBorderBrightness=', snake.segmentProps.avgOutBorderBrightness, ...
         ' maxOutBorderBrightness=', snake.segmentProps.maxOutBorderBrightness, ...
         ' avgInBorderBrightness=', snake.segmentProps.avgInBorderBrightness, ...
         ' avgInnerBrightness=', snake.segmentProps.avgInnerBrightness, ...
         ' maxInnerBrightness=', snake.segmentProps.maxInnerBrightness, ...
         ' avgInnerDarkness=', snake.segmentProps.avgInnerDarkness, ...
         ' maxContiguousFreeBorder=', snake.maxContiguousFreeBorder, ...
         ' freeBorderEntropy=', snake.freeBorderEntropy, ...
         ' rank=', snake.segmentProps.rank, ...
         ' bestSizeWeight=', bestSizeWeight); 
end

function [snake, handles] = StarMultiSub(seed, currentImage, starsparameters, avgCellDiameter, plotContours, debugLevel, fromPolar)

    handles = [];

    % shorthands
    N =                fromPolar.N;
%     distance =         fromPolar.distance;
    step =             fromPolar.step;
    unstick =          starsparameters.unstick;
    smoothness =       starsparameters.smoothness;
    gradientWeight =   starsparameters.gradientWeight;
    brightnessWeight = starsparameters.brightnessWeight;
    contentWeight =    starsparameters.contentWeight / avgCellDiameter;
    sizeWeight =       starsparameters.sizeWeight / avgCellDiameter;
    cumBrightnessWeight = starsparameters.cumBrightnessWeight / avgCellDiameter;
%    maxWeight =        starsparameters.maxWeight;
    backgroundWeight = starsparameters.backgroundWeight / avgCellDiameter;

    im = currentImage.cleanBlurred;
    imb = currentImage.brighter;
    imc = currentImage.darker;
    imfg = currentImage.foregroundMask;

    steps = fromPolar.steps;
    maxR = fromPolar.maxR;
    R = fromPolar.R;
    t = fromPolar.t;
    
    px = double(seed.x) + fromPolar.x;
    px = max(px, 1);
    px = min(px, size(im, 2));
    py = double(seed.y) + fromPolar.y;
    py = max(py, 1);
    py = min(py, size(im, 1));
    
    index = reshape(sub2ind(size(im), round(py(:)), round(px(:))), size(fromPolar.x));
    
    preF = ...
        (cumBrightnessWeight * imb(index) ...
        - contentWeight * imc(index) ...
        + backgroundWeight * (1 - imfg(index))) * step;
    
    f = cumsum(preF);
    
%     im_diff = zeros(size(index));
%     im_diff(2:end, :) = im(index(2:end, :)) - im(index(1:(end-1), :));

    borderThicknessSteps = 1 + floor(starsparameters.borderThickness / step);
    
    im_diff = GetGradient(im, index, borderThicknessSteps);
   
    ftot = f ...
         - sizeWeight * repmat(log(R), [1 length(t)]) ...
         - gradientWeight .* im_diff ... % .* im(index)
         - brightnessWeight .* im(index);
         % + max(f')' * maxWeight; disabled
    
    ftot = ftot';
        
    ftot = (ftot - min(ftot(:))) / (max(ftot(:)) - min(ftot(:)) + 10^-10);
    ftot2 = ftot;
    ftot = ftot ./ (repmat(max(ftot, [], 2), 1, size(ftot, 2)) + 10^-10);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % Uncomment this block to show star with shadows, to get pictures for 
%     % documentation / better understanding / debugging
%         dbstop in StarMultiVect at 135  % might be misplaced, does not work in octave
%         dbstop in StarMultiVect at 140  % might be misplaced, does not work in octave
%         dbstop in StarMultiVect at 143  % might be misplaced, does not work in octave
%         dbstop in StarMultiVect at 144  % might be misplaced, does not work in octave
%         im2 = -ones(size(im)); % 1 * currentImage.brighter;
%         im3 = 0 * im2;
%         for i = 1:size(ftot, 2);
%           R = i * step;
%           px1 = seed.x + R*cos(t);
%           py1 = seed.y + R*sin(t);
%           px1p = min(max(1, round(px1)), size(im, 2));
%           py1p = min(max(1, round(py1)), size(im, 1));
%           index = sub2ind(size(im),py1p, px1p);
%           %currvals = (ftot(:, i) - min(ftot(:, 1:i), [], 2)) ./ max(ftot(:, 1:i), [], 2);
%           currvals = ftot2(:, i);
%           im2(index) = max(im2(index)', currvals);
%           im3(index) = im3(index) | (ftot(:, i) == min(ftot')')';
%         end
%         hold on
%         plot(seed.x, seed.y, '.r');
%         hold off
% 
%         im2(im2 == -1) = 1;
%         max_points = im3;
%         imshow(cat(3, max_points, im, ImageNormalize(-im2)), 'border', 'tight');
%         shadows = min(1, ImageNormalize(im2) * 2);
%     %     shadows = ImageBlur(shadows);
%         imshow(1 - shadows);
% r        composite_shadow = im + 0.8 * (1 - shadows);
%         no_shadow = im;
% 
%         composite_im = ImageNormalize(cat(3, no_shadow, composite_shadow, no_shadow));
% 
%         composite_im(cat(3, max_points, 0 * max_points, 0 * max_points) > 0) = 1;
%         composite_im(cat(3, 0 * max_points, max_points, max_points) > 0) = 0;
% 
%         imshow(composite_im, 'border', 'tight');
%         imshow(ImageNormalize(currentImage.original), 'border', 'tight');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    idx = find(ftot == repmat(min(ftot, [], 2), 1, size(ftot, 2)), size(ftot, 1), 'first');
    
%     UIReset
    
    [ymins, xmins] = ind2sub(size(ftot), idx);
    [~, s] = sort(ymins);
    xmins = xmins(s);
    %ymins = ymins(s);

    
    maxd = double(abs(smoothness) * (1:steps) / (N));

    %%%SmoothContour(xmins, maxd)
    [xmins2, xmaxs] = SmoothContour(xmins, maxd, debugLevel, N, ftot);
    
    edgepoints = (xmins2 ~= xmaxs) | ((xmins2 == xmins) & (xmins2 < maxR - 1));
    xmins3 = min(xmins2, double(fromPolar.maxR));
    
    snake.originalEdgepoints = edgepoints; % before unsticking!
    snake.unstick = unstick;
    
    edgepoints = ContourUnstick(edgepoints, unstick);
    
    snake.finalEdgepoints = edgepoints; % after unsticking!
    
    cumlengths = find(edgepoints);
    if size(cumlengths(:) > 0)
        cumlengthsloop = [cumlengths(:) ; cumlengths(1) + N];
        for i = 1:size(cumlengths(:))
            current = cumlengths(i);
            mlength = cumlengthsloop(i + 1) - current - 1;
            jend = mod(current+mlength, N) + 1;

            for k = current+1:current+mlength
                j = mod((k - 1), N) + 1;
                newval = round(double(xmins3(current)) + double(xmins3(jend) - xmins3(current)) * double(k - current) / double(mlength + 1));
                xmins3(j) = min(xmins3(j), newval);
                %disp(['...' num2str(length)]);
            end
        end
    end
    
%     toc;

    % Show borders of star at all stages
%     input('Press enter to continue...', 's');

    px = double(seed.x) - 0. + step * (xmins3) .* cos(t');
    py = double(seed.y) + 0. + step * (xmins3) .* sin(t');
    py = [py;py(1)];
    px = [px;px(1)];
    
    % FIXME: polarCoordinateBoundary should always be a vector of integers, but (with
    % Octave) it happened to be also non integer: bug to fix?
    snake.polarCoordinateBoundary = min(max(round(xmins3), 1), double(maxR));
    snake.x = px;
    snake.y = py;
    snake.seed = seed;
    snake.type = 'star';

    if plotContours
        imshow(currentImage.originalClean, 'Border', 'Tight');
        starplot = @(x, color)StarPlot(x, seed, step, t, color);
        hold on;
        % handles(end + 1) = plot(double(seed.x + 0.), double(seed.y - 0.), 'r');
        handles(end + 1) = starplot(xmins, 'b');
        % handles(end + 1) = starplot(xmaxs, 'y');
        handles(end + 1) = starplot(xmins2, 'c');
        % starplot(xmins3, 'y');
        newHandles = PlotSnakeContour(snake);
        handles(end + 1 : end + int16(length(newHandles))) = newHandles;
        hold off;
        drawnow
    end

end

function h = StarPlot(x, seed, step, t, color)
    px = double(seed.y) - 0. + step * (x) .* sin(t');
    py = double(seed.x) + 0. + step * (x) .* cos(t');
    h = plot([py;py(1)], [px;px(1)], ['-' color], 'LineWidth', 2);
end

function  im_diff = GetGradient(im, index, borderThicknessSteps)
    im_diff = zeros([ size(index) borderThicknessSteps ]);
    for i = 1:borderThicknessSteps
        matrixend = size(index, 1) - i;
        matrixstart = 1 + i;
        intersectstart = 1 + ceil(i / 2);
        interesectend = intersectstart + matrixend - 1;
        im_diff( intersectstart:interesectend, :, i) = ...
            (im(index(matrixstart:end, :)) - im(index(1:matrixend, :))) / sqrt(i); % or i or nothing?
    end
    im_diff = max(im_diff, [], 3);
end    

function [xmins2, xmaxs] = SmoothContour(xmins, maxd, debugLevel, N, ftot)
    istart = find(xmins == min(xmins), 1, 'first');
    
    xmaxs = xmins;
    xmins2 = xmins;
    ok = 1;
    
    maxIterations = 10^5; % prevent infinite loops, there is no proof of termination
    currIteration = 0;
    
    thereIsChange = true;
    while thereIsChange
        thereIsChange = false;

        if currIteration > maxIterations
          PrintMsg(debugLevel, 3, 'StarMultiVect: Breaking loop, max iterations reached...');
          break
        end

        while (ok < N)
          current = mod((istart + currIteration - 1), N) + 1;
          previous = mod((istart + currIteration - 2), N) + 1;
          if (xmins2(current) - xmins2(previous) > maxd(int16(xmins2(previous))))
            xmaxs(current) = xmins2(previous) + maxd(int16(xmins2(previous)));
            v = ftot(current, 1:xmaxs(current));
            xmins2(current) = find(v == min(v), 1, 'last');
    %         ok = min(0, ok - 2);
            ok = 0;
            thereIsChange = true;
          else
            ok = ok + 1;
          end

          currIteration = currIteration + 1;
          if currIteration > maxIterations
            break
          end

        end

        while (ok > 1)
          current = mod((istart + currIteration - 1), N) + 1;
          previous = mod((istart + currIteration), N) + 1;
          if (xmins2(current) - xmins2(previous) > maxd(int16(xmins2(previous))))
            xmaxs(current) = xmins2(previous) + maxd(int16(xmins2(previous)));
            v = ftot(current, 1:xmaxs(current));
            xmins2(current) = max(find(v == min(v), 1, 'first'), xmins2(previous) - maxd(int16(xmins2(previous))));
    %         ok = max(N, ok);
    %       else
            ok = 0;
            thereIsChange = true;
              else
            ok = ok - 1;
          end

          currIteration = currIteration + 1;
          if currIteration > maxIterations
            break
          end

        end
    end
    PrintMsg(debugLevel, 4, 'StarMultiVect: ', currIteration, ' iterations.');
end