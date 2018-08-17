%     Copyright 2012, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [nRows, nCols, nVals, minVal, maxVal, strMsg] = MatrixResInfo(m)
  minVal = min(m(:));
  maxVal = max(m(:));
  nRows = size(m, 1);
  nCols = size(m, 2);
  uniq = unique(m(:));
  nVals = size(uniq(:), 1);
  strMsg = [ 'Image info: size ' ...
      num2str(nRows) 'x' num2str(nCols) ... 
      ', colors ' num2str(nVals) ...
      ', from ' num2str(minVal) ' to ' num2str(maxVal) ...
      '.' ];
end
