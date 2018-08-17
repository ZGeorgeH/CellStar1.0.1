%     Copyright 2013, 2015 Cristian Versari
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

function mask = DigitMask(digitstring, bwDigits)
   mask = zeros(size(bwDigits, 1), 0);
   hstep = round(size(bwDigits, 2) * 1.1);
   for i = 1:length(digitstring)
      d = str2double(digitstring(i)) + 1;
      mask(:,(i-1)*hstep+1:(i-1)*hstep+size(bwDigits, 2)) = bwDigits(:,:,d);
   end
end
