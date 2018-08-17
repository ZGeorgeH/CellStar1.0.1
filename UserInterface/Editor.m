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


function Editor(action, mouseClick)
  global csui;
  
  parameters = csui.session.parameters;
  nFrames = length(parameters.files.imagesFiles);
  currFrame = csui.session.states.Editor.currentFrame;
  
  UILoadSegmentationIfNeeded(currFrame);
  if ~isfield(csui.segBuf{currFrame}, 'deletedSegments')
       csui.segBuf{currFrame}.deletedSegments = [];
  end
  
  if ~any(strcmp(action, {'mouse1', 'mouse2', 'swap mouse buttons'}))
      StopTrackingGTAction(false);
  end
  
  if any(strcmp(action, { ...
          'recompute image preprocessing', ...
          'preload (and save) all frames for current channel', ...
          '(re)do segmentation and tracking for current frame', ...
          '(re)do tracking for current frame', ...
          '(re)do segmentation for current frame', ...
          '(re)do segmentation and tracking for all frames', ...
          '(re)do tracking for all frames', ...
          '(re)do segmentation for all frames', ...
          'select frames for which to (re)do segmentation and tracking', ...
          'select frames for which to (re)do tracking', ...
          'select frames for which to (re)do segmentation' ...
          'apply changes properly', ...
          'apply changes and return to main menu', ...
          'apply changes and go to background editor', ...
          'change cell content threshold', ...
          'change foreground threshold', ...
          'automatically tune contour parameters (quick search)', ...
          'automatically tune contour parameters (standard search)', ...
          'automatically tune contour parameters (extensive search)', ...
          'stars contour: reset parameters to default', ...
          'automatically tune ranking parameters (quick search)', ...
          'automatically tune ranking parameters (standard search)', ...
          'automatically tune ranking parameters (extensive search)', ...
          'stars ranking: reset parameters to default', ...
          'stars ranking: change maximum allowed rank', ...
          'stars: change maximum allowed area', ...
          'stars: change minimum allowed area', ...
          'reset user interface' ...
         }))
      csui.sessionNeedsSaving = true;
      SaveSession(false);
  end
  
  switch action
      case 'swap mouse buttons'
          csui.session.states.Editor.invertMouseButtons = ~csui.session.states.Editor.invertMouseButtons;
          disp('Mouse buttons functions swapped.');
      case {'mouse1', 'mouse2'}
          if (strcmp(action, 'mouse1') && ~csui.session.states.Editor.invertMouseButtons) ...
             || (strcmp(action, 'mouse2') && csui.session.states.Editor.invertMouseButtons)
             button = 1;
          else
              button = 2;
          end
          imDim = parameters.segmentation.transform.originalImDim;
          if (mouseClick.x <= 0.5) || (mouseClick.y <= 0.5) || (mouseClick.x >= imDim(2) + 0.5) || (mouseClick.y >= imDim(1) + 0.5)
              disp('Discarding mouse click, out of image area.');
          else
              MouseButtonPressed(button, mouseClick);
              ShowEditor();
          end
      case 'recompute image preprocessing'
          disp('Running preprocessing, it will take some time...');
          DeletePreprocessingImages ();
          chans = { 'originalClean', 'foregroundMask', 'brighterOriginal', ...
            'brighter', 'darkerOriginal', 'darker', 'cellContentMask', ...
            'cleanBlurred', 'segmentsColor', 'segmentsColorMasked', ...
            'tracking', 'trackingMasked', 'connectivity' };
          for j = 1:nFrames
              for i = 1:length(chans)
                  ImageFromBuffer(chans{i}, j);
                  UISaveImageToDisk(chans{i}, j);
              end
              for i = 1:length(chans)
                  ClearImageBuffer(chans{i}, j);
              end
          end
          ShowEditor ();
          disp ('Preprocessing is now terminated.');
      case 'change cell content threshold'
          if ~strcmp (csui.session.states.Editor.channel, 'cellContentMask')
              disp('You can change cell content threshold only when the selected channel is "cell content mask".');
          else
              oldT = num2str (csui.session.parameters.segmentation.cellContent.MaskThreshold);
              cct = inputdlg ('Insert new cell content threshold:', 'Cell content threshold', 1, { oldT });
%              cct = inputdlg ('Insert new cell content threshold:', 'Cell content threshold', 1);
              if (isempty (cct))
                  disp ('Canceling...');
              else
                  csui.session.parameters.segmentation.cellContent.MaskThreshold = max (0, str2double (cct));
                  UILogAction(['% csui.session.parameters.segmentation.cellContent.MaskThreshold = ' num2str(csui.session.parameters.segmentation.cellContent.MaskThreshold) ';']);
                  DeleteImage ('cellContentMask', 1:nFrames);
                  ClearImageBuffer ('cellContentMask', 1:nFrames);
                  ShowEditor ();
              end
          end
      case 'change foreground threshold'
          if ~strcmp (csui.session.states.Editor.channel, 'foregroundMask')
              disp('You can change foreground threshold only when the selected channel is "foreground mask".');
          else
              oldT = num2str (csui.session.parameters.segmentation.foreground.MaskThreshold);
              cct = inputdlg ('Insert new foreground threshold:', 'Foreground threshold', 1, { oldT });
              if (isempty (cct))
                  disp ('Canceling...');
              else
                  csui.session.parameters.segmentation.foreground.MaskThreshold = max (0, str2double (cct));
                  UILogAction(['% csui.session.parameters.segmentation.foreground.MaskThreshold = ' num2str(csui.session.parameters.segmentation.foreground.MaskThreshold) ';']);
                  DeleteImage ('foregroundMask', 1:nFrames);
                  ClearImageBuffer ('foregroundMask', 1:nFrames);
                  ShowEditor ();
              end
          end
      case 'delete selected segment'
          if EditorSegmentIsSelected()
              DeleteSegment(csui.session.states.Editor.selectedSegment, csui.session.states.Editor.currentFrame);
              EditorDeselectSegment();
              ShowEditor();
              disp('You can obtain the same effect with right mouse button when no element is selected.');
          else
              disp('No segment selected.');
          end
      case {'delete all segments in frame except ground truth', ...
              'delete all segments in frame including ground truth' }
          allSegs = ~strcmp(action, 'delete all segments in frame except ground truth');
          EditorDeselectSegment();
          disp('Deleting segments...');
          for i = 1:length(csui.segBuf{currFrame}.snakes)
              if allSegs || ~StarGroundTruth(csui.segBuf{currFrame}.snakes{i})
                  DeleteSegment(i, csui.session.states.Editor.currentFrame);
              end
          end
          ShowEditor();
      case 'undelete last deleted segment'
          if ~isempty(csui.segBuf{currFrame}.deletedSegments)
              UndeleteSegment(csui.segBuf{currFrame}.deletedSegments(end), csui.session.states.Editor.currentFrame);
              disp('You can obtain the same effect with right mouse button over a deleted segment.');
              ShowEditor();
          else
              disp('No segments to undelete.');
          end
      case 'undelete all segments in current frame'
          if isfield(csui.segBuf{currFrame}, 'deletedSegments')
              disp('Undeleting segments...');
              for i = 1:length(csui.segBuf{currFrame}.deletedSegments)
                  UndeleteSegment(csui.segBuf{currFrame}.deletedSegments(end), csui.session.states.Editor.currentFrame);
              end
              ShowEditor();
          end
      case 'remove last added seed'
          RemoveLastSeed(currFrame);
      case 'remove all seeds in current frame'
          RemoveAllSeedsInFrame(currFrame);
      case 'remove all seeds in all frames'
          RemoveAllSeeds(1:nFrames);
      case {'add selected star to segmentation ground truth', ...
              'add all stars in frame to segmentation ground truth', ...
              'add all stars in all frames to segmentation ground truth', ...
              'add selected star to segmentation ground truth for parameter learning', ...
              'add all stars in frame to segmentation ground truth for parameter learning', ...
              'add all stars in all frames to segmentation ground truth for parameter learning' ...
              }
          if ~strcmp(csui.session.states.Editor.channel, 'segmentsColorMasked')
              disp('You can add stars to ground truth only in the segments channel');
          else
              if any(strcmp(action, {'add selected star to segmentation ground truth', 'add selected star to segmentation ground truth for parameter learning'})) && ...
                 ~EditorSegmentIsSelected()
                  disp('No segment selected.');
              else
                  if ~any(strcmp(action, {'add all stars in all frames to segmentation ground truth', 'add all stars in all frames to segmentation ground truth for parameter learning'}))
                      sf = currFrame;
                  else
                      sf = 1:length(csui.session.parameters.files.imagesFiles);
                  end
                  ss = csui.session.states.Editor.selectedSegment;
                  
                  currTime = now();

                  EditorFixNewSeedsField();
                  
                  selectedSegment = -1;
                  if EditorSegmentIsSelected()
                      selectedSegment = csui.session.states.Editor.selectedSegment;
                      EditorDeselectSegment();
                  end
                  
                  gtIgnore = ~any(strcmp(action, {'add selected star to segmentation ground truth for parameter learning', ...
                                                  'add all stars in frame to segmentation ground truth for parameter learning', ...
                                                  'add all stars in all frames to segmentation ground truth for parameter learning'}));
                  
                  added = 0;
                  modified = 0;
                  
                  for f = 1:length(sf)
                      if ~any(strcmp(action, {'add selected star to segmentation ground truth', 'add selected star to segmentation ground truth for parameter learning'}))
                          ss = 1:length(csui.segBuf{sf(f)}.snakes);
                      end

                      for i = 1:length(ss)
                          currSnake = csui.segBuf{sf(f)}.snakes{ss(i)};
                          currSeedN = length(csui.segBuf{sf(f)}.newSeeds) + 1;
                          if ~StarGroundTruth(currSnake)
                               currSnake.groundTruth = true;
                               currSnake.groundTruthIgnore = gtIgnore;
                               currSnake.rank = -currTime;
                               added = added + 1;

                               csui.segBuf{sf(f)}.newSeeds{currSeedN}.seed = currSnake.seed;
                               csui.segBuf{sf(f)}.newSeeds{currSeedN}.star = currSnake;
                               csui.segBuf{sf(f)}.newSeeds{currSeedN}.contour = [];

                               if (sf(f) == currFrame)
                                   EditorPlotSeed(currSeedN);
                               end

                               DeleteSegment(ss(i), sf(f));
                          else
                              if ~isfield(csui.segBuf{sf(f)}.snakes{ss(i)}, 'groundTruthIgnore') || (csui.segBuf{sf(f)}.snakes{ss(i)}.groundTruthIgnore ~= gtIgnore)
                                  csui.segBuf{sf(f)}.snakes{ss(i)}.groundTruthIgnore = gtIgnore;
                                  modified = modified + 1;
                                  ClearImageBuffer('segmentsColor', sf(f));
                                  ClearImageBuffer('segmentsColorMasked', sf(f));
                                  DeleteImage('segmentsColor', sf(f));
                                  DeleteSegmentation(sf(f));
                              end
                          end
                      end
                  end
                  
                  if (added + modified > 0)
                      EditorStopEditingLastSeed();
                      ShowEditor();
                  end
                  if (added == 0) && (selectedSegment > 0)
                      SelectSegment(selectedSegment);
                  end
                  
                  disp(['Added ' num2str(added) ' stars to ground truth and modified ' num2str(modified) ' existing ground truth stars.']);
              end
          end
      case 'toggle ignoring selected ground truth for parameter learning'
          if ~strcmp(csui.session.states.Editor.channel, 'segmentsColorMasked')
              disp('You can modify segmentation ground truth only in the segments channel');
          else
              if ~EditorSegmentIsSelected()
                  disp('No segment selected.');
              else
                  currSeg = csui.segBuf{currFrame}.snakes{csui.session.states.Editor.selectedSegment};
                  if ~StarGroundTruth(currSeg)
                      disp('Selected segment is not part of ground truth.');
                  else
                      if isfield(currSeg, 'groundTruthIgnore') && currSeg.groundTruthIgnore
                          csui.segBuf{currFrame}.snakes{csui.session.states.Editor.selectedSegment}.groundTruthIgnore = false;
                      else
                          csui.segBuf{currFrame}.snakes{csui.session.states.Editor.selectedSegment}.groundTruthIgnore = true;
                      end
                      ClearImageBuffer('segmentsColor', currFrame);
                      ClearImageBuffer('segmentsColorMasked', currFrame);
                      DeleteImage('segmentsColor', currFrame);
                      DeleteSegmentation(currFrame);
                      ShowEditor();
                  end
              end
          end
      case 'import ground truth seeds from CSV file'
          disp('Select CSV file to import segmentation grond truth...');
          [f, p, ~] = uigetfile(fullfile(csui.session.parameters.files.destinationDirectory, '*.csv'), 'Select CSV file to import segmentation GT');
          if ischar(f)
              try
                  disp('Importing, it will take some time...');
                  ImportGroundTruthFromCSV(fullfile(p, f));
                  UILogAction(['% ImportGroundTruthFromCSV(''' fullfile(p, f) ''');']);
              catch
                  disp('Error importing data...');
              end
          else
              disp('Canceling...');
          end
          
      case {'connect selected segment to trace in next frame', ...
             'connect selected segment to trace in previous frame'} 
          if ~EditorSegmentIsSelected()
              disp('No segment selected.');
          else
              if (strcmp(action, 'connect selected segment to trace in next frame') && (currFrame == nFrames)) ...
                      || (strcmp(action, 'connect selected segment to trace in previous frame') && (currFrame == 1))
                  disp('Cannot go there.');
              else
                  StartTrackingGTAction();
                  disp('Select segment to connect traces...');
                  if strcmp(action, 'connect selected segment to trace in next frame')
                      LoadNextFrame();
                  else
                      LoadPreviousFrame();
                  end
              end
          end
      case 'trace for selected segment starts here'
           if EditorSegmentIsSelected()
               ModifyTrackingGroundTruth('start');
           else
               disp('No segment selected.');
           end
      case 'trace for selected segment ends here'
           if EditorSegmentIsSelected()
               ModifyTrackingGroundTruth('end');
           else
               disp('No segment selected.');
           end
      case 'remove tracking ground truth for selected segment'
          ModifyTrackingGroundTruth('remove');
      case { 'next frame', 'mouseWheelUp' }
          LoadNextFrame();
          if strcmp(action, 'next frame')
              disp('You can also use mouse wheel to switch frames.');
          end
      case {'previous frame', 'mouseWheelDown' }
          LoadPreviousFrame();
          if strcmp(action, 'previous frame')
              disp('You can also use mouse wheel to switch frames.');
          end
      case 'go forward 5 frames'
          LoadNextFrame(5);
      case 'jump to last frame'
          LoadFrame(nFrames);
      case 'go back 5 frames'
          LoadPreviousFrame(5);
      case 'jump to first frame'
          LoadFrame(1);
      case 'choose frame to jump to'
          f = inputdlg([ 'Insert frame number (1-' num2str(nFrames) ]);
          if isempty(f)
              disp('Canceling...');
          else
              LoadFrame(str2double(f));
          end
      case 'preload (and save) all frames for current channel'
          ApplyAllChanges();
          fprintf('Preloading (and possibly saving to disk) all the images in the channel %s, this will take a while...\n', csui.session.states.Editor.channel);
          channel = csui.session.states.Editor.channel;
          for i = 1:nFrames
              ImageFromBuffer(channel, i);
              UISaveImageToDisk(channel, i, 'skipIfFileExists');
          end
      case 'show-hide all seeds placed automatically'
          csui.session.states.Editor.showAllSeeds = ~csui.session.states.Editor.showAllSeeds;
          ShowHideAllSeeds();
      case { 'toggle original image (clean)', 'toggle original image', ...
              'toggle foreground mask', 'toggle cell border image', ...
              'toggle cell content image', 'toggle cell content mask', ...
              'toggle current additional (fluorescence) channel', ...
              'toggle segments image', 'toggle tracking image' }
          switch action
              case 'toggle original image (clean)'
                  newChannel = 'originalClean';
              case 'toggle original image' 
                  newChannel = 'original';
              case 'toggle cell border image'
                  newChannel = 'brighter';
              case 'toggle cell content image'
                  newChannel = 'darker';
              case 'toggle cell content mask'
                  newChannel = 'cellContentMask';
              case 'toggle foreground mask'
                  newChannel = 'foregroundMask';
              case 'toggle current additional (fluorescence) channel'
                  newChannel = 'additional';
              case 'toggle segments image'
                  newChannel = 'segmentsColorMasked';
              case 'toggle tracking image'
                  newChannel = 'trackingMasked';
                  UILoadTrackingIfNeeded();
          end
          SetNewChannel(newChannel);
          if any(strcmp(csui.session.states.Editor.channel, {'tracking', 'trackingMasked'}))
              PlotTrackingGroundTruth();
          else
              HideTrackingGroundTruth();
          end
          ShowEditor();
      case {'plot fluorescence graph of all traces', ...
            'plot fluorescence graph of selected trace', ...
            'store fluorescence in a variable', ...
            'export fluorescence to a csv file'}
          ApplyAllChanges();
          UILoadTrackingIfNeeded();
          UIComputeFluorescenceIfNeeded(1:nFrames);
          nChans = length(parameters.files.additionalChannels);
          switch action
               case {'plot fluorescence graph of all traces', ...
                     'plot fluorescence graph of selected trace'}
                   for i = 1:nChans
                       if strcmp(action, 'plot fluorescence graph of selected trace')
                           if EditorSegmentIsSelected()
                                 PlotFluorescence(i, csui.session.states.Editor.selectedSegment);
                           else
                               disp('No segment selected, cannot plot fluorescence graph.');
                           end
                       else
                           PlotFluorescence(i);
                       end
                   end
               case 'store fluorescence in a variable'
                   EditorStoreFluorescence();
               case 'export fluorescence to a csv file'
                   disp('Select file name to export fluorescence...');
                   [f, p] = uiputfile( ...
                               fullfile(csui.session.parameters.files.destinationDirectory, ...
                                        csui.session.parameters.tracking.folder, ...
                                        'fluorescence.csv'), ...
                               'Select file name to export fluorescence...');
                   if isnumeric(f)
                       disp('Canceling...');
                   else
                      EditorExportFluoToCSV(fullfile(p, f));
                   end
          end
          ShowEditor();
      case 'toggle tracking numbers'
          if any(strcmp(csui.session.states.Editor.channel, {'tracking', 'trackingMasked'}))
              UILoadTrackingIfNeeded();
              ClearImageBuffer('tracking', 1:nFrames);
              ClearImageBuffer('trackingMasked', 1:nFrames);
              DeleteImage('tracking', 1:nFrames);
              csui.session.states.Editor.showTrackingNumbers = ~csui.session.states.Editor.showTrackingNumbers;
              disp('Toggling tracking numbers...');
              ShowEditor();
          else
              disp('To toggle numbers, you must be on the tracking channel.');
          end
      case 'switch to next additional (fluorescence) channel'
          oldChan = csui.session.states.Editor.currentAdditionalChannel;
          nChans = length(parameters.files.additionalChannels);
          if (nChans == 1) && strcmp(csui.session.states.Editor.channel, 'additional')
              disp('Only one additional channel available.');
          else
              if oldChan < nChans
                  csui.session.states.Editor.currentAdditionalChannel = oldChan + 1;
              else
                  csui.session.states.Editor.currentAdditionalChannel = 1;
              end
              fprintf('Current additional channel: %d.\n', csui.session.states.Editor.currentAdditionalChannel);
              if ~strcmp(csui.session.states.Editor.channel, 'additional')
                  csui.session.states.Editor.previousChannel = csui.session.states.Editor.channel;
                  csui.session.states.Editor.channel = 'additional';
              end
              ShowEditor();
          end
      case 'set segmentation+tracking stubbornness'
          shift = 2;
          precList = cellfun(@num2str, num2cell((1:16)+shift), 'UniformOutput', false);
          precJava = listdlg('PromptString', 'Select stubbornness:', 'ListString', precList, 'SelectionMode', 'Single');
          if ~isempty(precJava)
              precision = precJava(1) + shift;
              disp([ 'Setting stubbornness to ' num2str(precision) '.' ]);
              csui.session.parameters = ParametersFromSegmentationPrecision(csui.session.parameters, precision);
              UILogAction([ '% csui.session.parameters = ParametersFromSegmentationPrecision(csui.session.parameters, ' num2str(precision) ');' ]);
              disp('You may now optimize star contour parameters with automatic tuning.');
          else
              disp('Canceling...');
          end
      case {'automatically tune contour parameters (quick search)', ...
            'automatically tune contour parameters (standard search)', ...
            'automatically tune contour parameters (extensive search)'}
        
            if ((exist('matlabpool', 'file') == 2) && (matlabpool('size') > 0))
              choice = questdlg('Matlab pool is open, this may cause issues. Proceed anyway?', 'Warning', 'Proceed', 'Close pool and proceed', 'Cancel', 'Cancel');
            else
                choice = 'Proceed';
            end
            if any(strcmp(choice, {'Proceed', 'Close pool and proceed'}))
                if strcmp(choice, 'Close pool and proceed')
                    matlabpool close
                end
                switch action
                  case 'automatically tune contour parameters (quick search)'
                      broadness = 0.01;
                  case 'automatically tune contour parameters (standard search)'
                      broadness = 0.1;
                  case 'automatically tune contour parameters (extensive search)'
                      broadness = 1;
                end
            %           optStarParams = OptimizeStarParameters(broadness);
                OptimizeStarParameters(broadness);
            %           if ~isempty(optStarParams)
            %               csui.session.parameters.segmentation.stars = optStarParams;
            %           end
            end
      case {'automatically tune ranking parameters (quick search)', ...
            'automatically tune ranking parameters (standard search)', ...
            'automatically tune ranking parameters (extensive search)'}
            if ((exist('matlabpool', 'file') == 2) && (matlabpool('size') > 0))
              choice = questdlg('Matlab pool is open, this may cause issues. Proceed anyway?', 'Warning', 'Proceed', 'Close pool and proceed', 'Cancel', 'Cancel');
            else
                choice = 'Proceed';
            end
            if any(strcmp(choice, {'Proceed', 'Close pool and proceed'}))
              if strcmp(choice, 'Close pool and proceed')
                  matlabpool close
              end
              switch action
                case 'automatically tune ranking parameters (quick search)'
                    broadness = 0.1;
                case 'automatically tune ranking parameters (standard search)'
                    broadness = 0.3;
                case 'automatically tune ranking parameters (extensive search)'
                    broadness = 1;
              end
    %           optRankParams = OptimizeRankingParameters(broadness);
                OptimizeRankingParameters(broadness);
    %           if ~isempty(optRankParams)
    %               csui.session.parameters.segmentation.ranking = optRankParams;
    %           end
            end
      case 'stars contour: reset parameters to default'
          dp = DefaultParameters();
          disp('Resetting parameters for stars contour to default.');
          csui.session.parameters.segmentation.stars = dp.segmentation.stars;
      case {'stars ranking: change maximum allowed rank', ...
            'stars: change maximum allowed area', ...
            'stars: change minimum allowed area' }
          switch action
              case 'stars ranking: change maximum allowed rank'
                    oldT = num2str (csui.session.parameters.segmentation.ranking.maxRank);
                    dialogMsg = 'maximum allowed rank';
              case 'stars: change maximum allowed area'
                    oldT = num2str (csui.session.parameters.segmentation.maxArea);
                    dialogMsg = 'maximum allowed area';
              case 'stars: change minimum allowed area'
                    oldT = num2str (csui.session.parameters.segmentation.minArea);
                    dialogMsg = 'minimum allowed area';
          end
          cct = inputdlg (['Insert new valued for ' dialogMsg ':'], dialogMsg , 1, { oldT });
          if (isempty (cct))
              disp ('Canceling...');
          else
              switch action
                  case 'stars ranking: change maximum allowed rank'
                        csui.session.parameters.segmentation.ranking.maxRank = str2double(cct);
                        UILogAction(['% csui.session.parameters.segmentation.ranking.maxRank = ' num2str(csui.session.parameters.segmentation.ranking.maxRank) ';']);
                  case 'stars: change maximum allowed area'
                        csui.session.parameters.segmentation.maxArea = str2double(cct);
                        UILogAction(['% csui.session.parameters.segmentation.maxArea = ' num2str(csui.session.parameters.segmentation.maxArea) ';']);
                  case 'stars: change minimum allowed area'
                        csui.session.parameters.segmentation.minArea = str2double(cct);
                        UILogAction(['% csui.session.parameters.segmentation.minArea = ' num2str(csui.session.parameters.segmentation.minArea) ';']);
              end
              UILoadSegmentationIfNeeded(1:nFrames);
              PrintMsg(parameters.debugLevel, 3, 'Filtering cells according to new value, it may take some time...');
              
              for f = 1:nFrames
                  for s = 1:length(csui.segBuf{f}.snakes);
                      avgArea = pi * 0.25 * csui.session.parameters.segmentation.avgCellDiameter^2;
                      switch action
                          case 'stars ranking: change maximum allowed rank'
                              deleteCell = (csui.segBuf{f}.snakes{s}.rank > csui.session.parameters.segmentation.ranking.maxRank);
                          case 'stars: change maximum allowed area'
                              deleteCell = (csui.segBuf{f}.snakes{s}.segmentProps.area > csui.session.parameters.segmentation.maxArea * avgArea);
                          case 'stars: change minimum allowed area'
                              deleteCell = (csui.segBuf{f}.snakes{s}.segmentProps.area < csui.session.parameters.segmentation.minArea * avgArea);
                      end
                      if deleteCell
                          DeleteSegment(s, f);
                      else
                          UndeleteSegment(s, f);
                      end
                  end
              end
              ShowEditor();
          end
      case 'stars ranking: reset parameters to default'
          dp = DefaultParameters();
          disp('Resetting parameters for stars contour to default.');
          csui.session.parameters.segmentation.ranking = dp.segmentation.ranking;
      case {  '(re)do segmentation and tracking for current frame', ...
              '(re)do tracking for current frame', ...
              '(re)do segmentation for current frame', ...
              '(re)do segmentation and tracking for all frames', ...
              '(re)do tracking for all frames', ...
              '(re)do segmentation for all frames', ...
              'select frames for which to (re)do segmentation and tracking', ...
              'select frames for which to (re)do tracking', ...
              'select frames for which to (re)do segmentation'  }
          switch action
              case '(re)do segmentation and tracking for current frame'
                  st = 'segmentation and tracking';
                  frames = currFrame;
              case '(re)do tracking for current frame'
                  st = 'tracking';
                  frames = currFrame;
              case '(re)do segmentation for current frame'
                  st = 'segmentation';
                  frames = currFrame;
              case '(re)do tracking for all frames'
                  st = 'tracking';
                  frames = 1:nFrames;
              case '(re)do segmentation for all frames'
                  st = 'segmentation';
                  frames = 1:nFrames;
              case '(re)do segmentation and tracking for all frames'
                  st = 'segmentation and tracking';
                  frames = 1:nFrames;
              case 'select frames for which to (re)do tracking'
                  st = 'tracking';
                  frames = -1;
              case 'select frames for which to (re)do segmentation'
                  st = 'segmentation';
                  frames = -1;
              case 'select frames for which to (re)do segmentation and tracking'
                  st = 'segmentation and tracking';
                  frames = -1;
          end

          if ((exist('matlabpool', 'file') == 2) && (matlabpool('size') == 0))
              choice = questdlg(['(Re)doing ' st ' may take a long time, and Matlab pool is closed.'], 'Warning', 'Proceed', 'Open pool and proceed', 'Cancel', 'Cancel');
          else
              choice = questdlg([ '(Re)doing ' st ' may take a long time. Continue?' ], 'Warning', 'Proceed', 'Cancel', 'Cancel');
          end
          if any(strcmp(choice, {'Proceed', 'Open pool and proceed'}))
              if strcmp(choice, 'Open pool and proceed')
                  matlabpool
              end
              applyLog = false;
              if (frames == -1)
                  frameList = cellfun(@num2str, num2cell(1:nFrames), 'UniformOutput', false);
                  framesJava = listdlg('PromptString', 'Select frames:', 'ListString', frameList, 'SelectionMode', 'Multiple');

                  if ~isempty(framesJava)
                      % octave...
                      frames = [];
                      for i =length(framesJava):-1:1
                          frames(i) = framesJava(i);
                      end
                  end
                  applyLog = true;
              end
              if ~isempty(frames) && ((length(frames) > 1) || (frames ~= -1))
                  EditorDeselectSegment();
                  EditorDeleteCurrentFrameHandles();
                  switch st
                      case 'tracking'
                          DoFullTracking(frames);
                          % Code duplication!
                          if applyLog
                              UILogAction([ '% DoFullTracking([' num2str(frames(:)') ']);' ]);
                          end
                      case 'segmentation'
                          DoFullSegmentation(frames);
                          if applyLog
                              UILogAction([ '% DoFullSegmentation([' num2str(frames(:)') ']);' ]);
                          end
                      case 'segmentation and tracking'
                          DoFullSegmentationAndTracking(frames);
                          if applyLog
                              UILogAction([ '% DoFullSegmentationAndTracking([' num2str(frames(:)') ']);' ]);
                          end
                  end
                  EditorPlotCurrentFrameObjects();
                  ShowEditor();
              else
                  disp('Canceling...');
              end
          else
              disp('Canceling...');
          end
      case 'apply changes quickly'
          disp('Applying changes quickly...');
          EditorDeselectSegment();
          ApplySegmentationChanges(true);
          ShowEditor();
      case 'apply changes properly'
          EditorDeselectSegment();
          ApplyAllChanges();
          SaveSegmentationIfNeeded();
          UISaveTrackingIfNeeded();
          ShowEditor();
      case { 'list unresolved tracking problems', ...
              'list all tracking problems', ...
              'jump to next unresolved problem' }
          problems = UIFindTrackingProblems();
          solved = cellfun(@(x)x.solved, problems);
          nsProblems = problems(~solved);
          switch action
              case 'list unresolved tracking problems'
                  ListProblems(nsProblems);
              case 'list all tracking problems'
                  ListProblems(problems);
              case 'jump to next unresolved problem'
                  if any(~solved)
                      p = GetNextProblem(nsProblems);
                      if (currFrame ~= nsProblems{p}.frame)
                          LoadFrame(nsProblems{p}.frame);
                      end
                      SelectSegment(csui.trackingBuf.tracking.traces(nsProblems{p}.trace, nsProblems{p}.frame));
                      disp('Jumped to problem:');
                      PrintProblem(nsProblems{p});
                  else
                      disp('No problem to jump to.');
                  end
          end
          drawnow();
      case {'apply changes and return to main menu', 'apply changes and go to background editor'}
          ApplyAllChanges();
          SaveSegmentationIfNeeded();
          UISaveTrackingIfNeeded();
          EditorDeleteCurrentFrameHandles();
          if strcmp(action, 'apply changes and go to background editor')
              ChangeState('BackgroundEditor');
          else
              ChangeState('MainMenu');
          end
      case 'set debug level'
          SetDebugLevel();
      case 'close request'
%           UIReset();
          disp('If you are trying to quit, press "h" for help.');
      case 'reset user interface'
          UIReset ();
      case {'close', 'apply changes and quit'}
          ApplyAllChanges();
          SaveSegmentationIfNeeded();
          EditorDeleteCurrentFrameHandles();
          UISaveTrackingIfNeeded();
          Quit();
      otherwise
          if ~isempty(action)
              disp(['Action "' action '" not implemented']);
          end
  end
end


function LoadFrame(frame)
  global csui;
  parameters = csui.session.parameters;
  nFrames = length(parameters.files.imagesFiles);
  if (frame < 1) && (csui.session.states.Editor.currentFrame == 1)
      disp('You are at the first frame.')
  elseif (frame > nFrames) && (csui.session.states.Editor.currentFrame == nFrames)
      disp('You are at the last frame.')
  elseif (frame == csui.session.states.Editor.currentFrame)
      disp('You are already on that frame.')
  else
      if (frame < 1)
          frame = 1;
      end
      if (frame > nFrames)
          frame = nFrames;
      end
      
      EditorDeselectSegment();
      EditorStopEditingLastSeed();
      EditorDeleteCurrentFrameHandles();

      csui.session.states.Editor.currentFrame = frame;
      
      EditorPlotCurrentFrameObjects();
      
      ShowEditor();
  end
end

function LoadNextFrame(varargin)
    global csui;
    if isempty(varargin)
        jump = 1;
    else
        jump = varargin{1};
    end
    frame = csui.session.states.Editor.currentFrame + jump;
    LoadFrame(frame);
end

function LoadPreviousFrame(varargin)
    global csui;
    if isempty(varargin)
        jump = 1;
    else
        jump = varargin{1};
    end
    frame = csui.session.states.Editor.currentFrame - jump;
    LoadFrame(frame);
end

function SetNewChannel(newChannel)
  global csui;
  if strcmp(csui.session.states.Editor.channel, newChannel)
      csui.session.states.Editor.channel = csui.session.states.Editor.previousChannel;
      csui.session.states.Editor.previousChannel = newChannel;
  else
      csui.session.states.Editor.previousChannel = csui.session.states.Editor.channel;
      csui.session.states.Editor.channel = newChannel;
  end
end

function DoFullSegmentation(frames)
   global csui;
   parameters = csui.session.parameters;
   
   if isempty(frames)
       return
   end


   disp('Applying segmentation...');
   
   UILoadSegmentationIfNeeded(frames);
   ApplySegmentationChanges();
   SaveSegmentationIfNeeded();
   InvalidateTracking();
   
   for i=1:length(frames)
      f = frames(i);

      DeleteStuffToModifySegmentation(f);
      csui.segBuf{f}.allSeeds = [];
      csui.segBuf{f}.snakes = ExtractGTSnakes(csui.segBuf{f}.snakes);
      csui.segBuf{f}.fluorescence = [];

      UISegmentFrame(f);
      UIComputeConnectivity(f);
      UISaveSegmentation(f);
   end
   
   UILoadTrackingIfNeeded();
   if ~isempty(csui.trackingBuf.tracking)
       DoFullTracking(frames);
   end
end

function DoFullTracking(frames)
   global csui;
   parameters = csui.session.parameters;
   nFrames = length(parameters.files.imagesFiles);

   UISaveTrackingGroundTruth();
   UILoadTrackingIfNeeded();
   
   ApplySegmentationChanges();
   SaveSegmentationIfNeeded();

   UIResetFluorescence();

   disp('Applying tracking...');
   if ~isempty(csui.trackingBuf.tracking) && (length(frames) < nFrames)
       UIComputeTracking(frames);
       UISaveTrackingIfNeeded();
   else
       disp('Computing full tracking, it will take some time...');
       UISaveTrackingGroundTruth();
       DoTrackingFromScratch();
   end
end

function DoFullSegmentationAndTracking(frames)
   global csui;
   DoFullSegmentation(frames);
   if isempty(csui.trackingBuf.tracking)
       DoFullTracking(frames);
   end
end

function DoTrackingFromScratch()
    global csui;
    UISaveTrackingGroundTruth();
    parameters = csui.session.parameters;
    nFrames = length(parameters.files.imagesFiles);
    doSeg = false(1, nFrames);
    for i = 1:nFrames
        fileNames = OutputFileNames(i, parameters);
        segmentationFile = fileNames.segmentation;
        if ~exist(segmentationFile, 'file')
            if UISegmentationIsLoaded(i)
                UISaveSegmentation(i);
            else
                doSeg(i) = true;
            end
        end
    end
    InvalidateTracking();
    DoFullSegmentation(find(doSeg));
    csui.trackingBuf.tracking = ComputeFullTracking(csui.session.parameters);
    csui.trackingBuf.needsFullTracking = [];
    SaveResult(csui.trackingBuf.tracking, 'tracking.csv', parameters);
end


function MouseButtonPressed(button, mouseClick)
   global csui;
   
   currFrame = csui.session.states.Editor.currentFrame;
   segments = ImageFromBuffer('segments', csui.session.states.Editor.currentFrame);
   x = round(mouseClick.x);
   y = round(mouseClick.y);
   if ~isempty(segments) && ...
           (size(segments, 1) >= y) && ...
           (size(segments, 2) >= x) && ...
           (y > 0) && (x > 0)

       newSelectedSegment = segments(y, x);
       if (newSelectedSegment == 0)
           newSelectedSegment = [];
       end
   else
       newSelectedSegment = [];
   end
   
   if (button == 1)
       if ~csui.session.states.Editor.editingLastSeed && ...
           (isempty(newSelectedSegment) && ~EditorSegmentIsSelected()) || ...
               (EditorSegmentIsSelected() && ~isempty(newSelectedSegment) && ...
               (newSelectedSegment == csui.session.states.Editor.selectedSegment))
           EditorDeselectSegment();
           EditorAddSeed(mouseClick);
       else
           if (isempty(newSelectedSegment) || any(csui.segBuf{currFrame}.deletedSegments == newSelectedSegment))
               if (~EditorSegmentIsSelected()) && ~csui.session.states.Editor.editingLastSeed
                   EditorAddSeed(mouseClick);
               elseif csui.session.states.Editor.editingLastSeed
                   EditorStopEditingLastSeed();
               end
               EditorDeselectSegment();
           else
               SelectSegment(newSelectedSegment);
           end
       end
   else
       if ~EditorSegmentIsSelected() && ...
           ~csui.session.states.Editor.editingLastSeed
           if any(strcmp(csui.session.states.Editor.channel, {'segmentsColorMasked', 'trackingMasked'}))
               if ~isempty(newSelectedSegment)
                   if any(csui.segBuf{currFrame}.deletedSegments == newSelectedSegment)
                       UndeleteSegment(newSelectedSegment, csui.session.states.Editor.currentFrame);
                   else
                       DeleteSegment(newSelectedSegment, csui.session.states.Editor.currentFrame);
                   end
                   ShowEditor();
               else
                   disp('No segment there...');
               end
           else
               disp('You can delete segments only in the segments or tracking channel.');
           end
       else
           EditContour(mouseClick);
       end
   end
   StopTrackingGTAction(false);
end


function DeleteSegment(segment, frame)
    DeleteUndeleteSegment(segment, 'delete', frame)
end

function UndeleteSegment(segment, frame)
    DeleteUndeleteSegment(segment, 'undelete', frame)
end

function DeleteUndeleteSegment(segment, deleteOrUndelete, frame)
    global csui;

    if (isempty(segment) || (segment == 0))
%         disp('No frame to delete');
        return
    end
    
    deletedSegmentsMask = GetImBuf('deletedSegmentsMask', frame);
    segments = ImageFromBuffer('segments', frame);
    
    if ~isfield(csui.segBuf{frame}, 'deletedSegments')
        csui.segBuf{frame}.deletedSegments = [];
    end
    
    if isempty(deletedSegmentsMask)
        ComputeDeletedSegmentsMask(frame);
        deletedSegmentsMask = GetImBuf('deletedSegmentsMask', frame);
    end
    
    if strcmp(deleteOrUndelete, 'delete')
        if ~any(csui.segBuf{frame}.deletedSegments == segment)
            csui.segBuf{frame}.deletedSegments = ...
                [ csui.segBuf{frame}.deletedSegments segment ];

            deletedSegmentsMask(segments == segment) = true;

            SetImBuf(deletedSegmentsMask, 'deletedSegmentsMask', frame);
            ClearImageBuffer('segmentsColorMasked', frame);
            ClearImageBuffer('trackingMasked', frame);
        end
    else
        dmask = (csui.segBuf{frame}.deletedSegments == segment);
        if any(dmask)
            csui.segBuf{frame}.deletedSegments = ...
                csui.segBuf{frame}.deletedSegments(~dmask);
            
            deletedSegmentsMask(segments == segment) = false;
        
            SetImBuf(deletedSegmentsMask, 'deletedSegmentsMask', frame);
            ClearImageBuffer('segmentsColorMasked', frame);
            ClearImageBuffer('trackingMasked', frame);
        end
    end
end


function SelectSegment(newSelectedSegment)
    global csui;
    if newSelectedSegment == 0
        newSelectedSegment = [];
    end
    EditorDeselectSegment();
    
    if ~isempty(newSelectedSegment)
        EditorStopEditingLastSeed();
    else
        return
    end
    csui.session.states.Editor.selectedSegment = newSelectedSegment;
    currFrame = csui.session.states.Editor.currentFrame;
    avgArea = pi * 0.25 * csui.session.parameters.segmentation.avgCellDiameter^2;
    snake = csui.segBuf{currFrame}.snakes{newSelectedSegment};
    maxSeg = length(csui.segBuf{currFrame}.snakes);
    evalin('base', 'UISelectedSegmentVar');
    if StarGroundTruth(snake)
        rankString = ['created: ' datestr(-snake.rank) ];
    else
        rankString = [ 'rank: ' num2str(snake.rank) ];
    end
    if IsSubField(csui, {'trackingBuf', 'tracking', 'traces'})
        trace = find(csui.trackingBuf.tracking.traces(:, currFrame) == newSelectedSegment);
        traceS = [ 'trace ' num2str(trace) ];
    else
        traceS = '';
    end
    msg = [ 'Selected ' traceS ' (segment ' num2str(newSelectedSegment) ' of ' num2str(maxSeg) ') with features:\n' ...
               rankString ...
            '   area: ' num2str(snake.segmentProps.area / avgArea) ' i.e. ' num2str(snake.segmentProps.area) ' pixels.\n' ...
            'More properties in the variable "selectedSegment".\n' ];
    fprintf(1, msg);
    
    EditorDrawSelectedSegment();
    
    if TrackingActionIsStarted()
       if (abs(csui.session.states.Editor.trackingGTAction.frame - currFrame) ~= 1)
             StopTrackingGTAction(false);
       else
             ModifyTrackingGroundTruth('connect');
       end
    end
end


function EditorDeleteCurrentFrameHandles()
    global csui;
    if ~IsSubField(csui, {'handles', 'currentFrame'})
        return
    end
    names = fieldnames(csui.handles.currentFrame);
    for f = 1:length(names)
        n = names{f};
        if iscell(csui.handles.currentFrame.(n))
            for i=1:length(csui.handles.currentFrame.(n))
                DeleteHandles(csui.handles.currentFrame.(n){i});
            end
            csui.handles.currentFrame.(n) = {};
        else
            csui.handles.currentFrame.(n) = DeleteHandles(csui.handles.currentFrame.(n));
        end
    end
end


function EditContour(point)
    global csui;
    currFrame = csui.session.states.Editor.currentFrame;
    if EditorSegmentIsSelected()
        selectedSegment = csui.session.states.Editor.selectedSegment;
        EditorDeselectSegment();
        DeleteSegment(selectedSegment, csui.session.states.Editor.currentFrame);
        
        currSeedN = length(csui.segBuf{currFrame}.newSeeds) + 1;
        
        star = csui.segBuf{currFrame}.snakes{selectedSegment};
        
        star.seed.from = 'mouseedit';
        
        csui.segBuf{currFrame}.newSeeds{currSeedN}.star = [];
        csui.segBuf{currFrame}.newSeeds{currSeedN}.seed = star.seed;
        csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.x = star.x;
        csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.y = star.y;
    end
    
    currSeedN = length(csui.segBuf{currFrame}.newSeeds);

    
    if isempty(csui.segBuf{currFrame}.newSeeds{currSeedN}.contour)
        csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.x = ...
            csui.segBuf{currFrame}.newSeeds{currSeedN}.star.x;
        csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.y = ...
            csui.segBuf{currFrame}.newSeeds{currSeedN}.star.y;
    end
    
    csui.segBuf{currFrame}.newSeeds{currSeedN}.star = [];
   
    if ~isfield(csui.segBuf{currFrame}.newSeeds{currSeedN}.contour, 'groundTruth')
        csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.groundTruth = ... 
            false(size(csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.x));
    end
    
    e = csui.segBuf{currFrame}.newSeeds{currSeedN};

    if IsSubField(csui, {'handles', 'currentFrame', 'seeds'}) && ...
        (length(csui.handles.currentFrame.seeds) >= currSeedN)
        csui.handles.currentFrame.seeds{currSeedN} = ...
            DeleteHandles(csui.handles.currentFrame.seeds{currSeedN});
    end

    csui.segBuf{currFrame}.newSeeds{currSeedN}.contour = ...
        InterpolateContour(e.seed, e.contour, point);
    csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.lastEdited = now();
    
    EditorPlotSeed(currSeedN);
    EditorEditLastSeed();
end


function contour = InterpolateContour(seed, oldContour, newPoint)
   % Naive linear interpolation (in polar coordinates) of star contour 
   % Input: seed with fields x, y representing the center of the star
   %        contour with fields 
   %                 x, y representing the contour;
   %                 groundTruth representing the points fixed by hand;
   %        newPoint with fields x, y is the new point to add to the
   %                 contour groundTruth
   % Output: the new contour with fields x, y, groundTruth


   % identify the point of the contour closest to the new point
   CCenter = [seed.x seed.y];
   MouseP = [newPoint.x newPoint.y];
   d = Inf * ones(size(oldContour.x));
   
   for i = 1:length(oldContour.x)
       ContourI = [ oldContour.x(i) oldContour.y(i) ];
       d(i) = abs(det([CCenter - ContourI; MouseP - ContourI])) / norm(CCenter - ContourI);
       rot = MouseP - CCenter;
       ccross = cross([ rot(2) ( - rot(1))  0 ], [ ContourI - CCenter  0 ]);
       if ccross(3) < 0
           d(i) = Inf;
       end
   end
   idx = find(d == min(d), 1);

   oldPoint = [ oldContour.x(idx) oldContour.y(idx) ];
   newPoint = CCenter + (oldPoint - CCenter) * norm(MouseP - CCenter) / norm(oldPoint - CCenter);
                   
   
   % Interpolate!
   x = oldContour.x(1:end-1);
   y = oldContour.y(1:end-1);
   gt = oldContour.groundTruth(1:end-1);
   if idx == length(x + 1)
       idx = 1;
   end

   x(idx) = newPoint(1);
   y(idx) = newPoint(2);
   gt(idx) = true;
   
   gt2 = [ gt; gt];
   
   mmod = @(n) mod(n - 1, length(x)) + 1;

   C = [ seed.x seed.y];
   
   next1 = find(gt2(idx+1:end), 1);
   dist = min(next1, round(length(x) / 3));
   rS = norm([ x(idx) y(idx)] - C);
   rE = norm([ x(mmod(idx + dist)) y(mmod(idx + dist))] - C);
   for i = (idx + 1) : (idx + dist - 1)
       rdiff = (rE - rS) * (i - idx) / dist;
       currR = rS + rdiff;
       P = [x(mmod(i)) y(mmod(i))];
       P = C + (P - C) * currR / norm(P - C);
       x(mmod(i)) = P(1);
       y(mmod(i)) = P(2);
   end

   prev1 = mmod(find(gt2(1:length(x)+idx-1), 1, 'last'));
   dist = min(mmod(idx - prev1), round(length(x) / 3));
   rS = norm([ x(idx) y(idx)] - C);
   rE = norm([ x(mmod(idx - dist)) y(mmod(idx - dist))] - C);
   for i = (idx - 1) : -1 : (idx - dist + 1)
       rdiff = (rE - rS) * (idx - i) / dist;
       currR = rS + rdiff;
       P = [x(mmod(i)) y(mmod(i))];
       P = C + (P - C) * currR / norm(P - C);
       x(mmod(i)) = P(1);
       y(mmod(i)) = P(2);
   end
   
   contour.x = [x ; x(1)];
   contour.y = [y ; y(1)];
   contour.groundTruth = [gt ; gt(1)];
end

function ApplySegmentationChanges(varargin)
   % Applies changes:
   % - deletes segments marked for deletion
   % - filters stars including the new ones added by mouse click
   % - puts remaining stars by mouse click in ground truth both in
   %   memory and in a separate file
   % Unique optional argument: a boolean telling if the we are applying
   % changes "quickly", which skips channel calculation
   global csui;
   parameters = csui.session.parameters;
   nFrames = length(parameters.files.imagesFiles);
   
   quickly = (~isempty (varargin) && islogical (varargin{1}) && varargin{1});
           
   thereAreChanges = false(1, nFrames);
   
   if ~isfield(csui, 'segBuf')
       csui.segBuf = {};
   end
   
   for f = 1:nFrames
       modB = (length(csui.segBuf) >= f) && (~isempty(csui.segBuf{f}));
       
       if (modB && ~isfield(csui.segBuf{f}, 'newSeeds'))
           csui.segBuf{f}.newSeeds = {};
       end

       if (modB && ~isfield(csui.segBuf{f}, 'deletedSegments'))
           csui.segBuf{f}.deletedSegments = [];
       end

       % TODO FIXME
       % This is not optimal: when applying changes properly, the segments
       % image will be recomputed even if there is only connectivity to be
       % recomputed
       if (modB && ~isfield(csui.segBuf{f}, 'connectivity'))
           csui.segBuf{f}.connectivity = -1;
       end
       
       mod1 = modB && ...
              ~isempty(csui.segBuf{f}.newSeeds);
          
       mod2 = modB && ...
              ~isempty(csui.segBuf{f}.deletedSegments);
                     
       mod3 = modB && ~quickly && ...
                      isnumeric(csui.segBuf{f}.connectivity) && ...
                      ~isempty(csui.segBuf{f}.connectivity) && ...
                      (csui.segBuf{f}.connectivity == -1);
       
       thereAreChanges(f) = mod1 || mod2 || mod3;
   end
   thereAreChanges = find(thereAreChanges);
   if isempty(thereAreChanges)
       return;
   end

   UIResetFluorescence();
   
   InvalidateTracking();
   
   EditorStopEditingLastSeed();
   
   UILoadSegmentationIfNeeded(thereAreChanges);
   DeleteStuffToModifySegmentation(thereAreChanges);
   
   EditorDeleteCurrentFrameHandles();
   
   changedSegBuf = csui.segBuf(thereAreChanges);
   snakesVect = cellfun(@(x)x.snakes, changedSegBuf, 'UniformOutput', false);
   allSeedsVect = cellfun(@(x)DecodeSeeds(x.allSeeds), changedSegBuf, 'UniformOutput', false);
   newSeedsVect = cellfun(@(x)x.newSeeds, changedSegBuf, 'UniformOutput', false);
   deletedSegmentsVect = cellfun(@(x)x.deletedSegments, changedSegBuf, 'UniformOutput', false);
   
   for i = length(thereAreChanges):-1:1
      intermediateImagesVect{i} = ComposeIntermediateImages(thereAreChanges(i));
   end
   
   [snakesVect, segmentsVect, allSeedsVect, segMapVect] = ...
       ApplySegmentationChangesPar(snakesVect, allSeedsVect, newSeedsVect, deletedSegmentsVect, intermediateImagesVect, csui.session.parameters);
   
   for i = 1:length(thereAreChanges)
       f = thereAreChanges(i);
       csui.segBuf{f}.snakes = snakesVect{i};
       csui.segBuf{f}.allSeeds = EncodeSeeds(allSeedsVect{i});
       csui.segBuf{f}.newSeeds = {};
       csui.segBuf{f}.deletedSegments = [];
       csui.segBuf{f}.fluorescence = [];
       SetImBuf(segmentsVect{i}, 'segments', f);
       if (quickly)
          csui.segBuf{f}.connectivity = -1;
       else
          UIComputeConnectivity(f);
       end
       % TODO
       % BUG
       % THIS IS NOT SAFE
       % images might be removed from image buffer before saving them.
       % Moreover, it is not optimal: this way, segmentation get saved
       % several times some of which are not necessary.
       UISaveSegmentation(f);
   end

   EditorPlotCurrentFrameObjects();

   UILoadTrackingIfNeeded();
   
   if ~isfield(csui.trackingBuf, 'needsFullTracking')
       csui.trackingBuf.needsFullTracking = [];
   end
   csui.trackingBuf.needsFullTracking = unique([ csui.trackingBuf.needsFullTracking thereAreChanges]);
   
   UISaveTrackingGroundTruth();
   if ~isempty(csui.trackingBuf.tracking)
        for i = 1:length(thereAreChanges)
            f = thereAreChanges(i);
            segmentation.segments = segmentsVect{i};
            segmentation.segmentsConnectivity = []; % csui.segBuf{f}.connectivity;
            segmentation.snakes = csui.segBuf{f}.snakes;
            csui.trackingBuf.tracking = ...
                PatchTracking(csui.trackingBuf.tracking, f, segmentation, segMapVect{i}.map, segMapVect{i}.newSegments, parameters);
        end
   end
   
end

function DeleteStuffToModifySegmentation(frames)
  ClearImageBuffer('segments', frames);
  ClearImageBuffer('segmentsColor', frames);
  ClearImageBuffer('segmentsColorMasked', frames);
  ClearImageBuffer('deletedSegmentsMask', frames);
  DeleteImage('segmentsColor', frames);

  ClearImageBuffer('connectivity', frames);
  DeleteImage('connectivity', frames);
  DeleteSegmentation(frames);
end


function [snakesVect, segmentsVect, allSeedsVect, segMapVect] = ...
       ApplySegmentationChangesPar(snakesVect, allSeedsVect, newSeedsVect, deletedSegmentsVect, intermediateImagesVect, parameters)
   % TODO: octave parallel version
   parfor i=1:length(snakesVect)
       [snakesVect{i}, segmentsVect{i}, allSeedsVect{i}, segMapVect{i}] = ...
           ApplySegmentationChangesPar1(snakesVect{i}, allSeedsVect{i}, newSeedsVect{i}, deletedSegmentsVect{i}, intermediateImagesVect{i}, parameters);
   end
end

function [snakes, segments, allSeeds, segMap] = ...
           ApplySegmentationChangesPar1(snakes, allSeeds, newSeeds, deletedSegments, intermediateImages, parameters)

    stars = {};   
    for i = length(newSeeds):-1:1
        if isempty(newSeeds{i}.star)
           stars{i}.x = newSeeds{i}.contour.x;
           stars{i}.y = newSeeds{i}.contour.y;
           stars{i}.seed = newSeeds{i}.seed;
           stars{i}.type = 'star';
           stars{i} = CalcSnakeProperties(stars{i}, intermediateImages, parameters.segmentation.ranking, parameters.segmentation.avgCellDiameter, []);
           stars{i}.rank = - newSeeds{i}.contour.lastEdited;
        else
            stars{i} = newSeeds{i}.star;
        end
    end
    
    seeds = cellfun(@(x)x.seed, newSeeds);
    
    if ~isempty(seeds)
        allSeeds = [ seeds allSeeds ];
    end
    
    nOldSegments = length(snakes);

    for i = 1:nOldSegments
       snakes{i}.previousSegmentNumber = i;
    end
    
    if ~isempty(deletedSegments)
        okSnakes = true(size(snakes));
        okSnakes(deletedSegments) = false;
        snakes = snakes(okSnakes);
    end
    
    [snakes, segments] = FilterSnakes(intermediateImages, parameters, [stars snakes]);
    
    % this is needed later for PatchTracking
    segmentsMap = zeros(1, nOldSegments);
    listOfNewSegments = [];
    for i = 1:length(snakes)
      if isfield(snakes{i}, 'previousSegmentNumber') && (snakes{i}.previousSegmentNumber > 0)
          segmentsMap(snakes{i}.previousSegmentNumber) = i;
          snakes{i} = rmfield(snakes{i}, 'previousSegmentNumber');
      else
          listOfNewSegments = [ listOfNewSegments i ];
      end
    end
    segMap.map = segmentsMap;
    segMap.newSegments = listOfNewSegments;
    
end

function SaveSegmentationIfNeeded() 
    % This will not save unapplied segmentation changes, beware!
    global csui;
    nFrames = length(csui.session.parameters.files.imagesFiles);
    for i = 1:nFrames
        fileNames = OutputFileNames(i, csui.session.parameters);
        segmentationFile = fileNames.segmentation;
        if ~exist(segmentationFile, 'file') && ... % trying to avoid useless saving to disk,
                (length(csui.segBuf) >= i) && ...  % a bit more efficient but not "bug-free"
                isfield(csui.segBuf{i}, 'snakes') && ...
                ~isempty(csui.segBuf{i}.snakes)
            UISaveSegmentation(i);
        end
    end
end

function ApplyAllChanges()
  global csui;
  disp('Applying changes if any, it may take some time...');
  ApplySegmentationChanges();
  if IsSubField(csui, {'trackingBuf', 'needsFullTracking'}) && ...
     IsSubField(csui, {'trackingBuf', 'tracking'}) && ~isempty(csui.trackingBuf.tracking)
      UILoadTrackingIfNeeded();
      DoFullTracking(csui.trackingBuf.needsFullTracking);
  end
end

function RemoveLastSeed(frame)
  global csui;
  EditorStopEditingLastSeed();
  currFrame = csui.session.states.Editor.currentFrame;
  if (length(csui.segBuf) >= frame) && ~isempty(csui.segBuf{frame}.newSeeds)
      if (frame == currFrame)
          DeleteHandles(csui.handles.currentFrame.seeds{end});
          csui.handles.currentFrame.seeds = csui.handles.currentFrame.seeds(1:end-1);
      end
      csui.segBuf{frame}.newSeeds = csui.segBuf{frame}.newSeeds(1:end-1);
  else
      disp('No seeds to remove.');
  end
end

function RemoveAllSeedsInFrame(frame)
   global csui;
   if (length(csui.segBuf) >= frame) && isfield(csui.segBuf{frame}, 'newSeeds')
        for i = 1:length(csui.segBuf{frame}.newSeeds)
            RemoveLastSeed(frame);
        end
   end
end

function RemoveAllSeeds(frames)
   for i = 1:length(frames)
       RemoveAllSeedsInFrame(frames(i));
   end
end

function UISaveTrackingIfNeeded()
   global csui;
   parameters = csui.session.parameters;
   trackingFolder = fullfile(parameters.files.destinationDirectory, parameters.tracking.folder);
   if IsSubField(csui, {'trackingBuf', 'tracking'}) && ~isempty(csui.trackingBuf.tracking)
       tracking = csui.trackingBuf.tracking;
       filename = fullfile(trackingFolder, 'tracking.mat');
       if ~exist(filename, 'file')
           disp('Saving tracking...');
           CSSave(filename, 'tracking');
           SaveResult(tracking, 'tracking.csv', parameters);
       end
   end
   UISaveTrackingGroundTruth();
end


function s = TrackingActionIsStarted()
    global csui;
    s = csui.session.states.Editor.trackingGTAction.started && ...    
        ~isempty(csui.session.states.Editor.trackingGTAction.segment) && ...
        ~isempty(csui.session.states.Editor.trackingGTAction.frame);
end

function StartTrackingGTAction()
    global csui;
    csui.session.states.Editor.trackingGTAction.started = true;
    csui.session.states.Editor.trackingGTAction.segment = ...
      csui.session.states.Editor.selectedSegment;
    csui.session.states.Editor.trackingGTAction.frame = ...
        csui.session.states.Editor.currentFrame;
end

function StopTrackingGTAction(correctly)
    global csui;
    if (csui.session.states.Editor.trackingGTAction.started) && (~correctly)
        disp('Tracking ground truth action terminated.');
    end
    csui.session.states.Editor.trackingGTAction.started = false;
    csui.session.states.Editor.trackingGTAction.segment = [];
    csui.session.states.Editor.trackingGTAction.frame = [];
end

function ModifyTrackingGroundTruth(action)
   global csui;
   parameters = csui.session.parameters;
   
   UILoadTrackingIfNeeded();
   
   switch action
       case 'connect'
           frame1 = csui.session.states.Editor.trackingGTAction.frame;
           segment1 = csui.session.states.Editor.trackingGTAction.segment;
           frame2 = csui.session.states.Editor.currentFrame;
           segment2 = csui.session.states.Editor.selectedSegment;
           if (frame1 > frame2)
               tmpFrame = frame1;
               tmpSegment = segment1;
               frame1 = frame2;
               segment1 = segment2;
               frame2 = tmpFrame;
               segment2 = tmpSegment;
           end
           segmentMatrix1 = (segment1 == ImageFromBuffer('segments', frame1));
           segmentMatrix2 = (segment2 == ImageFromBuffer('segments', frame2));

           centroid1 = regionprops(segmentMatrix1, 'Centroid');
           centroid2 = regionprops(segmentMatrix2, 'Centroid');

           csui.trackingBuf.groundTruth(end + 1, 1:6) = [ frame1 centroid1.Centroid frame2 centroid2.Centroid ];

           if ~isfield(csui.trackingBuf, 'needsFullTracking')
               csui.trackingBuf.needsFullTracking = [];
           end

           csui.trackingBuf.needsFullTracking = unique([ csui.trackingBuf.needsFullTracking frame1 frame2 ]);

           StopTrackingGTAction(true);
       case {'start', 'end'}
           frame = csui.session.states.Editor.currentFrame;
           segment = csui.session.states.Editor.selectedSegment;
           segmentMatrix = (segment == ImageFromBuffer('segments', frame));
           centroid = regionprops(segmentMatrix, 'Centroid');
           if strcmp(action, 'start')
               csui.trackingBuf.groundTruth(end + 1, 1:6) = [ 0 0 0 frame centroid.Centroid ];
           else
               csui.trackingBuf.groundTruth(end + 1, 1:6) = [ frame centroid.Centroid 0 0 0 ];
           end
           if ~IsSubField(csui, {'trackingBuf', 'needsFullTracking'})
               csui.trackingBuf.needsFullTracking = [];
           end
           csui.trackingBuf.needsFullTracking = unique([ csui.trackingBuf.needsFullTracking frame ]);
       case 'remove'
           frame = csui.session.states.Editor.currentFrame;
           segment = csui.session.states.Editor.selectedSegment;
           segmentMatrix = (segment == ImageFromBuffer('segments', frame));
           removeColumn = false([size(csui.trackingBuf.groundTruth, 1), 1]);
           for i = 1:size(csui.trackingBuf.groundTruth, 1)
               for j = [1 4]
                   if csui.trackingBuf.groundTruth(i, j) == frame
                        if segmentMatrix(round(csui.trackingBuf.groundTruth(i, j + 2)), round(csui.trackingBuf.groundTruth(i, j + 1)))
                            removeColumn(i) = true;
                        end
                   end
               end
           end
           csui.trackingBuf.groundTruth = csui.trackingBuf.groundTruth(find(~removeColumn), :);
           if any (removeColumn')
               if (~IsSubField (csui, {'trackingBuf', 'needsFullTracking'}))
                   csui.trackingBuf.needsFullTracking = [];
               end
               csui.trackingBuf.needsFullTracking = unique([ csui.trackingBuf.needsFullTracking frame ]);
           end
   end
   
   if ~strcmp(action, 'remove')
       PrintMsg(parameters.debugLevel, 4, [ 'Added to tracking ground truth table the line: ' num2str(csui.trackingBuf.groundTruth(end, 1:6)) ' .']);
   end
   CheckTrackingGroundTruthConsistency();
   PlotTrackingGroundTruth();
   InvalidateTracking();
end

function CheckTrackingGroundTruthConsistency()
   global csui;
   % remove entries in the tracking ground truth that are clearly
   % conflicting, keeping the most recent ones
   removeColumn = false(size(csui.trackingBuf.groundTruth, 1), 1);
   for i = 1:size(csui.trackingBuf.groundTruth, 1)
       for j = i + 1:size(csui.trackingBuf.groundTruth, 1)
           for k = [1 4]
               if csui.trackingBuf.groundTruth(i, k) > 0
                   if nnz(csui.trackingBuf.groundTruth(i, k:k+2) == csui.trackingBuf.groundTruth(j, k:k+2)) == 3
                       removeColumn(i) = true;
                   end
               end
           end
       end
   end
   csui.trackingBuf.groundTruth = csui.trackingBuf.groundTruth(find(~removeColumn), :);
end


function problems = UIFindTrackingProblems()
    global csui;
    UILoadTrackingIfNeeded();
    if isempty(csui.trackingBuf.tracking)
        disp('Warning: you should apply tracking at least once before looking for problems.');
    end
    problems = FindTrackingProblems(csui.trackingBuf.tracking, csui.session.parameters);
    for i = 1:length(problems)
        problems{i}.solved = TrackingProblemIsSolved(problems{i}, csui.trackingBuf.tracking, csui.trackingBuf.groundTruth);
    end
end

function solved = TrackingProblemIsSolved(problem, tracking, groundTruth)
    solved = false;
    
    if isempty(groundTruth)
        return
    end
    
    idx = ((groundTruth(:, 1) == 0) & (groundTruth(:, 4) == problem.frame)) | ...
          ((groundTruth(:, 4) == 0) & (groundTruth(:, 1) == problem.frame));
    subGroundTruth = groundTruth(idx, :);
    
    for i = 1:size(subGroundTruth, 1)
        switch problem.type
            case 'appear'
                if (subGroundTruth(i, 1) == 0) && ...
                   (subGroundTruth(i, 4) == problem.frame)
                   segments = ImageFromBuffer('segments', problem.frame);
                   segment = (segments == tracking.traces(problem.trace, problem.frame));
                   if segment(round(subGroundTruth(i, 6)), round(subGroundTruth(i, 5)))
                     solved = true;
                   end
                end
            case 'disappear'
                if (subGroundTruth(i, 4) == 0) && ...
                   (subGroundTruth(i, 1) == problem.frame)
                   segments = ImageFromBuffer('segments', problem.frame);
                   segment = (segments == tracking.traces(problem.trace, problem.frame));
                   if segment(round(subGroundTruth(i, 3)), round(subGroundTruth(i, 2)))
                     solved = true;
                   end
                end
        end
    end
end

function ListProblems(problems)
    if isempty(problems)
        disp('No problem was found.');
        return
    end
    
    fprintf('\nThe following problems were found:\n');
    for i = 1:length(problems)
       PrintProblem(problems{i});
    end
end


function PrintProblem(problem)
   switch problem.type
       case 'appear'
           s = 'too big cell appeared';
       case 'disappear'
           s = 'cell disappeared';
       case 'orphan'
           s = 'orphan cell appeared';
   end
   if isfield(problem, 'solved') && problem.solved
       solved = ' (solved)';
   else
       solved = '';
   end
   msg = [ '  ' s ' in frame ' num2str(problem.frame) ', trace ' num2str(problem.trace) solved ];
   disp(msg);
end

function p = GetNextProblem(problems)
    global csui;

    if isempty(problems)
        p = [];
        return
    end
    
    if ~EditorSegmentIsSelected()
        p = 1; 
        return
    end
    
    currFrame = csui.session.states.Editor.currentFrame;
    currSeg = csui.session.states.Editor.selectedSegment;
    currTrace = find(csui.trackingBuf.tracking.traces(:, currFrame) == currSeg);
    if isempty(currTrace)
        p = 1;
        return
    end
    
    sameFrame = (cellfun(@(x)x.frame, problems) == currFrame);
    sameSeg = (cellfun(@(x)x.trace, problems) == currTrace);
    
    thisProblem = find(sameFrame & sameSeg);
    
    if isempty(thisProblem)
        p = 1;
    elseif (thisProblem == length(problems))
        p = 1;
    else
        p = thisProblem(end) + 1;
    end
end

function DeletePreprocessingImages ()
    global csui;
    nFrames = length (csui.session.parameters.files.imagesFiles);
    chans = { 'originalClean', 'foregroundMask', 'brighterOriginal', ...
      'brighter', 'darkerOriginal', 'darker', 'cellContentMask', ...
      'cleanBlurred', 'segmentsColor', 'segmentsColorMasked', ...
      'tracking', 'trackingMasked', 'connectivity' };
    for i = 1:length (chans)
        DeleteImage (chans{i}, 1:nFrames);
        ClearImageBuffer (chans{i}, 1:nFrames);
    end
end

function UIComputeFluorescenceIfNeeded(frames)
    global csui;

    UILoadSegmentationIfNeeded(frames);

    disp('Computing fluorescence, it may take some time...');
    parameters = csui.session.parameters;
    
    fluorescenceUpdated = false;

    % Update fluorescence
    for frame = frames
        if (~isfield(csui.segBuf{frame}, 'fluorescence') || ...
               isempty(csui.segBuf{frame}.fluorescence)) || ...
               (numel(csui.session.parameters.files.additionalChannels) > numel(csui.segBuf{frame}.fluorescence.validChannels))
            segments = ImageFromBuffer('segments', frame);
            csui.segBuf{frame}.fluorescence = ComputeFluorescence(segments, frame, parameters);
            fluorescenceUpdated = true;
        end
    end

    if   ( ...
           fluorescenceUpdated && ...
           IsSubField(csui, {'trackingBuf', 'tracking', 'traces'}) ...
         ) ...
       || ...
         ( ...
           IsSubField(csui, {'trackingBuf', 'tracking', 'traces'}) && ...
           ( ...
             ~IsSubField(csui, {'trackingBuf', 'tracking', 'fluorescence'}) || ...
             isempty(csui.trackingBuf.tracking.fluorescence) ...
           ) ...
         )

        frames = length(csui.segBuf);
        fluoChans = length(csui.session.parameters.files.additionalChannels);
        segments = max(cellfun(@(x)size(x.fluorescence.matrix, 2), csui.segBuf));

        csui.trackingBuf.tracking.fluorescence = NaN([size(csui.trackingBuf.tracking.traces) fluoChans ]);

        for f = 1:frames
            elems = find(csui.trackingBuf.tracking.traces(:, f));
            for c = 1:fluoChans
                if csui.segBuf{f}.fluorescence.validChannels(c)
		        csui.trackingBuf.tracking.fluorescence(elems, f, c) = ...
		             csui.segBuf{f}.fluorescence.matrix(c, csui.trackingBuf.tracking.traces(elems, f));
                end
            end 
        end
    end

end

function PlotFluorescence(channel, varargin)
    global csui;
    
    if ~isempty(varargin)
        segment = varargin{1};
    else
        segment = [];
    end
    
    nFrames = length (csui.session.parameters.files.imagesFiles);
    
    if ~IsSubField(csui, {'trackingBuf', 'tracking', 'traces'}) || ...
         isempty(csui.trackingBuf.tracking.traces)
        disp('Tracking is empty, cannot plot fluorescence graph...');
        return
    end
    
    figure('Name', ['Fluorescence graph for channel' num2str(channel) ]);
    hold on;
    
    if isempty(segment)
        traces = [];
        disp('Plotting fluorescence for all the traces...');
    else
        traces = find(csui.trackingBuf.tracking.traces(:, csui.session.states.Editor.currentFrame) == segment);
        disp(['Plotting fluorescence for trace ' num2str(traces) '...']);
    end
    
    tracesVect = [setdiff(1:size(csui.trackingBuf.tracking.traces, 1), traces(:)') traces(:)'];
    for i = tracesVect
             if ~isempty(traces)
                 if any(traces == i)
                     color = [1 0 1];
                     lineSpec = 2;
                 else
                     color = [0.8 0.8 0.8];
                     lineSpec = 1;
                 end
             else
                 color = rand([1 3]);
                 lineSpec = 1;
             end
             elems = find(~isnan(csui.trackingBuf.tracking.fluorescence(i, :, channel)));
             plot(elems, csui.trackingBuf.tracking.fluorescence(i, elems, channel), 'Color', color, 'LineWidth', lineSpec);
    end
    hold off;
    drawnow
end

function UIResetFluorescence()
    global csui;
    if (IsSubField(csui, {'trackingBuf', 'tracking'}) && ~isempty(csui.trackingBuf.tracking))
        csui.trackingBuf.tracking.fluorescence = [];
    end
end

function EditorStoreFluorescence()
    global csui;
    if IsSubField(csui, {'trackingBuf', 'tracking', 'fluorescence'})
        evalin('base', 'UIFluorescenceVar');
        disp('Fluorescence is now stored in the matrix fluorescenceMatrix of dimensions traces*frames*fluochannels.');
    else
        disp('Fluorescence on traces has not been calculated: you need to (re)do tracking maybe?');
    end
end

function EditorExportFluoToCSV(fileName)
    global csui;

    if ~IsSubField(csui, {'trackingBuf', 'tracking', 'fluorescence'})
        disp('Fluorescence on traces has not been calculated: you need to (re)do tracking maybe?');
        return
    end
    
    m = csui.trackingBuf.tracking.fluorescence;
    [c, r, l] = meshgrid(1:size(m, 2), 1:size(m, 1), 1:size(m, 3));
    
    elems = find(~isnan(m));
    
    data = [ c(elems(:)) r(elems(:)) l(elems(:)) m(elems(:)) ];

    dlmwrite(fileName, 'Frame_number, Cell_number, Fluorescence_channel, Fluorescence_value', '');
    dlmwrite(fileName, data, '-append');

    disp([ 'Fluorescence data saved to ' fileName ' .']);
    
end


