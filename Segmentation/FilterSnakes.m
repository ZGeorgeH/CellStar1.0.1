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


function [newSnakes, segments] = FilterSnakes(currentImage, parameters, oldSnakes)
   % Filter snakes based on their properties, overlapping, etc.

   newSnakes = cell(size({}));
   segments = zeros(size(currentImage.original));
   if (size(oldSnakes(:), 1) == 0)
       PrintMsg(parameters.debugLevel, 3,  'No snakes to filter...');
   else
       PrintMsg(parameters.debugLevel, 3,  'Filtering snakes...');

       snakerank = zeros(size(oldSnakes));
       for i = 1:size(oldSnakes(:))
           oldsp = oldSnakes{i};
           snakerank(i) = oldsp.rank;
       end

       [~, I] = sort(snakerank);

       curindex = 1;
       
       for i=1:size(oldSnakes(:),1)
           if ~isfield(oldSnakes{i}, 'inPolygon')
           end
       end

       for i=1:size(oldSnakes(:),1)
           currSnake = oldSnakes{I(i)};
           isNotPutByHand =  ~StarGroundTruth(currSnake);
           if (currSnake.rank > parameters.segmentation.ranking.maxRank) && isNotPutByHand
               PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too high rank:' num2str(snakerank(I(i))) ' ...' ]);
           else
               if isfield(currSnake, 'inPolygon')
%                    in = false(size(currentImage.original));
                    xy = currSnake.inPolygonXY;
                    in = currSnake.inPolygon;
%                    in(inpx:inpx+inps(1)-1, inpy:inpy+inps(2)-1) = currSnake.inPolygon;
               else
                   [~, in, xy] = OptInPolygon(size(currentImage.original), currSnake.x, currSnake.y);
               end
               xy = [xy(1) xy(2) ([xy(1) xy(2)] + size(in) - 1)];
               % proximityDilation disabled, to be reimplemented according
               % to new implementation
%                if parameters.segmentation.ranking.proximityDilation > 0
%                  dilatedSegments = ImageDilate((segments ~= 0), parameters.segmentation.ranking.proximityDilation);
%                else
%                  dilatedSegments = segments;
%                end
               dilatedSegments = segments(xy(1):xy(3),xy(2):xy(4));
               overlaparea = sum(dilatedSegments(in) ~= 0);
               
               overlap = overlaparea / currSnake.segmentProps.area;
               if (overlap > parameters.segmentation.maxOverlap)
                   PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too much overlapping: ' num2str(overlap) '...' ]);
               else
                   in2 = in & (dilatedSegments == 0);
                   % recalculate average inner darkness and area, since the snake
                   % could have changed because of overlapping!
                   tmp = (in2 .* currentImage.cellContentMask(xy(1):xy(3),xy(2):xy(4)));
                   currSnake.segmentProps.area = sum(in2(:));
                   currSnake.segmentProps.avgInnerDarkness =  sum(tmp(:)) / currSnake.segmentProps.area;
                   
                   if (currSnake.segmentProps.avgInnerDarkness < parameters.segmentation.minAvgInnerDarkness) && isNotPutByHand
                       PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too low "inner darkness"...' ]);
                   else
                      if (currSnake.segmentProps.area > (parameters.segmentation.maxArea * parameters.segmentation.avgCellDiameter^2 * pi / 4)) && isNotPutByHand
                           PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too big area: ' num2str(currSnake.segmentProps.area) ' ...' ]);
                      else
                          if (currSnake.segmentProps.area < (parameters.segmentation.minArea * parameters.segmentation.avgCellDiameter^2 * pi / 4)) && isNotPutByHand
                               PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too small area...' ]);
                          else
                               maxFreeBorder = parameters.segmentation.stars.points * parameters.segmentation.maxFreeBorder;
                               if isfield(currSnake, 'maxContiguousFreeBorder') && ~isempty(currSnake.maxContiguousFreeBorder) && (currSnake.maxContiguousFreeBorder > maxFreeBorder) && isNotPutByHand
                                   PrintMsg(parameters.debugLevel, 4,  [ 'Discarding snake ' num2str(I(i)) ' for too long contiguous free border: ' num2str(currSnake.maxContiguousFreeBorder) ' over ' num2str(maxFreeBorder) '...' ]);
                               else
                                   dilatedSegments(in2) = curindex;
                                   segments(xy(1):xy(3),xy(2):xy(4)) = dilatedSegments;
                                   newSnakes{1, curindex} = oldSnakes{I(i)};
                                   PrintMsg(parameters.debugLevel, 4,  [ 'Accepting snake ' num2str(I(i)) '...' ]);
                                   curindex = curindex + 1;
                               end
                          end
                      end
                   end
               end
           end
       end
   end
end
