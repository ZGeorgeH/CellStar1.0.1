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


function BackgroundEditor(action, mouseClick)
  global csui;
  
  parameters = csui.session.parameters;

  if (parameters.segmentation.avgCellDiameter > 0) && (csui.session.states.BackgroundEditor.circleSize <= 0)
      csui.session.states.BackgroundEditor.circleSize = parameters.segmentation.avgCellDiameter / 2;
  end
  
  nFrames = length(parameters.files.imagesFiles);
  switch action
      case { 'mouse1', 'mouse2' }
          bg = ImageFromBuffer('background');
          bgMask = ImageFromBuffer('backgroundMask');
          if isempty(bg)
              errordlg('You need to get a background image before editing the mask');
          elseif (csui.session.states.BackgroundEditor.circleSize <= 0) && (parameters.segmentation.avgCellDiameter <= 0)
              errordlg('You need to set average cell diameter first');
          else
              csui.session.states.BackgroundEditor.showMask = true;
              if (csui.session.states.BackgroundEditor.circleSize <= 0)
                  csui.session.states.BackgroundEditor.circleSize = parameters.segmentation.avgCellDiameter / 2;
              end
              if isempty(bgMask)
                  bgMask = false(size(ImageFromBuffer('background')));
              end
              
              R = csui.session.states.BackgroundEditor.circleSize;
              
              t = linspace(0,2*pi,32)';
              px = double(mouseClick.x) + R .* cos(t);
              py = double(mouseClick.y) + R .* sin(t);

              [maskDot, ~, ~] = OptInPolygon(size(bg), px, py);
              
              if (strcmp(action, 'mouse1') && ~csui.session.states.BackgroundEditor.invertMouseButtons) || ...
                 (strcmp(action, 'mouse2') && csui.session.states.BackgroundEditor.invertMouseButtons)
                  bgMask(logical(maskDot)) = true;
              else
                  bgMask(logical(maskDot)) = false;
              end
              SetImBuf(bgMask, 'backgroundMask');
              ShowBackground();
          end
      case 'return to main menu'
          ChangeState('MainMenu');
      case 'start segmentation-tracking editor'
          ChangeState('Editor');
      case 'load background from file'
          [f, p, ~] = uigetfile(fullfile(csui.session.parameters.files.destinationDirectory, '*.tif;*.png;*.bmp;*.jpg'), action);
          if ischar(f)
              ClearImageBuffer('background');
              csui.session.parameters.files.background.imageFile = fullfile(p, f);
              SaveBackground();
              ShowBackground();
              UILogAction('% ClearImageBuffer(''background'');');
              UILogAction(['% csui.session.parameters.files.background.imageFile = ''' csui.session.parameters.files.background.imageFile ''';']);
              UILogAction('% SaveBackground();');
              UILogAction('% ShowBackground();');
          else
              disp('Canceling...');
          end
      case 'set background as mean brightness of first frame'
          frame1 = ImageFromBuffer('original', 1);
          il = mean(frame1(:));
          UpdateBackground(repmat(il, size(frame1)));
          SaveBackground();
          ShowBackground();
          disp([ 'Background set as average intensity of first frame: ' num2str(il) '.']);
      case 'set background as average of all frames'
          avg = ImageFromBuffer('original', 1);
          for i = 2:nFrames
              avg = avg + double(ImageFromBuffer('original', i));
          end
          avg = avg / nFrames;
          UpdateBackground(avg);
          SaveBackground();
          ShowBackground();
          disp('Background set as average of all frames.');
      case 'select frames to average to compute background'
          frameList = cellfun(@num2str, num2cell(1:nFrames), 'UniformOutput', false);
          framesJava = listdlg('PromptString', 'Select frames:', 'ListString', frameList, 'SelectionMode', 'Multiple');

          if ~isempty(framesJava)
              % octave...
              for i =length(framesJava):-1:1
                  frames(i) = framesJava(i);
              end              
              avg = ImageFromBuffer('original', frames(1));
              for i = 2:length(frames)
                  avg = avg + ImageFromBuffer('original', frames(i));
              end
              avg = avg / length(frames);
              UpdateBackground(avg);
              SaveBackground();
              ShowBackground();
              UILogAction(['% Selected frames: [' num2str(frames(:)') '];']);
              UILogAction('% SaveBackground();');
              UILogAction('% ShowBackground();');
          else
              disp('Canceling...');
          end
      case 'toggle background mask'
          bg = ImageFromBuffer('background');
          bgMask = ImageFromBuffer('backgroundMask');
          if isempty(bg)
              errordlg('You need to get a background image first, to be then smoothed according to the background mask');
          elseif isempty(bgMask) || ~any(~bgMask(:))
              disp('The mask is empty...');
          else
              csui.session.states.BackgroundEditor.showMask = ~csui.session.states.BackgroundEditor.showMask;
              ShowBackground();
          end
      case 'toggle histogram equalization'
          csui.session.states.BackgroundEditor.histogramEqualization = ~csui.session.states.BackgroundEditor.histogramEqualization;
          ShowBackground();
      case 'invert background mask'
          bg = ImageFromBuffer('background');
          bgMask = ImageFromBuffer('backgroundMask');
          if isempty(bg)
              errordlg('You need to get a background image first, to be then smoothed according to the background mask');
          elseif isempty(bgMask) || ~any(~bgMask(:))
              disp('The mask is empty...');
          else
              csui.session.states.BackgroundEditor.showMask = true;
              
              % Showing inverted mask is currently disabled
              % csui.session.states.BackgroundEditor.invertedMask = ~csui.session.states.BackgroundEditor.invertedMask;
              
              SetImBuf(~bgMask, 'backgroundMask');
              ShowBackground();
          end
      case {'widen background mask', 'shrink background mask'}
          bg = ImageFromBuffer('background');
          bgMask = ImageFromBuffer('backgroundMask');
          if isempty(bg)
              errordlg('You need to get a background image first, to be then smoothed according to the background mask');
          elseif isempty(bgMask) || ~any(~bgMask(:))
              disp('The mask is empty...');
          else
              csui.session.states.BackgroundEditor.showMask = true;
              if strcmp(action, 'widen background mask')
                  bgMask = ImageDilate(bgMask, round(csui.session.states.BackgroundEditor.circleSize / 10));
              else
                  bgMask = ImageErode(bgMask, round(csui.session.states.BackgroundEditor.circleSize / 10));
              end
              SetImBuf(bgMask, 'backgroundMask');
              ShowBackground();
          end
      case 'reset background mask'
          SetImBuf([], 'backgroundMask');
          ShowBackground();
      case 'autodetect background mask'
          bg = ImageFromBuffer('background');
          if isempty(bg)
              errordlg('You need to get a background image first, to be then smoothed according to the background mask');
          elseif (parameters.segmentation.avgCellDiameter <= 0)
              errordlg('You need to set average cell diameter first');
          else
              disp('Trying to autodetect background mask, it will take some time...');
              bgSmooth = ImageSmooth(bg, round(parameters.segmentation.background.computeByBlurring * parameters.segmentation.avgCellDiameter));
              bgMask = ImageNormalize(abs(bg - bgSmooth)) > parameters.segmentation.foreground.MaskThreshold;
              SetImBuf(FillForegroundHoles(bgMask, parameters), 'backgroundMask');
          end          
          csui.session.states.BackgroundEditor.showMask = true;
          ShowBackground();
      case {'blur by circle size', 'blur by neighbor pixels', 'apply low-pass filter by circle size'}
          bg = ImageFromBuffer('background');
          bgMask = ImageFromBuffer('backgroundMask');
          if isempty(bg) 
              errordlg('You need to get a background image first, to be then smoothed according to the background mask');
          else
              if isempty(bgMask)
                  errordlg('The background mask is empty, smoothing can be applied only to masked regions.');
              else
                  switch action
                    case 'blur by circle size'
                      disp([ 'Blurring background by disk of (' num2str(csui.session.states.BackgroundEditor.circleSize * 2) ' / 2) pixels, it will take some time...']);
                      bgSmooth = ImageSmooth(bg, round(csui.session.states.BackgroundEditor.circleSize));
                      bgFin = bg;
                      bgFin(bgMask) = bgSmooth(bgMask);
                    case 'blur by neighbor pixels'
                      disp('Blurring background by neighborhood, it will take some time...');
                      bgFin = FillMaskedImageHoles(bg, ~bgMask, parameters.segmentation.background.blur * parameters.segmentation.avgCellDiameter,  parameters.segmentation.background.blurSteps, parameters.debugLevel);
                    case 'apply low-pass filter by circle size'
                      disp('Blurring background by low-pass filter, it will take some time...');
                      filtRow = size(bg, 1) / (csui.session.states.BackgroundEditor.circleSize * 2);
                      filtCol = size(bg, 2) / (csui.session.states.BackgroundEditor.circleSize * 2);
                      bff = fftshift(fft2(bg));
                      xdim = size(bg, 2);
                      ydim = size(bg, 1);
                      [X, Y] = meshgrid(ceil(-xdim/2):(ceil(xdim/2)-1), ceil(-ydim/2):(ceil(ydim/2)-1));
                      mask = ((1.0 * Y / filtRow).^2 + (1.0 * X / filtCol).^2) > 1;
                      bff(mask) = 0;
                      bbff = abs(ifft2(ifftshift(bff)));
                      bgFin = bg;
                      bgFin(bgMask) = bbff(bgMask);
                  end
                  UpdateBackground(bgFin);
                  csui.session.states.BackgroundEditor.showMask = false;
                  SaveBackground();
                  ShowBackground();
              end
          end
      case 'swap mouse buttons (paint-erase)'
          csui.session.states.BackgroundEditor.invertMouseButtons = ~csui.session.states.BackgroundEditor.invertMouseButtons;
          disp('Mouse buttons functions swapped.');
      case 'increase circle size'
          csui.session.states.BackgroundEditor.circleSize = csui.session.states.BackgroundEditor.circleSize * 1.1;
          fprintf('Circle diameter set to %f pixels.\n', csui.session.states.BackgroundEditor.circleSize * 2);
      case 'decrease circle size'
          csui.session.states.BackgroundEditor.circleSize = csui.session.states.BackgroundEditor.circleSize / 1.1;
          fprintf('Circle diameter set to %f pixels.\n', csui.session.states.BackgroundEditor.circleSize * 2);
      case 'set average (adult) cell diameter'
          SetAvgCellDiameter();
          if (parameters.segmentation.avgCellDiameter > 0)
              csui.session.states.BackgroundEditor.circleSize = parameters.segmentation.avgCellDiameter / 2;
              UILogAction(['% csui.session.states.BackgroundEditor.circleSize = ' num2str(csui.session.states.BackgroundEditor.circleSize) ';']);
          end
      case 'close request'
%           UIReset();
          disp('If you are trying to quit, press "h" for help.');
      case {'close', 'quit'}
          Quit();
      otherwise
          if ~isempty(action)
              disp(['Action "' action '" not implemented']);
          end
  end
  csui.sessionNeedsSaving = true;
end

function UpdateBackground(im)
   global csui;
   
   SetImBuf(im, 'background');
   nFrames = length(csui.session.parameters.files.imagesFiles);
   
   cchans = { 'originalClean', 'foregroundMask', 'brighterOriginal', ...
            'brighter', 'darkerOriginal', 'darker', 'cellContentMask', ...
            'cleanBlurred', 'segments', 'segmentsColor', 'segmentsColorMasked', ...
            'tracking', 'trackingMasked', 'connectivity' };
   for i = 1:length(cchans)
       ClearImageBuffer(cchans{i}, 1:nFrames);
       DeleteImage(cchans{i}, 1:nFrames);
   end
end