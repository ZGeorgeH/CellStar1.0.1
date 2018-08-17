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

function bwDigits = LoadDigits(height)
   [digitsBasePath, ~, ~] = fileparts(mfilename('fullpath'));
   
   digitspath = fullfile(digitsBasePath, 'DigitsFont');

   bwDigits = double(imread(fullfile(digitspath, '0.png')));
   for i = 1:9
       bwDigits(:,:,i+1) = imread(fullfile(digitspath, [ num2str(i) '.png' ]));
   end
   newWidth = round(size(bwDigits, 2) * height / size(bwDigits, 1));
   
   % Octave does not allow resizing all at once...
   for i = 1:10
       bwDigitsR(:,:,i) = imresize(bwDigits(:,:,i), [height newWidth]);
   end
   bwDigitsR = 1 - bwDigitsR;
   bwDigits = bwDigitsR;
end
