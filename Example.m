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


%% This file is an example script to run CellStar.
% You can:
% - either start directly the user interface by running the file InitUI.m 
%   (in the subfolder UserInterface) as a function from command line or 
%   by clicking it from Matlab/Octave GUI,
% - or run the following instructions that execute segmentation and
%   tracking in batch mode, without any manual intervention.
% Notice that you can do batch processing even from the user interface,
% once you spent few seconds setting up the session.

%% Create the destination directory
% The result will be in
% ExampleFiles/segments/

movie = 'ExampleFiles';
[cellStarBaseDir, ~, ~] = fileparts(mfilename('fullpath'));
movieDir = fullfile(cellStarBaseDir, movie);

fileSubRegexp = '*';

files = ...
  { 
    fullfile(movieDir, ['yeasts_bf' fileSubRegexp '.tif']);
    % or, if you want one or more specific files, for example
    % fullfile(movieDir, 'yeasts_bf1.tif')
    % fullfile(movieDir, 'yeasts_bf3.tif')
  };

destDirSeg = fullfile(movieDir, 'segments');

addpath('Segmentation', 'Tracking', 'UserInterface', 'Misc');

disp('Init done!');


% Let us get default parameter values for segmentation and tracking
% precision goes from 0 (none) to 20 (veeery slow)
% avgCellDiameter is the average diameter of an adult cell, in pixels: you
% may try auto-detection by not providing it as a parameter to 
% DefaultParameters(), at your own risk!
parameters = DefaultParameters('precision', 7, 'avgCellDiameter', 35);
parameters.debugLevel = 2;

parameters.files.destinationDirectory = destDirSeg;

% The background will be saved in this file
parameters.files.background.imageFile = fullfile(movieDir, 'background.tif');

% The background mask will be edited by hand if the background file does not
% exist already: you may set this flag to false (or press "escape" when asked)
% and try auto-detection, but at your own risk.
% Or better you may use the user interface previously mentioned to edit the 
% background.
parameters.segmentation.background.manualEdit = true;

% Let us choose which files to segment
parameters.files.imagesFiles = files;

% Additional fluorescence channel are mapped by replacing "yeasts_bf" with "yeasts_fluo" in
% the original file name. There are many ways to associate additional
% channels, see file DefaultParameters.m for more detailed information.
parameters.files.additionalChannels{1}.fileMap = { 'regexp', '_bf', '_fluo' };

% Enable parallel processing if you want: for Matlab you need to start
% matlabpool at some point before running the segmentation, while for
% Octave no need.
parameters.maxThreads = 4;
% matlabpool;

% This is to be run to be sure that nothing is missing, and to process
% regular expressions in file names
parameters = CompleteParameters(parameters);

%% Segment pictures

parameters = RunSegmentation(parameters);

disp('Segmentation done!');

%% Run the tracking

tracking = ComputeFullTracking(parameters);

disp('Tracking done!');

%% Modify results manually
% If you change your mind, you can still edit the results 
% in the user interface as follows:
InitUI(parameters);
