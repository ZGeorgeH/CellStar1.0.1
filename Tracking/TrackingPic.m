%     Copyright 2013, 2014 Kirill Batmanov
%               2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function pic = TrackingPic(traces, frame, parents, parameters, segments, plotNumbers, boolSaveToFile, baseImage)
%TRACKINGPIC Saves and returns a picture for given frame

  pic = [];
  
  fileNames = OutputFileNames(frame, parameters);
%   try 
%       load(fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'versions.mat'));
%   catch
%       return
%   end

    if isempty(segments)
        if exist(fileNames.segmentation, 'file')
            seg = CSLoad('segmentation', fileNames.segmentation, 'segments');
            segments = seg.segments;
        else
            return
        end
    end
  
%   if versions(frame) ~= tracking.currentTrackingVersion
    % tracking was updated, got to save a new picture
    
    if ~isempty(baseImage)
        im = baseImage;
    else
        try 
            im = imread(fileNames.images.originalClean);
        catch
            disp('Could not load original image, skipping tracking image...');
            return
        end
        if ndims(im) == 3
            im = im(:,:,1);
        end
    end
    
%     currentFigure = get(0,'CurrentFigure');
    
%     h = findobj('name', 'Tracking');
%     if(isempty(h))
%         if strcmp(parameters.hostLanguage, 'matlab')
%           h = figure('name', 'Tracking', 'Visible', 'off');
%         else
%             h = figure('name', 'Tracking', 'Position', [ 0 0 size(im,2) size(im, 1)], 'Visible', 'off', '__graphics_toolkit__', 'gnuplot');
%             %set(gcf, '__graphics_toolkit__', 'gnuplot', 'Visible', 'off');
%             set(gca, 'units', 'normalized', 'position', [0 0 1 1]);
%         end
%     end
        
%     set(0, 'CurrentFigure', h);
    
    nCells = size(traces, 1);
    
    if (nCells == 0)
        pic = baseImage;
        return
    end
    
    nFrames = size(traces, 2);
    
    chsv = rgb2hsv(hsv(nCells));
    chsv(:,2) = 0.5;
    chsv(:,3) = 0.5;
    colors = hsv2rgb(chsv);
    
    rand('seed', 1);
    
    colors = colors(randperm(nCells), :);
    colors = [colors; 0 0 1; 1 0 0; 1 0 1];
    colorMap = zeros(max(traces(:)), 1);

    
    %pic = imadjust(im2double(im));
    pic = im2double(im);
    picSize = size(im);

    nSegments = max(segments(:));
    s = regionprops(segments, 'centroid', 'PixelIdxList');
    tracked = find(traces(:, frame));
    nTracked = numel(tracked);
    trackedSegments = traces(tracked, frame);

    
    if ~isempty(setdiff(traces(:, frame), unique(segments(:))))
      disp('Your tracking is not up-to-date, redo it!');
      return
    end
    coords = cat(1, s(trackedSegments).Centroid);
        

    colorMap(:) = nCells + 1;
    colorMap(1:nSegments) = nCells + 1; % may expand
    colorMap(trackedSegments) = tracked;
    
    for i = 1:nSegments
      if colorMap(i) == nCells + 1
        pic(s(i).PixelIdxList) = 0;
      end
    end    
    
    if frame > 1
      justAppeared = find(traces(:,frame-1) == 0 & traces(:,frame) ~= 0);
      if ~isempty(justAppeared)
        colorMap(traces(justAppeared,frame)) = nCells + 2;
        for i = justAppeared(:)'
          pic(s(traces(i,frame)).PixelIdxList) = 0;
        end
      end
    end
    if frame < nFrames
      willDisappear = find(traces(:,frame+1) == 0 & traces(:,frame) ~= 0);
      if ~isempty(willDisappear)
        colorMap(traces(willDisappear,frame)) = nCells + 3;
        for i = willDisappear(:)'
          pic(s(traces(i,frame)).PixelIdxList) = 0;
        end
      end
    end

    labels = ColorLabels(picSize, s, colors(colorMap, :));
    
    
    borders = false(size(segments));
    borders(2:end, 1:end) = segments(1:end-1, 1:end) ~= segments(2:end, 1:end);
    borders(1:end, 2:end) = borders(1:end, 2:end) | segments(1:end, 1:end-1) ~= segments(1:end, 2:end);
    
    labels(cat(3, borders, borders, borders)) = 0;
    pic(borders) = 0;

    pic = cat(3, pic, pic, pic) + labels;

%     imshow(pic, 'Border', 'tight');

    
    if plotNumbers
      fontSize = 10;      
%       hold on;
      ts = {};
      x = [];
      y = [];
      for j=1:nTracked
          x(j) = coords(j,1);
          y(j) = coords(j,2);
          t = tracked(j);
          ts{j} = num2str(t);
      end
      
      pic = PlotDigitsOnImage(pic, fontSize, ts, x, y);

      % arrow.m is not included in old Matlab versions, nor in Octave
%       if ~isempty(parents)
%         parentsHere = parents(parents(:,3) <= frame & parents(:,3) > frame - 5,1:2);
%         for j = 1:size(parentsHere,1)
%             parent = tracked == parentsHere(j,1);
%             child = tracked == parentsHere(j,2);
%             arrow(coords(parent,:), coords(child,:), 'length', 15,...
%                 'EdgeColor','black','FaceColor','white', 'width', 3);
%         end
%       end
%       hold off;
    end
    
    pic(pic > 1) = 1;
    
%     if strcmp(parameters.hostLanguage, 'matlab')
%         disp(['before drawnow ' get(gcf, 'name')]);
%         drawnow
%         disp(['after drawnow ' get(gcf, 'name')]);
%     end
    
%     PrintScreen(fileNames.images.tracking);
      if boolSaveToFile
         ImageSave(pic, fileNames.images.tracking, parameters.segmentation.transform, parameters.debugLevel);
%         imwrite(pic, fileNames.images.tracking);
      end
%     if strcmp(parameters.hostLanguage, 'octave')
%         close
%     end
%     versions(frame) = tracking.currentTrackingVersion;
%     save(fullfile(parameters.files.destinationDirectory, parameters.tracking.folder, 'versions.mat'), 'versions');
    
%     if ~isempty(currentFigure)
%         set(0, 'CurrentFigure', currentFigure);
%     end
%   end

%   pic = imread(fileNames.images.tracking);
end
