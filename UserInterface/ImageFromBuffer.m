%     Copyright 2014 Kirill Batmanov
%               2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function im = ImageFromBuffer(imChannel, varargin)
  % handles the loading of pictures from computation or disk to memory
  % varargin{2} = frame number
  % varargin{3} = additional channel number
  
  global csui;
  
  if ~isempty(varargin)
      frame = varargin{1};
  else
      frame = [];
  end
  if length(varargin) > 1
      additionalChannel = varargin{2};
  else
      additionalChannel = [];
  end
  
  parameters = csui.session.parameters;
  
  switch imChannel
      case 'background'
          SetBackgroundFileName();
          imFile = csui.session.parameters.files.background.imageFile;
          im = LoadImageFromFileIfNeeded(imFile, imChannel, frame, []);
      case 'backgroundMask'
          im = GetImBuf(imChannel, frame, additionalChannel);
      case 'original'
          imFile = parameters.files.imagesFiles{frame};
          im = LoadImageFromFileIfNeeded(imFile, imChannel, frame, []);
      case 'additional'
          if isempty(additionalChannel)
              additionalChannel = csui.session.states.Editor.currentAdditionalChannel;
          end
          imFile = GetFluorescenceFileName(additionalChannel, frame, parameters);
          im = LoadImageFromFileIfNeeded(imFile, imChannel, frame, additionalChannel);
      case {'originalClean', 'foregroundMask', 'brighterOriginal', ...
            'brighter', 'darkerOriginal', 'darker', 'cellContentMask', ...
            'cleanBlurred', 'segments', 'segmentsColor', 'segmentsColorMasked', ...
            'tracking', 'trackingMasked', 'connectivity', 'deletedSegmentsMask' }
          allFileNames = OutputFileNames(frame, parameters);
          if isfield(allFileNames.images, imChannel)
              imFile = allFileNames.images.(imChannel);
              im = LoadImageFromFileIfNeeded(imFile, imChannel, frame, []);
          else
              im = GetImBuf(imChannel, frame);
          end
          if isempty(im)
              % optional todo: try to load image from mat file instead
              switch imChannel
                  case 'originalClean'
                      original = ImageFromBuffer('original', frame);
                      bg = ImageFromBuffer('background');
                      im = ComputeCleanImage(original, bg);
                  case 'brighterOriginal'
                      original = ImageFromBuffer('original', frame);
                      bg = ImageFromBuffer('background');
                      im = BackgroundSubtract(original, bg, 1, parameters.debugLevel, parameters.interfaceMode);
                  case 'darkerOriginal'
                      original = ImageFromBuffer('original', frame);
                      bg = ImageFromBuffer('background');
                      im = BackgroundSubtract(original, bg, -1, parameters.debugLevel, parameters.interfaceMode);
                  case 'brighter'
                      brighterOriginal = ImageFromBuffer('brighterOriginal', frame);
                      foregroundMask = ImageFromBuffer('foregroundMask', frame);
                      im = ComputeBrighterDarkerImage( ...
                             brighterOriginal, ...
                             foregroundMask, ...
                             parameters.segmentation.cellBorder.medianFilter, ...
                             parameters.segmentation.avgCellDiameter, ...
                             parameters.debugLevel);
                  case 'darker'
                      darkerOriginal = ImageFromBuffer('darkerOriginal', frame);
                      foregroundMask = ImageFromBuffer('foregroundMask', frame);
                      im = ComputeBrighterDarkerImage(...
                             darkerOriginal, ...
                             foregroundMask, ...
                             parameters.segmentation.cellContent.medianFilter, ...
                             parameters.segmentation.avgCellDiameter, ...
                             parameters.debugLevel);
                  case 'cleanBlurred'
                      originalClean = ImageFromBuffer('originalClean', frame);
                      foregroundMask = ImageFromBuffer('foregroundMask', frame);
                      im = ComputeCleanBlurredImage(...
                              originalClean, ...
                              foregroundMask, ...
                              parameters.segmentation.stars.gradientBlur, ...
                              parameters.segmentation.avgCellDiameter, ...
                              parameters.debugLevel);
                  case 'cellContentMask'
                      brighter = ImageFromBuffer('brighter', frame);
                      darker = ImageFromBuffer('darker', frame);
                      foregroundMask = ImageFromBuffer('foregroundMask', frame);
                      im = ComputeCellContentMask(brighter, darker, foregroundMask, parameters);
                  case 'foregroundMask'
                      original = ImageFromBuffer('original', frame);
                      brighterOriginal = ImageFromBuffer('brighterOriginal', frame);
                      darkerOriginal = ImageFromBuffer('darkerOriginal', frame);
                      im = ComputeForegroundMask(original, brighterOriginal, darkerOriginal, parameters);
                  case 'segments'
                      if ~ImageIsLoaded('segments', frame, [])
                          UILoadSegmentationIfNeeded(frame);
                          if ~ImageIsLoaded('segments', frame, [])
                            [segments, ~, ~, ~, ~, ~] = LoadSegmentationData(allFileNames.segmentation, [], parameters.debugLevel);
                            SetImBuf(segments, 'segments', frame);
                          end
                      end
                      im = GetImBuf('segments', frame);
                  case 'segmentsColor'
                      im = ImageFromSegmentation(...
                                  ImageFromBuffer('segments', frame), ...
                                  ImageFromBuffer('originalClean', frame), ...
                                  csui.segBuf{frame}.snakes);
                  case 'connectivity'
%                       if ~ImageIsLoaded('connectivity', frame, [])
%                           UIComputeConnectivity(frame);
%                       end
                      im = GetImBuf('connectivity', frame);
                  case 'tracking'
                      UILoadTrackingIfNeeded();
                      if ~isempty(csui.trackingBuf.tracking)
                          im = TrackingPic(...
                              csui.trackingBuf.tracking.traces, ...
                              frame, ...
                              [], ...
                              parameters, ...
                              ImageFromBuffer('segments', frame), ...
                              csui.session.states.Editor.showTrackingNumbers, ...
                              false, ImageFromBuffer('originalClean', frame)); % do not save the image to disk 
                      end
                  case {'segmentsColorMasked', 'trackingMasked'}
                      origChan = imChannel(1:end-6); % channel without "Masked" suffix
                      masked = GetImBuf(imChannel, frame);
                      mask = ImageFromBuffer('deletedSegmentsMask', frame);
                      if ~isempty(masked)
                          im = masked;
                      else
                          im = ImageFromBuffer(origChan, frame);
                          if ~isempty(mask)
                              im = ApplyMask(im, ~mask);
                              SetImBuf(im, imChannel, frame);
                          end
                      end
                  case 'deletedSegmentsMask'
                      ComputeDeletedSegmentsMaskIfNeeded(frame);
                      im = GetImBuf('deletedSegmentsMask', frame);
              end
              SetImBuf(im, imChannel, frame);
          end
      otherwise
          im = GetImBuf(imChannel, frame, additionalChannel);
          disp(['Warning: the channel ' imChannel ' should not be displayed...']);
  end
  
end


function im = LoadImageFromFileIfNeeded(imFile, imChannel, frame, additionalChannel)
  if ~ImageIsLoaded(imChannel, frame, additionalChannel)
     SetImBuf(LoadImageFromFile(imFile), imChannel, frame, additionalChannel);
  end
  im = GetImBuf(imChannel, frame, additionalChannel);
end


function im = LoadImageFromFile(imFile)
  global csui;
  parameters = csui.session.parameters;
  
  im = [];
  try
     if exist(imFile, 'file')
         [tmpMatrix, imDim] = ReadImage(imFile, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
%          im = double(tmpMatrix(:,:,1));
         im = double(tmpMatrix);
         if ~isfield(parameters.segmentation.transform, 'originalImDim') || isempty(parameters.segmentation.transform.originalImDim)
              csui.session.parameters.segmentation.transform.originalImDim = imDim; 
         end
         if any(imDim ~= csui.session.parameters.segmentation.transform.originalImDim)
              errordlg('Error: image dimensions do not correspond');
         end
     end
  catch
      fprintf(1, 'Error loading %s\n.', imFile);
  end
end

function imOut = ApplyMask(im, mask)
   % im   is a m x n x p matrix,
   % mask is a m x n x 1 matrix
   imOut = im;
   if isempty(im)
       return
   end
   imOut(~repmat(mask, [1 1 size(im, 3)])) = 0;
end
