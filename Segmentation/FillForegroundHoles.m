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

function newMask = FillForegroundHoles(oldMask, parameters)
  newMask = oldMask;

  ImageShow(newMask, 'Foreground detected...', 4, parameters.debugLevel, parameters.interfaceMode);
  PrintMsg(parameters.debugLevel, 3, 'Filling foreground holes...');

  tmpNewMask = newMask;
  while true
     blackAreas = regionprops(~tmpNewMask, 'PixelIdxList');
     PrintMsg(parameters.debugLevel, 4, [ num2str(max(size(blackAreas))) ' hole(s) to fill, ' num2str(size(tmpNewMask(:), 1) - sum(tmpNewMask(:))) ' pixel(s)...']);
     if min(size(blackAreas)) > 0
         for i = 1:max(size(blackAreas))
            if isfield(blackAreas(i), 'PixelIdxList')
                if size(blackAreas(i).PixelIdxList, 1) < (parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4)
                    tmpNewMask(blackAreas(i).PixelIdxList) = true;
                else
                   tmpMask = false(size(oldMask));
                   tmpMask(blackAreas(i).PixelIdxList) = true;
                   %imshow(tmpMask);
                   tmpMask = ImageDilate(tmpMask, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter);
                   tmpMask = ImageErode(tmpMask, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter);
                   tmpMask = ImageErode(tmpMask, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter);
                   tmpMask = tmpMask & ~tmpNewMask;
                   %imshow(tmpMask);
                   smallBlackAreas = regionprops(tmpMask, 'PixelIdxList');
                   for j = 1:size(smallBlackAreas, 1)
                      if size(smallBlackAreas(j).PixelIdxList, 1) < (parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4)
                          tmpMask2 = false(size(oldMask));
                          tmpMask2(smallBlackAreas(j).PixelIdxList) = true;
                          %imshow(tmpMask2);
                          % tmpMask2 = logical(ImageDilate(tmpMask2, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter));
                          tmpNewMask(tmpMask2) = true;
                      end
                   end
                end
            end
         end
     end
     if tmpNewMask == newMask
         break
     else
        newMask = tmpNewMask;
     end
  end
  
  
%   whiteAreas = regionprops(newMask, 'PixelIdxList');
%   for i = 1:size(whiteAreas, 1)
%       if size(whiteAreas(i).PixelIdxList, 1) >= (parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4)     
%           tmpMask = zeros(size(oldMask));
%           tmpMask(whiteAreas(i).PixelIdxList) = true;
%           blackAreas = regionprops(~tmpMask, 'PixelIdxList');
%           for j = 1:size(blackAreas, 1)
%             if size(blackAreas(j).PixelIdxList, 1) <
%             (parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4)
%                 newMask(blackAreas(j).PixelIdxList) = true;
%             end
%           end
%       end
%   end
  
  % newMask = FillSmallHoles(newMask, parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4);

  ImageShow(newMask, 'Holes filled...', 4, parameters.debugLevel, parameters.interfaceMode);
  
%   whiteAreas = regionprops(newMask, 'PixelIdxList');
%   for i = 1:size(whiteAreas, 1)
%       if size(whiteAreas(i).PixelIdxList, 1) < (parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4)
%           newMask(whiteAreas(i).PixelIdxList) = false;
%       end
%   end

  newMask = ~FillSmallHoles(~newMask, parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4, parameters.debugLevel);

  ImageShow(newMask, 'Small contiguous regions removed...', 4, parameters.debugLevel, parameters.interfaceMode);
  
  newMask = ImageErode(newMask, parameters.segmentation.foreground.MaskMinRadius * parameters.segmentation.avgCellDiameter);
  newMask = ImageDilate(newMask, parameters.segmentation.foreground.MaskMinRadius * parameters.segmentation.avgCellDiameter);
  
  ImageShow(newMask, 'Noise hopefully removed...', 4, parameters.debugLevel, parameters.interfaceMode);

  newMask = DilateBigAreas(newMask, parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter, parameters.debugLevel);

  ImageShow(newMask, 'Dilated remaining big areas...', 4, parameters.debugLevel, parameters.interfaceMode);
  
  return


  newMask = DilateBigAreas(newMask, parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter, parameters.debugLevel);

  %newMask = ImageDilate(newMask, parameters.segmentation.foreground.MaskPreDilation);

  ImageShow(newMask, 'Dilated big areas...', 4, parameters.debugLevel, parameters.interfaceMode);

  newMask = FillSmallHoles(newMask, parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4, parameters.debugLevel);

  ImageShow(newMask, 'Filling small holes...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = ImageErode(newMask, parameters.segmentation.foreground.MaskPreDilation);

  %ImageShow(newMask, 'Eroding...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = medfilt2(newMask, [1 1] * parameters.segmentation.foreground.medianFilter, 'symmetric');

  %ImageShow(newMask, 'Applying median filter...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = FillSmallHoles(newMask, parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4);

  %ImageShow(newMask, 'Re-filling small holes...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = ImageDilate(newMask, parameters.segmentation.foreground.MaskPreDilation);

  %ImageShow(newMask, 'Dilating...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = FillSmallHoles(newMask, parameters.segmentation.foreground.FillHolesWithAreaSmallerThan * parameters.segmentation.avgCellDiameter^2 * pi / 4);

  %ImageShow(newMask, 'Re-re-filling small holes...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = ImageErode(newMask, parameters.segmentation.foreground.MaskMinRadius * parameters.segmentation.avgCellDiameter);
  %newMask = ImageDilate(newMask, parameters.segmentation.foreground.MaskMinRadius * parameters.segmentation.avgCellDiameter);

  newMask = ~FillSmallHoles(~newMask, parameters.segmentation.foreground.MinCellClusterArea * parameters.segmentation.avgCellDiameter^2 * pi / 4, parameters.debugLevel);

  ImageShow(newMask, 'Small contiguous regions removed...', 4, parameters.debugLevel, parameters.interfaceMode);

  %newMask = ImageDilate(newMask, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter);
  %ImageShow(newMask, 'Foreground mask dilated...', 4, parameters.debugLevel, parameters.interfaceMode);
end


function newMask = FillSmallHoles(oldMask, maxHoleSize, debugLevel)
  newMask = oldMask;
  fgMaskRP = regionprops(~newMask, 'PixelIdxList');
  PrintMsg(debugLevel, 4, ['Filling ' num2str(max(size(fgMaskRP))) ' holes...']);
  for pil = 1:size(fgMaskRP, 1)
      if size(fgMaskRP(pil).PixelIdxList, 1) < maxHoleSize
          newMask(fgMaskRP(pil).PixelIdxList) = true;
      end
  end
end

function newMask = DilateBigAreas(oldMask, minAreaSize, dilateRadius, debugLevel)
  newMask = oldMask;
  fgMaskRP = regionprops(newMask, 'PixelIdxList');
  PrintMsg(debugLevel, 4, ['Dilating ' num2str(max(size(fgMaskRP))) ' areas...']);
  for pil = 1:size(fgMaskRP, 1)
      if size(fgMaskRP(pil).PixelIdxList, 1) > minAreaSize
          tmpMask = zeros(size(oldMask));
          tmpMask(fgMaskRP(pil).PixelIdxList) = true;
          tmpMask = ImageDilate(tmpMask, dilateRadius);
          newMask = newMask | tmpMask;
      end
  end
end

