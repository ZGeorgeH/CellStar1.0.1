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


function [fileSnakes, allSeeds, currentImage] = LoadPreviousSegmentation(oldParameters, frameNumber)
    parameters = oldParameters;
    
    fileNames = OutputFileNames(frameNumber, parameters);
    
%     
%     if ~parameters.segmentation.loadPreviousSegmentationResults
%         return
%     end

    [currentImage.segments, fileSnakes, allSeeds, currentImage, ~, ~] = LoadSegmentationData(fileNames.segmentation, fileNames.segmentationGroundTruth, parameters.debugLevel);
    allSeeds = DecodeSeeds(allSeeds);

    if (IsSubField(currentImage, { 'original' }))
        PrintMsg(parameters.debugLevel, 4, 'Original picture loaded from previous segmentation...');
    end

    if (IsSubField(currentImage, { 'segments' }))
        PrintMsg(parameters.debugLevel, 4, 'Segments loaded from previous segmentation...');
    end

    if (IsSubField(currentImage, { 'brighterOriginal' }))
        PrintMsg(parameters.debugLevel, 4, 'Original brighter image loaded from previous segmentation...');
    else
        if exist(fileNames.images.brighterOriginal, 'file')
            [tmpMatrix, ~] = ReadImage(fileNames.images.brighterOriginal, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
            currentImage.brighterOriginal = tmpMatrix(:,:,1);
            clear tmpMatrix;
        end
    end

    if (IsSubField(currentImage, { 'darkerOriginal' }))
      PrintMsg(parameters.debugLevel, 4, 'Original darker image loaded from previous segmentation...');
    else
        if exist(fileNames.images.darkerOriginal, 'file')
            [tmpMatrix, ~] = ReadImage(fileNames.images.darkerOriginal, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
            currentImage.darkerOriginal = tmpMatrix(:,:,1);
            clear tmpMatrix;
        end
    end

    if (IsSubField(currentImage, { 'originalClean' }))
      PrintMsg(parameters.debugLevel, 4, 'Clean image loaded from previous segmentation...');
    else
        if exist(fileNames.images.originalClean, 'file')
            [tmpMatrix, ~] = ReadImage(fileNames.images.originalClean, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
            currentImage.originalClean = tmpMatrix(:,:,1);
            clear tmpMatrix;
        end
    end

    if (IsSubField(currentImage, { 'cleanBlurred' }))
      PrintMsg(parameters.debugLevel, 4, 'Blurred cleaned image loaded from previous segmentation...');
    end

    if (IsSubField(currentImage, { 'foregroundMask' }))
      PrintMsg(parameters.debugLevel, 4, 'Foreground mask loaded from previous segmentation...');
    else
        if exist(fileNames.images.foregroundMask, 'file')
            [tmpMatrix, ~] = ReadImage(fileNames.images.foregroundMask, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
            currentImage.foregroundMask = logical(tmpMatrix(:,:,1));
            clear tmpMatrix;
        end
    end
    
    if (IsSubField(currentImage, { 'cellContentMask' }))
      PrintMsg(parameters.debugLevel, 4, 'Cell content mask loaded from previous segmentation...');
    else
        if exist(fileNames.images.cellContentMask, 'file')
            [tmpMatrix, ~] = ReadImage(fileNames.images.cellContentMask, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
            currentImage.cellContentMask = logical(tmpMatrix(:,:,1));
            clear tmpMatrix;
        end
    end
    
end
