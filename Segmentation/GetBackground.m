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


% Gets the background image to be subtracted, either from file or by
% manually editing the mask
function [bg, parameters] = GetBackground(oldParameters)
  parameters = oldParameters;

  if (strcmp(parameters.files.background.imageFile, '') || ~exist(parameters.files.background.imageFile, 'file'))
      if parameters.segmentation.background.manualEdit
          PrintMsg(parameters.debugLevel, 0, 'You chose to manually edit the background. Good luck!');
          PrintMsg(parameters.debugLevel, 0, 'Enter the files that will be averaged and manually masked to compute the background...');
          currentFolder = pwd;
          cd(parameters.files.destinationDirectory);
          [f, d] = uigetfile({parameters.files.uigetfileFilter}, 'Choose image files to compute the background...', 'MultiSelect', 'on');
          cd(currentFolder);
          if isa(f, 'double')
              PrintMsg(parameters.debugLevel, 0, 'You did not provide background file: I will smooth the first picture to be segmented and use it as a background.');
              [bg, parameters] = BgFromSmoothing(parameters);
          else
              if ischar(f)
                  [tmpIm, parameters.segmentation.transform.originalImDim] = ReadImage(fullfile(d, f), parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
                  totf = double(tmpIm);
              else
                  for i = 1:size(f(:), 1)
                      [tmpf, parameters.segmentation.transform.originalImDim] = ReadImage(fullfile(d, f{i}), parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
                      if (i == 1)
                          totf = double(tmpf(:,:,1));
                      else
                         totf = totf + double(tmpf(:,:,1));
                      end
                  end
                  totf = totf / double(size(f(:), 1));
              end
              mask = GetMaskFromUI(totf, parameters.keys.GetMaskFromUI, round(parameters.segmentation.avgCellDiameter * 1.3 / 2));
              bg = FillMaskedImageHoles(totf, mask, round(parameters.segmentation.background.blur * parameters.segmentation.avgCellDiameter), parameters.segmentation.background.blurSteps, parameters.debugLevel);
              parameters.files.background.imageFile = fullfile(parameters.files.destinationDirectory, 'background.png');
              ImageSave(bg, parameters.files.background.imageFile, parameters.segmentation.transform, parameters.debugLevel);
          end
      else
         if strcmp(parameters.interfaceMode, 'batch')
            PrintMsg(parameters.debugLevel, 0, 'You did not provide background file and you chose batch mode: I will smooth the first picture to be segmented and use it as a background.');
            [bg, parameters] = BgFromSmoothing(parameters);
         else
            PrintMsg(parameters.debugLevel, 0, 'You did not provide background file name: now choose it!');
            currentFolder = pwd;
            if ~exist(parameters.files.destinationDirectory, 'file')
                mkdir(parameters.files.destinationDirectory);
            end
            cd(parameters.files.destinationDirectory);
            [f, d] = uigetfile({'*.tif;*.png'}, 'Choose background image file...');
            cd(currentFolder);
            if ischar(f)
              parameters.files.background.imageFile = fullfile(d, f);
              [tmpMatrix, parameters.segmentation.transform.originalImDim] = ReadImage(parameters.files.background.imageFile, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
              bg = tmpMatrix(:,:,1);
            else
              PrintMsg(parameters.debugLevel, 0, 'You did not provide background file: I will smooth the first picture to be segmented and use it as a background.');
              [bg, parameters] = BgFromSmoothing(parameters);
            end
         end
      end
  else
    [tmpMatrix, parameters.segmentation.transform.originalImDim] = ReadImage(parameters.files.background.imageFile, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
    bg = tmpMatrix(:,:,1);
  end
end

function [bg, parameters] = BgFromSmoothing(oldParameters)
    parameters = oldParameters;
    [tmpMatrix, parameters.segmentation.transform.originalImDim] = ReadImage(parameters.files.imagesFiles{1}, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
    firstPic = double(tmpMatrix(:,:,1));
    firstPicSmooth = ImageSmooth(firstPic, round(parameters.segmentation.background.computeByBlurring * parameters.segmentation.avgCellDiameter));

    fgMask = ImageNormalize(abs(firstPicSmooth - firstPic)) > parameters.segmentation.foreground.MaskThreshold;
    fgMask = FillForegroundHoles(fgMask, parameters);
    
    bg = FillMaskedImageHoles(firstPic, ~fgMask, parameters.segmentation.background.blur * parameters.segmentation.avgCellDiameter,  parameters.segmentation.background.blurSteps, parameters.debugLevel);

    parameters.files.background.imageFile = fullfile(parameters.files.destinationDirectory, 'background.png');
    ImageSave(bg, parameters.files.background.imageFile, parameters.segmentation.transform, parameters.debugLevel);
end