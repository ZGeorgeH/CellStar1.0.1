%     Copyright 2013 Kirill Batmanov
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


function [connectivity, connectivityImage] = SegmentsConnectivity2(currentImage, parameters)

  nSegments = max(currentImage.segments(:));

  connectivityImage = false(size(currentImage.originalClean));
  
  connectivity.reachable = false(nSegments);
  connectivity.neighbors = false(nSegments);
  connectivity.distance = -ones(nSegments);
  
  if strcmpi(parameters.connectivity.calculate, 'no')
      PrintMsg(parameters.debugLevel, 4, 'Channel calculation is not performed.');
      connectivity.channel = {};
      connectivity.channelMaxBrightness = [];
      connectivity.channelLength = [];
  else
      connectivity.channel = cell(double(nSegments));
      connectivity.channelMaxBrightness = -ones(nSegments);
      connectivity.channelLength = zeros(nSegments);
%     return 
  end

%   if false
%     connectivityImageBG = currentImage.brighter;
%     h = fspecial('average', 5);
%     connectivityImageBG = filter2(h, connectivityImageBG);
%   else
    connectivityImageBG = currentImage.originalClean;
%     if isempty(connectivityImageBG)
%         keyboard
%     end
    [gx, gy] = gradient(connectivityImageBG);
    g = sqrt(gx.^2 + gy.^2);
    connectivityImageBG = ImageBlur(g, round(parameters.connectivity.gradientBlur * parameters.segmentation.avgCellDiameter));
%   end

  % Try to guess if segments are disconnected == there are no visible
  % channels between close (but not touching/overlapping) cells
  % Idea: it is not possible to say whether there is a channel between
  % two cells (e.g. mother and daughter) but if a clear white border is
  % present between them, then we are pretty sure that there is no such
  % channel

  props = regionprops(currentImage.segments, 'Centroid');
  
  PrintMsg(parameters.debugLevel, 4, 'Calculating neighbor channels...');
  
  connData = cell(nSegments, 1);
  segs = currentImage.segments;
     
  parfor currSeg = 1:nSegments
    c1 = round(props(currSeg).Centroid);
    
    currDilatedSeg = ImageDilate(segs == currSeg, round(parameters.connectivity.maxDistance * parameters.segmentation.avgCellDiameter));
    neighbors = double(currDilatedSeg) .* double(segs ~= currSeg) .* double(segs);
    neighbors = unique(neighbors(:));
    neighborhood = neighbors(neighbors > currSeg);
    PrintMsg(parameters.debugLevel, 4, 'Segment ', currSeg, ', neighbors: ', neighborhood');
    
    nNeighbors = numel(neighborhood);
    connData{currSeg} = cell(nNeighbors, 1);
    for currNeighOrd = 1:nNeighbors
      currNeigh = neighborhood(currNeighOrd);         
      c2 = round(props(currNeigh).Centroid);

      PrintMsg(parameters.debugLevel, 4, 'Calculating neighbor channel between ', ...
         currSeg, ' (', c1(1), 'x', c1(2), ') ', ' and ', ...
         currNeigh, ' (', c2(1), 'x', c2(2), ') ');

       
       
      switch parameters.connectivity.calculate
          case 'straight'
              conn = GetBorderInfoStraight(c1, c2, connectivityImageBG);
          case 'strange'
              conn = ...
                 GetBorderInfo(currSeg, ...
                             currNeigh, ...
                             currentImage, ...
                             connectivityImageBG, ...
                             parameters);
          case 'no'
              conn = InitConnectivity();
      end
      
      seg = currentImage.segments == currSeg;
      neigh = currentImage.segments == currNeigh;
      proximityMask = [1 1 1; 1 1 1; 1 1 1];
      while ~any(seg(neigh))
       seg = imdilate(seg, logical(proximityMask)); 
       conn.distance = conn.distance + 1;
      end      
      
      connData{currSeg}{currNeighOrd} = {currNeigh, conn};        

      PrintMsg(parameters.debugLevel, 4, ...
           'Segments ', currSeg, ', ', currNeigh, ...
           ':    reachable = ', conn.reachable, ...
           '    distance = ', conn.distance, ...
           '    channel brightness = ', conn.channelMaxBrightness, ...
           '    channel length = ', conn.channelLength ...
           );
     end
  end
  
  for currSeg = 1:nSegments
     for currNeighOrd = 1:numel(connData{currSeg})
          currNeigh = connData{currSeg}{currNeighOrd}{1};
         
          if strcmpi(parameters.connectivity.calculate, 'no')
                fields = {'reachable', 'distance', 'neighbors'};
          else
                fields = {'reachable', 'distance', 'channel', 'channelMaxBrightness', 'channelLength', 'neighbors'};
          end
          for i = 1:length(fields)
              connectivity.(fields{i})(currSeg, currNeigh) = ...
                  connData{currSeg}{currNeighOrd}{2}.(fields{i});
              connectivity.(fields{i})(currNeigh, currSeg) = ...
                  connectivity.(fields{i})(currSeg, currNeigh);
          end
         
          if ~strcmpi(parameters.connectivity.calculate, 'no')
              connectivityImage(connectivity.channel(currSeg, currNeigh)) = true;
          end
     end
  end
  
  connectivityImage = ImageNormalize(max(ImageNormalize(connectivityImageBG), double(connectivityImage) * 1.2));
end

function connectivity = InitConnectivity()
   connectivity.reachable = true;
   connectivity.distance = -1;
   connectivity.channel = [];
   connectivity.channelMaxBrightness = -1;
   connectivity.channelLength = 0;
   connectivity.neighbors = true;
end

function connectivity = GetBorderInfoStraight(center1, center2, image)
   connectivity = InitConnectivity();
   connectivity.channelLength = norm(center1 - center2);

   [lx ly] = bresenham(center1(1), center1(2), center2(1), center2(2));
   nPoints = numel(lx);
   connectivity.channel = zeros(nPoints, 1);   
   for i = 1:nPoints
       connectivity.channel(i) = sub2ind(size(image), ly(i), lx(i));
       connectivity.channelMaxBrightness = max(connectivity.channelMaxBrightness, image(ly(i),lx(i)));
   end
end

function connectivity = GetBorderInfo(segment, neighbor, currentImage, connectivityImageBG, parameters)
   connectivity = InitConnectivity();

   seg = currentImage.segments == segment;
   neigh = currentImage.segments == neighbor;

   proximityMask = [1 1 1; 1 1 1; 1 1 1];
     
   dilatedSeg = logical(ImageDilate(seg, round(parameters.connectivity.maxDistance * parameters.segmentation.avgCellDiameter)));
   dilatedNeigh = logical(ImageDilate(neigh, round(parameters.connectivity.maxDistance * parameters.segmentation.avgCellDiameter)));
   border = dilatedSeg & dilatedNeigh & (currentImage.segments == 0);

   %%%%%%%%%%%%%%%%%%%
   border = border | seg | neigh;
   
   [~, c1] = find(border, 1, 'first');
   [~, c2] = find(border, 1, 'last');
   [~, r1] = find(border', 1, 'first');
   [~, r2] = find(border', 1, 'last');

   c1 = max(1, c1 - 2);
   r1 = max(1, r1 - 2);
   c2 = min(size(border, 1), c2 + 2);
   r2 = min(size(border, 2), r2 + 2);
   border =  border(int16(r1:r2), int16(c1:c2));
   seg = seg(int16(r1:r2), int16(c1:c2));
   neigh = neigh(int16(r1:r2), int16(c1:c2));
   
   myimage = connectivityImageBG(int16(r1:r2), int16(c1:c2));
   
   segCenter = regionprops(int32(seg), 'centroid');
   seg = false(size(seg));
   seg(int32(segCenter.Centroid(2)), int32(segCenter.Centroid(1))) = true;
   neighCenter = regionprops(int32(neigh), 'centroid');
   neigh = false(size(seg));
   neigh(int32(neighCenter.Centroid(2)), int32(neighCenter.Centroid(1))) = true;
   
   border = border & (~seg);
   
   currFrontier = border & imdilate(seg, proximityMask);
   currTraversedBorder = zeros(size(seg));
   while ~any(currFrontier & neigh)
       if (max(currFrontier(:)) == 0)
           connectivity.reachable = false;
           break
       end
       brightnessLevels = myimage(currFrontier);
       connectivity.channelMaxBrightness = max(connectivity.channelMaxBrightness, min(brightnessLevels(:)));
       currTraversedBorder = currTraversedBorder | ...
                              ( currFrontier & ...
                                (myimage <= connectivity.channelMaxBrightness) ...
                               );
       currFrontier = (border | neigh) & ...
                      imdilate(seg | currTraversedBorder, proximityMask) & ...
                      ~currTraversedBorder;
   end

   if connectivity.reachable && (connectivity.channelMaxBrightness >= 0)
       allowedBorder = border & (myimage <= connectivity.channelMaxBrightness);
       currTraversedBorder = allowedBorder & imdilate(seg, proximityMask);
       currTraversedBorderNumbered = zeros(size(allowedBorder));
       
       while ~any(currTraversedBorder & neigh)
           connectivity.channelLength = connectivity.channelLength + 1;
           frontier = currTraversedBorder & (currTraversedBorderNumbered == 0) & allowedBorder;
           currTraversedBorderNumbered(frontier) = connectivity.channelLength;
           currTraversedBorder = imdilate(currTraversedBorder, proximityMask) ...
                                 & (allowedBorder | neigh);
       end
       
       smallChannelPath = zeros(size(seg));
       smallChannelPath(find((currTraversedBorderNumbered == connectivity.channelLength) & imdilate(neigh, proximityMask), 1)) = true;
       for i = (connectivity.channelLength - 1):-1:1
           frontier = find((currTraversedBorderNumbered == i) & (imdilate(smallChannelPath, proximityMask)), 1);
           smallChannelPath(frontier) = true;
       end
       channelPath = false(size(currentImage.brighter));
       channelPath(int16(r1:r2), int16(c1:c2)) = smallChannelPath;
       %imagesc(channelPath);
       connectivity.channel = find(channelPath);
   else
       connectivity.channelMaxBrightness = 0;
   end
end
