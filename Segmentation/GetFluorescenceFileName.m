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


function fluoImageFile = GetFluorescenceFileName(fluoChannelNumber, currIm, parameters)
  fluoImageFile = '';
  fileMapArray = [];
  fluorescenceChannels = parameters.files.additionalChannels;


  if ~isempty(fluorescenceChannels) && isfield(fluorescenceChannels{fluoChannelNumber}, 'files')
     fluoFiles = fluorescenceChannels{fluoChannelNumber}.files;
  else
      fluoFiles = {};
  end

  if ~isempty(fluorescenceChannels) && isfield(fluorescenceChannels{fluoChannelNumber}, 'fileMap')
      fileMap = fluorescenceChannels{fluoChannelNumber}.fileMap;
  else
      fileMap = '';
      fileMapArray = 1:max(size(fluoFiles));
  end

  if ischar(fileMap) && strcmp(fileMap, 'date')
      fileMapArray = zeros(1, max(size(fluoFiles)));
      imageDates = zeros(1, max(size(parameters.files.imagesFiles)));
      if max(size(fluoFiles)) > 0
          for i = 1:max(size(imageDates))
              tmpFileStat = dir(parameters.files.imagesFiles{i});
              imageDates(i) = tmpFileStat.datenum;
          end
          for i = 1:max(size(fluoFiles))
              tmpFileStat = dir(fluoFiles{i});
              distArray = abs(imageDates - tmpFileStat.datenum);
              filesIdx = find(distArray == min(distArray));
              if max(size(filesIdx)) > 1
                  PrintMsg(parameters.debugLevel, 0, [ 'Warning: channel file mapping by date did not work...' ]);
              else
                 if min(size(filesIdx)) > 0
                    fileMapArray(i) = filesIdx;
                 end
              end
          end                  
      end
  elseif iscell(fileMap)
      if strcmp(fileMap{1}, 'regexp')
          fluoImageFile = regexprep(...
              cell2mat(parameters.files.imagesFiles(currIm)), ...
              fileMap{2}, ...
              fileMap{3});
      end
  elseif isempty(fileMap) 
      fileMapArray = 1:length(fluoFiles);
  elseif isnumeric(fileMap)
      fileMapArray = fileMap;
  end

  if ~isempty(fileMapArray)
      fluoFileIdx = find(fileMapArray == currIm);
      if length(fluoFileIdx) > 1
          PrintMsg(parameters.debugLevel, 0, [ 'Warning: your fluorescence file map is very likely wrong...' ]);
          fluoFileIdx = fluoFileIdx(1);
      end
      if min(size(fluoFileIdx)) > 0
          if (fluoFileIdx <= max(size(fluoFiles)))
              fluoImageFile = fluoFiles{fluoFileIdx};
          end
      end
  end
end
