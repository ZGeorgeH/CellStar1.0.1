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


function InitUI(varargin)
   % Usage:
   %    InitUI()                      load empty session
   %    InitUI('force')               force loading of empty session
   %    InitUI(parameters)            create session with given segmentation/tracking parameters
   %    InitUI(parameters, 'force')   force creation of session with given parameters
   
   global csui;
   
   [cellStarUIDir, ~, ~] = fileparts(mfilename('fullpath'));
   [cellStarBaseDir, ~, ~] = fileparts(cellStarUIDir);
   dirs = { 'Segmentation' 'Tracking' 'UserInterface' 'Misc' };
   for i = 1:length(dirs)
       addpath(fullfile(cellStarBaseDir, dirs{i}));
   end
   
   force = false;
   parameters = [];
   
   if ~isempty(varargin)
       if ischar(varargin{1})
           force = strcmp(varargin{1}, 'force');
       else
           parameters = varargin{1};
           if (length(varargin) > 1) && ischar(varargin{2})
               force = strcmp(varargin{2}, 'force');
           end
       end
   end
   
   if ~force && isfield(csui, 'lock')
       disp('Another session is apparently running. If not, run "InitUI force"');
       return
   else
       LoadSession('');
   end
   
   if isstruct(parameters)
       csui.session.parameters = parameters;
   end
   
   csui.session.keys = KeyBindings();
   
   SetFigureName('CellStar');

   if strcmp(csui.session.parameters.hostLanguage, 'octave')
       set(csui.handles.figure, 'visible', 'off')
       drawnow;
       set(csui.handles.figure, 'visible', 'on');
       drawnow;
   end
   
   SetHandleHooks(csui.handles.figure, @Hook);
   SetHandleHooks(csui.handles.image, @Hook);
   
   disp('CellStar user interface initialized.');
   
   if ~ispref('CellStar', 'startedOnce')
       msg = sprintf(...
          [
             '    This seems the first time you run CellStar user interface.     \n' ...
             '    Remember that you can see at any time the list of available    \n' ...
             '    actions by pressing "h". When CellStar figure window is        \n' ...
             '    selected, you may also find the list of available actions      \n' ...
             '    in the menu bar under "CellStar".                              \n' ...
             '    Meanwhile, you may also type any expression at the console.    \n' ...
          ]);
       msgbox(msg);
       setpref('CellStar', 'startedOnce', 'true');
   end
   ShowHelp('Help');
   disp('Press "h" at any time for the list of available actions.');
   fprintf('\nConsole ready.');
end
