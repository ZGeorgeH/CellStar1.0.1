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


function FixHandles()
   global csui;
   if ~IsSubField(csui, {'handles', 'image'}) || ...
       isempty(csui.handles.image) || (length(csui.handles.image) > 1) || ~ishandle(csui.handles.image)
  
       f = findobj('tag', 'CellStar User Interface');
       if (length(f) ~= 1)
           delete(f);
           f = figure('tag', 'CellStar User Interface', 'WindowStyle', 'docked', 'NumberTitle', 'off');
       else
           figure(f);
       end
       csui.handles.figure = f;

       csui.handles.image = findobj('tag', 'CellStar User Interface cdata');
       if (length(csui.handles.image) ~= 1)
           delete(csui.handles.image);
           csui.handles.image = imshow(0, 'border', 'tight');
           set(gca, 'Units', 'normalized', 'Position', [0 0 1 1]);
           set(csui.handles.image, 'tag', 'CellStar User Interface cdata');
       end
       
       SetHandleHooks(csui.handles.figure, @Hook);
       SetHandleHooks(csui.handles.image, @Hook);

   end
   
   if ~IsSubField(csui, {'handles', 'uimenu'}) || ...
           isempty(csui.handles.uimenu) || ...
           ~ishandle(csui.handles.uimenu)
       h = findobj(csui.handles.figure, 'Label', 'CellStar', 'Tag', 'CellStar uimenu');
       if (isempty(h) || (length(h) > 1))
           DeleteHandles(h);
           csui.handles.uimenu = uimenu('Label', 'CellStar', 'Tag', 'CellStar uimenu');
       else
           csui.handles.uimenu = h;
       end
   end
   
end
