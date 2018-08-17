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


function UIReset(varargin)
    global csui;
    
    if isempty(varargin)
        force = false;
    else
        force = strcmp(varargin{1}, 'force');
    end
    
    if isfield(csui, 'lock') || force
        FixHandles();

        SetHandleHooks(csui.handles.figure, []);
        SetHandleHooks(csui.handles.image, []);
        clf(csui.handles.figure);
        set(csui.handles.figure, 'CloseRequestFcn', @(x,y)delete(x));

        % OCTAVE BUG
        % Currently Octave crashes if you try to delete the figure
        % within a hook of the figure itself...
        % Deleting the figure does not seem a good idea in general, so
        % it is currently disabled.
        %defaultParams = DefaultParameters();
        %if ~strcmp(defaultParams.hostLanguage, 'octave')
        %    delete(gcf);
        %end

        FixHandles();
        UIShowCurrentState();
        UpdateUIMenu();
    else
        disp('Use InitUI instead, if the session is empty.');
    end
end
