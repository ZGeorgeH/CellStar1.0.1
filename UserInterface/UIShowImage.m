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


function UIShowImage (im, varargin)
   if (~isempty (varargin))
       drawLater = strcmp (varargin{1}, 'drawLater');
   else
       drawLater = false;
   end
   global csui;
   FixHandles ();
   currSize = size (get (csui.handles.image, 'cdata'));
   if isempty (im)
       im = zeros (currSize);
   end
   % Octave bug/incompatibility: cannot display empty image
   if isempty (im)
       im = 0;
   end
   imSize = size (im);
   
   if (islogical (im))
       % Octave does not like logical data to be shown
       im = uint8 (im);
   end
   
   % unfortunately Octave does not well support replacing figure's cdata if
   % size(im, 3) (i.e. new image's depth) differs from cdata's, so we have to do 
   % imshow and then restore xlim and ylim, even if the height and width
   % don't change: this is less efficient but only when changing channel, not when
   % scrolling frames
   if (~isequal (currSize, imSize))
       if isequal (currSize (1:2), imSize (1:2))
           currXlim = get (gca, 'xlim');
           currYlim = get (gca, 'ylim');
       end
       delete (findobj (get (csui.handles.image, 'Parent'), 'Type', 'image'));
       csui.handles.image = imshow (ImageNormalize (im), 'border', 'tight');
       set (csui.handles.image, 'tag', 'CellStar User Interface cdata');
       EditorPlotCurrentFrameObjects ();
       if isequal (currSize (1:2), imSize (1:2))
           set(gca, 'xlim', currXlim);
           set(gca, 'ylim', currYlim);
       end
       UpdateUIMenu ();
   else
       set (csui.handles.image, 'cdata', ImageNormalize (im));
   end
   if (~drawLater)
      drawnow;
   end
end
