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


function cellContentMask = ComputeCellContentMask(brighter, darker, foregroundMask, parameters)
      PrintMsg(parameters.debugLevel, 4, 'Computing cell content mask...');
      blurredDarker = ImageBlur(darker, round(parameters.segmentation.cellContent.blur * parameters.segmentation.avgCellDiameter));
      if (parameters.segmentation.cellContent.MaskThreshold == 0)
          tmpmask = ImageErode(foregroundMask, parameters.segmentation.foreground.MaskDilation * parameters.segmentation.avgCellDiameter);
          cellContentMaskThreshold = median(darker(tmpmask)) / 10.0;
          clear tmpmask;
      else
          cellContentMaskThreshold = parameters.segmentation.cellContent.MaskThreshold;
      end
      cellContentMask = (brighter == 0) & foregroundMask & (blurredDarker > cellContentMaskThreshold);
%       ImageShow(cellContentMask, 'Cell content mask detected...', 4, parameters.debugLevel, parameters.interfaceMode);
end