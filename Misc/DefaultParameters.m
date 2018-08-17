%     Copyright 2013, 2014, 2015 Cristian Versari, Kirill Batmanov
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

function parameters = DefaultParameters(varargin)
  % Get default values for parameters. Three options, each consisting of two 
  % parameters:
  % 'averageCellDiameter', N
  %      the average diameter of a cell in pixels, with 1 <= N
  % 'precision', P
  %      the precision of the image analysis, from 0 (none) to 20 (very slow)
  % 'host', H
  %      'matlab' or 'octave', if not specified it will be autodetected
  
  parameters.cellStarVersion = 1.01;

  parameters.hostLanguage = 'detect';

  parameters.segmentation.avgCellDiameter = -1; % number of pixels of average adult cell diameter. -1: autodetect
  
  precision = 10;

  if mod(nargin, 2) ~= 0
      disp('Wrong number of parameters to DefaultParameters()');
  else
      for i=1:2:nargin
         switch varargin{i} 
             case 'avgCellDiameter'
                 parameters.segmentation.avgCellDiameter = varargin{i + 1};
             case 'precision'
                 precision = varargin{i + 1};
             case 'host'
                 parameters.hostLanguage = varargin{i + 1};
             otherwise
                 disp([ 'Unrecognized parameter to DefaultParameters():' varargin{i} ]);
         end
      end
  end

  parameters.hostLanguage = DetectHost ();

  % Debug level:
  %   0 = no debug
  %   1 = debug
  %   2 = verbose debug
  %   3 = very verbose debug
  %   4 = very very verbose debug
  parameters.debugLevel = 3;

  
  % Possible modes:
  %  'batch'          no questions, no plots are shown
  %
  %  'interactive'    some of the missing parameters may be asked 
  %                   at run time, plots may be shown according 
  %                   to the debug level
  %
  %  'confirm'        waits for user confirmation at every step,
  %                   useful to understand the use of parameters
  parameters.interfaceMode = 'interactive';


  
  
  % Maximal number of parallel threads to use (mainly for Octave, since for
  % Matlab you will have first to start the parallel Matlab pool manually
  % with the right number of workers). A value of 0 means no parallel
  % computation. Notice that visualization of realtime snake detection is disabled
  % if parallel computation is enabled.
  parameters.maxThreads = 4;

  parameters.files.uigetfileFilter = '*.tif;*.png;*.bmp;*.jpg';

  % The background imageFile is the name of the file containing 
  % the background image to be compared to the images to be segmented
  % in order to determine their brighter ( = cell contour) and darker
  % ( = cell content) pixels.
  parameters.files.background.imageFile = '';
  % If manualEdit is set to true and the background imageFile is empty, 
  % then the user is asked to manually provide images and
  % background mask in order to compute a valid background.
  % If the background imageFile is empty and manualEdit is set to false
  % and batch mode is not enabled, the user is asked to choose the file
  % from user interface. If imageFile is empty and batch mode is enabled,
  % the background is computed as a uniform image with value corresponding
  % to the first picture to be segmented blurred by an amount specified
  % in computeByBlurring.
  parameters.segmentation.background.manualEdit = false;
  parameters.segmentation.background.blur = 0.3; % in units of "avgCellDiameter"
  parameters.segmentation.background.blurSteps = 50; % 500 would be better
  parameters.segmentation.background.computeByBlurring = 0.5; % in units of "avgCellDiameter"


  % imagesFiles is a cell array of strings / regular expressions
  % (possibly empty) indicating the files to be processed.
  % If the cell array is empty or no file is found and the interfaceMode is
  % not 'batch', then the user is asked to choose the file from user interface.
  parameters.files.imagesFiles = {};
  
  % Images from additional channels (for example fluorescence channels): 
  % unlimited number of channels. Each channel has 3 fields:
  % - files: a cell array which specifies the list of filenames or regular 
  %          expressions;
  % - fileMap: maps each image of this channel to a
  %            corresponding segmentation image; can be:
  %   - not specified, or '': the first fluo image will correspond
  %     to the first segmentation image, the second to the second, etc.
  %   - 'date': each image will be mapped to the segmentation
  %             image with closest creation/modification date;
  %   - { 'regexp', e1, e2 }: the file name of the image will
  %                           be calculated by applying regexprep() to the
  %                           corresponding file name (with full path) of the
  %                           segmentation image, with
  %                           parameters e1, e2; see doc regexprep;
  %   - [ i1 i2 i3 ...]: an array of integers of (at least) the size 
  %                      of the total number of images in this additional
  %                      channel, mapping each image to the
  %                      corresponding segmentation image.
  % - computeFluorescence: specifies how the fluorescence is computed:
  %   - 'avg': or unspecified: by average of all the area of the segment
  %   - 'max': by max over the pixels of the segment
  %   - 'none': fluorescence is not computed
  parameters.files.additionalChannels = {};

  % destination directory where to save all the files
  parameters.files.destinationDirectory = '';
  
  % absolute path for all the other file/directory variables
  %parameters.workingDirectory = pwd;

  
  parameters.segmentation.loadPreviousSegmentationResults = true;

%   Now disabled: always 'pic'  
%   % Possible values:
%   % 'none'         intermediate images produced during the segmentation
%   %                are not saved
%   %
%   % 'mat'          intermediate images are saved in .mat files
%   %                with the result of the segmentation
%   %
%   % 'pic'          intermediate images are saved as .png pictures but
%   %                not in .mat files
%   %
%   % 'all'          intermediate images are saved both in .mat files 
%   %                and as .png pictures
%   parameters.segmentation.files.saveIntermediate = 'pic';
  
  
  parameters.segmentation.transform.clip.apply = false;
  parameters.segmentation.transform.clip.X1 = 0;
  parameters.segmentation.transform.clip.Y1 = 0;
  parameters.segmentation.transform.clip.X2 = 0;
  parameters.segmentation.transform.clip.Y2 = 0;

  parameters.segmentation.transform.scale = 1; % scale is applied AFTER clip
  
  parameters.segmentation.transform.invert = 0; % -1 = autodetect, 0 = false, 1 = true
  
    
  % The foreground mask is a boolean mask:
  % seeds are not allowed where this mask is equal to 0.
  % The mask is calculated from the difference between the background and the 
  % images to be segmented.
  %
  % The variable parameters.segmentation.foregroundMaskThreshold is the
  % minimal difference between the background image and the image to be segmented
  % that allows setting to 1 the pixels of such a mask. Its value is
  % normalized between 0 and 1.
  parameters.segmentation.foreground.MaskThreshold = 0.03; %0.1; %0.06;
  %parameters.segmentation.foreground.pickyDetection = true; % takes longer... % now depends on segmentation precision
  % parameters.segmentation.foreground.medianFilter = 1;
  %
  % The value (parameters.segmentation.foregroundMaskMinRadius * 2 + 1)
  % is the minimal pixel diameter of contiguous regions in the foreground mask:
  % if smaller than this diameter, all the pixels of these regions are set to 0.
  parameters.segmentation.foreground.MaskMinRadius = 0.34; % in units of "avgCellDiameter"
  %
  % The variable foregroundMaskDilation is the pixel radius for the dilation of the
  % foreground mask.
  % parameters.segmentation.foreground.MaskPreDilation = 3;
  parameters.segmentation.foreground.MaskDilation = 0.136; % in units of "avgCellDiameter"

  parameters.segmentation.foreground.FillHolesWithAreaSmallerThan = 2.26; % in units of "avgCellArea"
  parameters.segmentation.foreground.MinCellClusterArea = 0.85; % in units of "avgCellArea"

  
  parameters.segmentation.foreground.blur = 1; %  1 = no blur

 

  % The cell content mask is a boolean mask, used for the ranking of the
  % snakes, whose value corresponds to the pixel being detected as "cell
  % content" or not. As for the foreground mask, the cell content mask 
  % threshold sets the threshold above which the pixels of such a mask 
  % are set to 1. If the threshold is 0, then the [median value divided by 10] of the
  % cell content picture is used.
  parameters.segmentation.cellContent.MaskThreshold = 0; % 0.07;

  parameters.segmentation.cellContent.medianFilter = 0.17; % in units of "avgCellDiameter"
  
  parameters.segmentation.cellContent.blur = 0.6; % in units of "avgCellDiameter"

  parameters.segmentation.cellBorder.medianFilter = 0.1; % in units of "avgCellDiameter"
  

  parameters.segmentation.seeding.randomDiskRadius = 0.33; % max distance of random seeds in pixels, in units of "avgCellDiameter"
  
  % In order to find the initial seeds for the snakes (and grow them
  % later), two images are considered, calculated by the difference between
  % the current image and the background: the 'border' image, characterized
  % by the set of pixels that in the current image are brighter than the
  % background, and the 'content' image, that conversely contains the
  % pixels that are darker than in the background image.
  % The seeding procedure works in two steps: first a set of seeds is
  % calculated by smoothing the 'border' image and looking for minima, then
  % another set of seed is calculated by smoothing the 'content' image and
  % looking for maxima. The following variables contain the level of
  % blurring, corresponding to the number of times the images are blurred:
  parameters.segmentation.seeding.BorderBlur = 2; % 1.66; % in units of "avgCellDiameter"
  parameters.segmentation.seeding.ContentBlur = 2; % 3.34; % in units of "avgCellDiameter"
  % Seeds tend to cluster. The following parameter states the minimal
  % distance between seeds:
  parameters.segmentation.seeding.minDistance = 0.27; % in units of "avgCellDiameter"
  
  % if you want to supply some user defined seeds or load them from files
  % of previous segmentations, you can store them in this variable
  parameters.segmentation.seeding.initialSeeds = struct([]);
  

  % if you want to supply some user defined snakes or load them from files
  % of previous segmentations, you can store them in this variable
  parameters.segmentation.snakes.initialSnakes = cell(size({}));
 
  % parameters.segmentation.stars.points = 90; % now depends on segmentation precision
  parameters.segmentation.stars.maxSize = 1.67; % in units of "avgCellDiameter"
  % parameters.segmentation.stars.step = 0.0067; % in units of "avgCellDiameter", now depends on segmentation precision
  parameters.segmentation.stars.unstick = 0.3; %0.15;
  parameters.segmentation.stars.smoothness = 4.3129;
  parameters.segmentation.stars.gradientWeight = 15.482;
  parameters.segmentation.stars.brightnessWeight = 0.044210;
  parameters.segmentation.stars.contentWeight = 0; % will be normalized by "avgCellDiameter"
  parameters.segmentation.stars.sizeWeight = 189.4082; % will be normalized by "avgCellDiameter", depends also on segmentation precision
  parameters.segmentation.stars.cumBrightnessWeight = 304.45; % will be normalized by "avgCellDiameter"
  parameters.segmentation.stars.maxWeight = 0;
  parameters.segmentation.stars.backgroundWeight = 0; % will be normalized by "avgCellDiameter"
  parameters.segmentation.stars.gradientBlur = 0; % 0.08; % in units of "avgCellDiameter"
  parameters.segmentation.stars.borderThickness = 0.1; %supposed thickness of cell borders, in units of "avgCellDiameter"
  
  % parameters.segmentation.stars.parameterLearningRingResize = 1; % used for parameter learning, now depends on segmentation precision

  
  
  
  parameters.segmentation.minArea = 0.07; % in units of "avgCellArea"
  parameters.segmentation.maxArea = 2.83; % in units of "avgCellArea"
  parameters.segmentation.maxFreeBorder = 0.4; % now in ParametersFromSegmentationPrecision()
  parameters.segmentation.maxOverlap = 0.3; % 0.38;
  parameters.segmentation.minAvgInnerDarkness = 0.1; % 0.16;

  
  % Several features are calculated for each snake in order to rank it
  % and decide whether the snake is "good" enough to be accepted.
  % Lower rank = better snake
  % 
  parameters.segmentation.ranking.maxRank = Inf; % 0.85 with images in the ExampleFiles
  parameters.segmentation.ranking.avgBorderBrightnessWeight = 0.51310;
  parameters.segmentation.ranking.avgInnerBrightnessWeight = 1;
  parameters.segmentation.ranking.avgInnerDarknessWeight = -0.082400;
  parameters.segmentation.ranking.maxInnerBrightnessWeight = 0.029200;
  parameters.segmentation.ranking.logAreaBonus = 0.26290; % normalized by "avgCellDiameter"
  parameters.segmentation.ranking.stickingWeight = 0.29170;
  parameters.segmentation.ranking.shift = 0.68000;
  
  %%%% parameters.segmentation.ranking.proximityDilation = 0; % this parameter is currently disabled

  % Set the following variable to 1 if you want to avoid overwriting
  % the output corresponding to input files with the same name 
  % in different directories 
  parameters.files.addNumericIdToOutputFileNames = 0;  

  % Maximal distance (in pixels) of two cells to consider them as neighbors
  % and possibly connected through some channel
  parameters.connectivity.maxDistance = 0.34; % in units of "avgCellDiameter"
  parameters.connectivity.calculate = 'no'; % possible values: no, straight, strange
  parameters.connectivity.gradientBlur = 0.0667; % in units of "avgCellDiameter"

  
  % Tracking
  parameters.tracking.folder = 'tracking'; % will be put inside segmentation folder
  % parameters.tracking.iterations = 5; % >= 0 - number of tracking iterations to detect jumps, now in ParametersFromSegmentationPrecision()
  parameters.tracking.minTrackLength = 0; % >= 0 - traces which are shorter than this will be discarded
  parameters.tracking.loadGroundTruth = true; % whether ground truth should be loaded and taken into account for tracking

  parameters = ParametersFromSegmentationPrecision(parameters, precision);
  
  % Lineage
  parameters.lineage.folder = 'lineage'; % will be put inside tracking folder
  
  parameters.lineage.minAttachedFrames = 15; % the minimum number of frames after initial detection during which
                                             % the bud has to stay attached
                                             % to the parent

  parameters.lineage.minBuddingDelay = 17;   % the minimum number of frames between the two budding events of a cell
                                             
  parameters.lineage.maxNewbornSize = 0.31;   % maximal area of a child cell during first minAttachedFrames
                                              % in units of "avgCellArea"
                                             
  parameters.lineage.maxChildSize = 0.42;     % in units of "avgCellArea"
                                             
  parameters.lineage.minParentSize = 0.31;    % minimal area of a parent cell
                                              % in units of "avgCellArea"

                                              
end
