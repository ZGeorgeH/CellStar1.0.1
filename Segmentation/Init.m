%     Copyright 2013 Kirill Batmanov
%               2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


% TODO:
% check validity of input parameters when possible
function [parameters] = Init(parameters)
  parameters.initializationOk = true;

  PrintMsg(parameters.debugLevel, 2, 'Initializing...');
  
  %restoreDir = pwd;
  %if (~(strcmp(restoreDir, parameters.workingDirectory)))
  %  PrintMsg(parameters.debugLevel, 4, [ 'Switching current directory to "' parameters.workingDirectory '" ...' ]);
  %  cd(parameters.workingDirectory);
  %end
  
  parameters.startTime = datestr(now);

  % Last thing to do: save the parameters in a .mat file in the destination directory
  [s, ~, ~] = mkdir(parameters.files.destinationDirectory);
  if s
    PrintMsg(parameters.debugLevel, 4, 'Segmentation destination directory created or found.');
  else
    PrintMsg(parameters.debugLevel, 0, 'ERROR: segmentation destination directory not found or created.');  
    parameters.initializationOk = false;
  end
end
