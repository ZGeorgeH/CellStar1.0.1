%     Copyright 2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [m, originalImDim] = ReadImage(fileName, transform, debugLevel, interfaceMode)
  PrintMsg(debugLevel, 4, [ 'Reading "' fileName '" ... ' ]);
  m = imread(fileName);
  if islogical(m)
      imax = 1;
  else
      imax = intmax(class(m));
  end
  % Octave bug/incompatibility: boolean images are int8 and not logical
  if (max(m(:)) > 1)
      m = double(m)/double(imax);
  end
  originalImDim = size(m);
  originalImDim = originalImDim(1:2);
  if transform.clip.apply
      m = m(transform.clip.Y1:transform.clip.Y2,transform.clip.X1:transform.clip.X2);
  end
  if transform.invert == 1
     m = 1 - m;
  end
  
  if transform.scale ~= 1
      m = imresize(m, transform.scale);
  end
  [~, ~, ~, ~, ~, strMsg] = MatrixResInfo(m);
  PrintMsg(debugLevel, 4, strMsg);
  % ImageShow(m, 'done', 4, debugLevel, interfaceMode);
end
