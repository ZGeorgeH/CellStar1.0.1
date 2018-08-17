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


function fluoImage = LoadFluorescencePicture(fluoChannelNumber, currIm, parameters)
  % try to find, in the given channel fluoChannelNumber (possibly not a fluorescence channel...),
  % the image file corresponding to the current image currIm used for segmentation,
  % according to the map described in parameters 
  fluoImage = [];
  fluoImageFile = GetFluorescenceFileName(fluoChannelNumber, currIm, parameters);
  if ~isempty(fluoImageFile) && exist(fluoImageFile, 'file')
      [tmpMatrix, ~] = ReadImage(fluoImageFile, parameters.segmentation.transform, parameters.debugLevel, parameters.interfaceMode);
      fluoImage = tmpMatrix(:,:,1);
  end
end
