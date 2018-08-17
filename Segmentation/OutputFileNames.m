%     Copyright 2013 Kirill Batmanov
%               2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function fileNames = OutputFileNames(fileNameOrFrameNumber, parameters)
    % for each image to segment, compute output file names for mat files
    % and intermediate images by adding proper suffixes
    
    if ischar(fileNameOrFrameNumber)
        fileName = fileNameOrFrameNumber;
    else
        fileName = parameters.files.imagesFiles{fileNameOrFrameNumber};
    end
    [~, basename, ~] = fileparts(fileName);
    
    if parameters.files.addNumericIdToOutputFileNames
      idx = num2str(currIm + 100000);
      idx = idx(2:size(idx(:)));
      idx = [ idx '_' ];
    else
      idx = '';
    end
    fileNames.basename = fullfile(parameters.files.destinationDirectory, [ idx basename ]);
    fileNames.segmentation = [ fileNames.basename '_segmentation.mat' ];
    fileNames.segmentationGroundTruth = [ fileNames.basename '_segmentation_groundtruth.mat' ];
    fileNames.images.foregroundMask = [ fileNames.basename '_fgmask.png' ];
    fileNames.images.brighterOriginal = [ fileNames.basename '_bright.png' ];
    fileNames.images.brighter = [ fileNames.basename '_bright_pp.png' ];
    fileNames.images.darkerOriginal = [ fileNames.basename '_dark.png' ];
    fileNames.images.darker = [ fileNames.basename '_dark_pp.png' ];
    fileNames.images.originalClean =  [ fileNames.basename '_clean.png' ];
    fileNames.images.connectivity = [ fileNames.basename '_channels.png' ];
    fileNames.images.cellContentMask = [ fileNames.basename '_dark_threshold.png' ];
    fileNames.images.segmentsColor = [ fileNames.basename '_segments.png' ];
    fileNames.images.tracking = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder,...
      [idx basename '_tracking.png']);
end
