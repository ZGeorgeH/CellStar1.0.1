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


function [parameters, background] = CompleteParameters(oldParameters)
  % Asks user for file names of images to segment, if none is provided in parameters;
  % calculates cell diameter if needed;
  % loads background image or computes it if needed, according to parameters.

  parameters = oldParameters;
  
  parameters.files.imagesFiles = FilesFromRegexps(parameters.files.imagesFiles);
  PrintMsg(parameters.debugLevel, 4, [ num2str(size(parameters.files.imagesFiles, 1)) ' images found.']);

  for i = 1:length(parameters.files.additionalChannels)
      if isfield(parameters.files.additionalChannels{i}, 'files')
          parameters.files.additionalChannels{i}.files = FilesFromRegexps(parameters.files.additionalChannels{i}.files);
          PrintMsg(parameters.debugLevel, 3, [ num2str(size(parameters.files.additionalChannels{i}.files, 1)) ' images found in additional channel ' num2str(i) '.']);
      end
  end
  
  if (parameters.debugLevel > 3)
    PrintMsg(parameters.debugLevel, 4, 'Files to be segmented:');
    for i = 1:size(parameters.files.imagesFiles(:), 1)
      PrintMsg(parameters.debugLevel, 4, cell2mat(parameters.files.imagesFiles(i)) );
    end
  end
  
  if size(parameters.files.imagesFiles(:), 1) == 0
     if strcmp(parameters.interfaceMode, 'batch')
         PrintMsg(parameters.debugLevel, 0, 'You chose batch mode and there is no file to process!');
     else
         PrintMsg(parameters.debugLevel, 0, 'Either you did not enter any file name to segment or none could be found. Choose some files now!');
         parameters.files.imagesFiles = MultiSelectFiles(parameters, 'Choose one or more image files...');
         if max(size(parameters.files.additionalChannels)) == 0
             fluoChans = input('Specify the number of additional channels (or press enter for none)');
             for i = 1:fluoChans
                PrintMsg(parameters.debugLevel, 0, [ 'Select files for additional channel ' num2str(i) '...' ]);
                parameters.files.additionalChannels{i}.files = MultiSelectFiles(parameters, 'Choose one or more additional image files...');
                parameters.files.additionalChannels{i}.fileMap = ...
                    input('Specify how to map additional channel files to segmentation images (by "date", or just press enter for the identity map, or specify a map: [ v1 v2 v3 ... ] )');
                parameters.files.additionalChannels{i}.computeFluorescence = ...
                    input('Specify how to compute fluorescence ("avg" or empty string for the average, "max" for the maximum)');
             end
         end
     end
  end

  if parameters.segmentation.avgCellDiameter <= 0
     PrintMsg(parameters.debugLevel, 0, 'Auto-detecting cell size, it will take some time...');
     parameters.segmentation.avgCellDiameter = DetectAvgCellSize(parameters);
     PrintMsg(parameters.debugLevel, 0, [ 'Detected diameter: ' num2str(parameters.segmentation.avgCellDiameter) ]);
  end

  [background, parameters] = GetBackground(parameters);
  
end
