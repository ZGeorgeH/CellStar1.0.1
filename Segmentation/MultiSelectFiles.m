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


function selectedFiles = MultiSelectFiles(parameters, msg)
     % Ask user to select multiple files by uigetfile()
     
     selectedFiles = 0;
     currentFolder = pwd;
     if ~isempty(parameters.files.destinationDirectory)
         if ~exist(parameters.files.destinationDirectory, 'file')
             mkdir(parameters.files.destinationDirectory);
         end
         cd(parameters.files.destinationDirectory);
     end
     [f, d] = uigetfile({parameters.files.uigetfileFilter}, msg, 'MultiSelect', 'on');
     cd(currentFolder);
     if isnumeric(f)
         PrintMsg(parameters.debugLevel, 0, 'Canceling...');
     else
         if ischar(f)
             selectedFiles = { fullfile(d, f) };
             PrintMsg(parameters.debugLevel, 0, '1 file selected.');
         else
             selectedFiles = {};
             for i = size(f(:), 1):-1:1
                 % Octave bug, may be removed later
                 if ~isempty(f{i})
                     selectedFiles{end + 1} = fullfile(d, f{i});
                 end
             end
             % Octave bug/incompatibility: does not sort file names
             selectedFiles = sort(selectedFiles);
             PrintMsg(parameters.debugLevel, 0, [ num2str(length(selectedFiles)) ' files selected.' ]);
         end
     end
end
