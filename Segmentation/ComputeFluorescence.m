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


function fluorescence = ComputeFluorescence(segments, currIm, parameters)

%   disp('DEBUG ME!');
%   keyboard
  
  cols = max(segments(:));
  fluorescenceChannels = parameters.files.additionalChannels;
  rows = length(fluorescenceChannels);
  fluorescence.matrix = zeros(rows, cols);
  fluorescence.validChannels = false(rows, 1);
  if cols == 0
      return
  end

  for fc = 1:rows
      calculate = 'avg';
      if (length(fluorescenceChannels) >= fc) && ...
         isfield(fluorescenceChannels{fc}, 'computeFluorescence')
          if ischar(fluorescenceChannels{fc}.computeFluorescence)
              switch fluorescenceChannels{fc}.computeFluorescence
                  case {'none', 'avg', 'max'}
                      calculate = fluorescenceChannels{fc}.computeFluorescence;
                  otherwise
                      PrintMsg(parameters.debugLevel, 4, 'Invalid fluorescence calculation method...');
                      calculate = 'none';
              end
          end
      end
      switch calculate
          case 'none'
             PrintMsg(parameters.debugLevel, 4, 'Skipping channel for fluorescence calculation...');
          case {'avg', 'max'}
             fluoImage = LoadFluorescencePicture(fc, currIm, parameters);
             if ~isempty(fluoImage) > 0
                  fluorescence.validChannels(fc) = true;
                  for s = 1:cols
                      mask = segments == s;
                      vals = fluoImage .* mask;
                      if strcmp(calculate, 'max')
                          fluorescence.matrix(fc, s) = max(vals(:));
                      else
                          area = sum(mask(:));
                          fluorescence.matrix(fc, s) = sum(vals(:)) / area;
                      end
                  end
             else
                 PrintMsg(parameters.debugLevel, 4, 'Image not found for fluorescence calculation...');
             end
      end
  end
end
