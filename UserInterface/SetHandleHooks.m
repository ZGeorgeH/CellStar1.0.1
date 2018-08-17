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


function SetHandleHooks(handle, hookFunction)
    handleType = get(handle, 'Type');
    switch handleType
        case 'figure'
            set(handle, 'BusyAction', 'cancel', 'Interruptible', 'off');
%             hooks = { 'ButtonDownFcn', 'CloseRequestFcn', 'DeleteFcn', 'KeyPressFcn', ...
%                      'KeyReleaseFcn', 'ResizeFcn', 'WindowButtonMotionFcn', ...
%                      'WindowButtonUpFcn', 'WindowKeyPressFcn', 'WindowKeyReleaseFcn', ...
%                      'WindowScrollWheelFcn', 'WindowButtonWheelFcn' ...
%                    };
            hooks = { 'CloseRequestFcn', 'DeleteFcn', 'KeyPressFcn', 'WindowButtonUpFcn', 'WindowScrollWheelFcn' };
        otherwise
%             hooks = { 'ButtonDownFcn' };
            hooks = { };
    end
            
    for i = 1:length(hooks)
       try
           if isempty(hookFunction)
               set(handle, hooks{i}, '');
           else
               set(handle, hooks{i}, {hookFunction, hooks{i}});
           end
       catch
           
       end
    end
end
