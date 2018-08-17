%     Copyright 2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function seeds = FindSeeds(currentImage, parameters, snakes, allSeeds, currentStep)
  seeds = struct([]);
  if (currentStep == 1) && parameters.segmentation.seeding.from.houghTransform
      newSeeds = FindSeedsFromHough(currentImage, parameters);
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from hough transform...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.cellBorderRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  if (currentStep == 1) && parameters.segmentation.seeding.from.cellBorder
      newSeeds = FindSeedsFromBorderOrContent(currentImage, parameters, currentImage.segments, 'border', false);
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from border...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.cellBorderRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  if (currentStep == 1) && parameters.segmentation.seeding.from.cellContent
      newSeeds = FindSeedsFromBorderOrContent(currentImage, parameters, currentImage.segments, 'content', false);
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from content...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.cellContentRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  if (size(snakes, 2) > 0) && parameters.segmentation.seeding.from.cellBorderRemovingCurrSegments
      newSeeds = FindSeedsFromBorderOrContent(currentImage, parameters, currentImage.segments, 'border', true);
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from border after removing current segments...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.cellBorderRemovingCurrSegmentsRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  if (size(snakes, 2) > 0) && parameters.segmentation.seeding.from.cellContentRemovingCurrSegments
      newSeeds = FindSeedsFromBorderOrContent(currentImage, parameters, currentImage.segments, 'content', true);
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from content after removing current segments...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.cellContentRemovingCurrSegmentsRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  if (parameters.segmentation.seeding.from.snakesCentroids && (size(snakes, 2) > 0))
      centroidsX = cellfun(@(x)x.segmentProps.centroidX, snakes, 'UniformOutput', false);
      centroidsY = cellfun(@(x)x.segmentProps.centroidY, snakes, 'UniformOutput', false);
      newSeeds = SeedsFromXY([centroidsX{:}], [centroidsY{:}], 'centroids');
      PrintMsg(parameters.debugLevel, 4, ['Adding ' num2str(size(newSeeds, 2)) ' seeds from centroids...']);
      newSeeds = ...
        [ newSeeds ...
          RandSeeds(...
             parameters.segmentation.seeding.from.snakesCentroidsRandom, ...
             parameters.segmentation.seeding.randomDiskRadius * parameters.segmentation.avgCellDiameter, ...
             newSeeds) ];
      seeds = [seeds newSeeds];
  end
  PrintMsg(parameters.debugLevel, 4, [ 'Found ' num2str(size(seeds, 2)) ' seeds, removing duplicates...']);
%  tic
%  length(seeds)
  seeds = FilterSeeds(seeds, allSeeds, parameters);
%  length(seeds)
%  toc
  PrintMsg(parameters.debugLevel, 4, [ num2str(size(seeds, 2)) ' seeds remaining...']);
end

function seeds = FindSeedsFromBorderOrContent(currentImage, parameters, segments, from, excludeCurrSegments)
    seeds = struct([]);
    i = ~(strcmp(from, 'border'));
   
    if ~i
        im = currentImage.brighter;
        blur = parameters.segmentation.seeding.BorderBlur * parameters.segmentation.avgCellDiameter;
        imName = 'border';
        if excludeCurrSegments
            im(segments ~= 0) = 1;
        end
        im(1, :) = 1;
        im(:, 1) = 1;
        im(size(im, 1), :) = 1;
        im(:, size(im, 2)) = 1;
    else
        im = currentImage.darker;
        blur = parameters.segmentation.seeding.ContentBlur * parameters.segmentation.avgCellDiameter;
        imName = 'content';
        if excludeCurrSegments
            im(currentImage.segments ~= 0) = 0;
        end
    end
    t = imName;
    if excludeCurrSegments
        t = [ t 'NoSegments' ];
        imName = [ imName ' excluding current segments' ];
    end
    if excludeCurrSegments
    end
    blurred = ImageBlur(im, blur);
    ImageShow(blurred, ['Blurred ' imName '...'], 4, parameters.debugLevel, parameters.interfaceMode);
    if ~i
        maxima = FindMaxima(1 - blurred) .* currentImage.foregroundMask;
    else
        maxima = FindMaxima(blurred) .* currentImage.foregroundMask;
    end
    maxima = maxima';
    seedsN = find(maxima)';
    sx = mod(seedsN, size(maxima, 1));
    sy = round((seedsN - sx)/size(maxima,1));
    PrintMsg(parameters.debugLevel, 4, ['Found ' num2str(size(sx, 2)) ' seeds from ' imName '... ']);
    %if (parameters.debugLevel > 1)
    %    hold on; plot(sx,sy,'.'); hold off;
    %end
    %if (strcmp(parameters.interfaceMode, 'confirm'))
    %  input('Press enter to continue...', 's');
    %end
    PrintMsg(parameters.debugLevel, 4, 'Clustering seeds... ');
    [sx, sy] = ClusterSeeds(sx, sy, parameters.segmentation.seeding.minDistance * parameters.segmentation.avgCellDiameter);
    %imshow(double(blurred), double([min(blurred(:)) max(blurred(:))]));
    %hold on; plot(sx,sy,'.'); hold off;
    PrintMsg(parameters.debugLevel, 4, [ 'done. ' num2str(size(sx, 2)) ' seeds from ' imName ' remaining. ']);
    if (strcmp(parameters.interfaceMode, 'confirm'))
      input('Press enter to continue...', 's');
    end
    seeds = [seeds SeedsFromXY(sx, sy, t)];
end


function seeds = FindSeedsFromHough(currentImage, parameters)
    seeds = struct([]);
    sx = [];
    sy = [];
    im = currentImage.original;

    radiiRange = round(sqrt([parameters.segmentation.minArea parameters.segmentation.maxArea] * parameters.segmentation.avgCellDiameter^2 / 4));
    
    if (exist('circle_hough') == 2) || (exist('hough_circle') == 2) || (exist('imfindcircles') == 2)
      tmpsx = [];
      tmpsy = [];
      radiiVect = radiiRange(1):(radiiRange(2) - radiiRange(1))/10:radiiRange(2);
      radiiVect = radiiVect(3:11);
      [gradx, grady] = gradient(double(im));
      imGradBW = ImageNormalize(sqrt(gradx.^2 + grady.^2)) > 0.3;
      PrintMsg(parameters.debugLevel, 4, 'Applying Hough transform...');
      if (exist('imfindcircles') == 2)
        centers = imfindcircles(imGradBW, round(parameters.segmentation.avgCellDiameter * [0.8 1.2]), 'Sensitivity', 0.975);
        if min(size(centers)) > 0
          tmpsx = centers(:, 1)';
          tmpsy = centers(:, 2)';
          dilImGradBW = ImageDilate(imGradBW, round(parameters.segmentation.avgCellDiameter / 6));
          sok = false(size(tmpsx));
          for i = size(tmpsx, 2):-1:1
              sok(i) = ~dilImGradBW(round(tmpsy(i)), round(tmpsx(i)));
          end
          tmpsx = tmpsx(sok);
          tmpsy = tmpsy(sok);
        end;
      else
          if (exist('hough_circle') == 2)
              centersImages = hough_circle(imGradBW, int64(radiiVect));
          else
              centersImages = circle_hough(imGradBW, radiiVect, 'same');
          end
          for i = 1:size(radiiVect, 2)
              %currCenterImage = ImageDilate(ImageNormalize(ImageSmooth(centersImages(:,:,i), round(radiiVect(i) / 5))) > 0.6, 1);
              currCenterImage = ImageDilate(centersImages(:,:,i) > 3 * radiiVect(i), 1 + round(radiiVect(i) / 3));
              centroids = regionprops(logical(currCenterImage), 'Centroid');
              if isfield(centroids, 'Centroid')
                  centroidsVect = [centroids(:).Centroid];
                  tmpsx = centroidsVect(1:2:end);
                  tmpsy = centroidsVect(2:2:end);
                  dilImGradBW = ImageDilate(imGradBW, round(radiiVect(i) / 2));
                  sok = false(size(tmpsx));
                  for i = size(tmpsx, 2):-1:1
                      sok(i) = ~dilImGradBW(round(tmpsy(i)), round(tmpsx(i)));
                  end
                  tmpsx = tmpsx(sok);
                  tmpsy = tmpsy(sok);
              end
          end
      end
      sx = [sx tmpsx ];
      sy = [sy tmpsy ];
    else
      PrintMsg(parameters.debugLevel, 0, 'No Hough transform available on your system...');
    end
   
    PrintMsg(parameters.debugLevel, 4, ['Found ' num2str(size(sx, 2)) ' seeds from Hough transform...']);
 
    PrintMsg(parameters.debugLevel, 4, 'Clustering seeds... ');
    [sx, sy] = ClusterSeeds(sx, sy, parameters.segmentation.seeding.minDistance * parameters.segmentation.avgCellDiameter);
    
    if (strcmp(parameters.interfaceMode, 'confirm'))
      input('Press enter to continue...', 's');
    end
    seeds = [seeds SeedsFromXY(sx, sy, 'hough')];
end

