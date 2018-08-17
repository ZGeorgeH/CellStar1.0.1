%     Copyright 2013, 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function ClearImageBuffer(channel, varargin)
   % Clear images from memory buffer:
   % First argument: 'all channels' or a string corresponding to the
   %                 channel
   % Second optional argument = frame list to clear
   % Examples:
   % ClearImageBuffer('backgroundMask', [1 4 10]);
   %
   % Beware! You should use 'all channels' with care: in particular, be
   % sure you saved the 'segments' channel already to disk in the
   % corresponding segmentation files.
   
   global csui;
   if ~isempty(varargin)
       frames = varargin{1};
   else
       frames = [];
   end
   
   if (length(varargin) > 1)
       additionalChannel = varargin{2};
   else
       additionalChannel = [];
   end
   
   switch channel
       case 'all channels'
           % Beware! You may have loss of data here if you clear segments
           % from memory before saving them to file.
           csui.imBuf = {};
       otherwise
          if isfield(csui.imBuf, channel)
              if isempty(frames)
                  SetImBuf([], channel, [], additionalChannel);
              else
                  for i = 1:length(frames)
                      SetImBuf([], channel, frames(i), additionalChannel);
                  end
              end
          end
   end

end
