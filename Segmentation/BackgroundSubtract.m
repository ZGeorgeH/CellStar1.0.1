%     Copyright 2012, 2015 Cristian Versari
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

function n = BackgroundSubtract(im, bg, sign, debugLevel, interfaceMode)
  n = ImageNormalize(max(sign * (double(im) - double(bg)), 0));
  if (sign == 1)
    PrintMsg(debugLevel, 4, 'Detecting cell borders...');
  else
    PrintMsg(debugLevel, 4, 'Detecting cell content...');
  end
  [~, ~, ~, ~, ~, strMsg] = MatrixResInfo(n);
  ImageShow(n, strMsg, 4, debugLevel, interfaceMode);
end
