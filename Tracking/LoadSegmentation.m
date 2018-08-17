%     Copyright 2012, 2013 Kirill Batmanov
%               2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function segments = LoadSegmentation(parameters)
  nFrames = size(parameters.files.imagesFiles(:), 1);

  trackingTruth = LoadGroundTruth(parameters);
  
  segments(nFrames) = LoadSegmentation1(nFrames, parameters, trackingTruth(nFrames));
  
  parfor fi = 1:(nFrames - 1)
    PrintMsg(parameters.debugLevel, 4, ['Loading segmentation frame ' num2str(fi) '...']);
    segments(fi) = LoadSegmentation1(fi, parameters, trackingTruth(fi));
  end   
end