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


function currentImage = ComputeIntermediateImages(currentImage, background, frameNumber, parameters)

    currImFileName = parameters.files.imagesFiles{frameNumber};

    if ~(isfield(currentImage, 'original'))
        [tmpMatrix, parameters.segmentation.transform.originalImDim] = ReadImage(currImFileName, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
        currentImage.original = tmpMatrix(:,:,1);
    end
    
    if ~(isfield(currentImage, 'brighterOriginal')) 
      PrintMsg(parameters.debugLevel, 4, 'Computing brighter image...');
      currentImage.brighterOriginal = BackgroundSubtract(currentImage.original, background, 1, parameters.debugLevel, parameters.interfaceMode);
    end
       
        
    if ~(isfield(currentImage, 'darkerOriginal'))
      PrintMsg(parameters.debugLevel, 4, 'Computing darker image...');
      currentImage.darkerOriginal = BackgroundSubtract(currentImage.original, background, -1, parameters.debugLevel, parameters.interfaceMode);
    end
        
    if ~(isfield(currentImage, 'originalClean'))
      PrintMsg(parameters.debugLevel, 4, 'Computing clean image...');
      currentImage.originalClean = ComputeCleanImage(currentImage.original, background);
    end

    if ~(isfield(currentImage, 'foregroundMask'))
        currentImage.foregroundMask = ComputeForegroundMask(currentImage.original, currentImage.brighterOriginal, currentImage.darkerOriginal, parameters);
    end

    if ~(isfield(currentImage, 'cleanBlurred'))
        currentImage.cleanBlurred = ...
            ComputeCleanBlurredImage(...
                currentImage.originalClean, ...
                currentImage.foregroundMask, ...
                parameters.segmentation.stars.gradientBlur, ...
                parameters.segmentation.avgCellDiameter, ...
                parameters.debugLevel);
    end

    if ~(isfield(currentImage, 'brighter'))
      currentImage.brighter = ...
          ComputeBrighterDarkerImage(...
             currentImage.brighterOriginal, ...
             currentImage.foregroundMask, ...
             parameters.segmentation.cellBorder.medianFilter, ...
             parameters.segmentation.avgCellDiameter, ...
             parameters.debugLevel);
    end
        
    if ~(isfield(currentImage, 'darker'))
      currentImage.darker = ...
          ComputeBrighterDarkerImage(...
             currentImage.darkerOriginal, ...
             currentImage.foregroundMask, ...
             parameters.segmentation.cellContent.medianFilter, ...
             parameters.segmentation.avgCellDiameter, ...
             parameters.debugLevel);
    end
    
    if ~(isfield(currentImage, 'cellContentMask'))
      currentImage.cellContentMask = ComputeCellContentMask(currentImage.brighter, currentImage.darker, currentImage.foregroundMask, parameters);
    end
    
end


