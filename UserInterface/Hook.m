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


function Hook(varargin)
  % This function handles events from keyboard and mouse, but only the
  % events that both Matlab and Octave handle correctly
  % (very few for Octave, currently...)
  global csui;
  
  if ~IsSubField(csui, {'session', 'keys'})
      return
  end
  
  mouseClick.button = '';
  
  switch varargin{3}
      case {'WindowButtonUpFcn'}
          cp = get(gca, 'CurrentPoint');
          mouseClick.x = cp(1, 1); % Matlab and Octave differ...
          mouseClick.y = cp(2, 2);
          mouseClick.button = get(gcf, 'SelectionType');
          if strcmp(mouseClick.button, 'normal')
              action = 'mouse1';
          else
              action = 'mouse2';
          end
      case {'KeyPressFcn'}
%           varargin{2}
          actionMap = csui.session.keys.(csui.session.states.current);
          action = ['' MapKeyToAction(actionMap, varargin{2})];
      case {'WindowScrollWheelFcn'}
          if varargin{2}.VerticalScrollCount < 0
             action = 'mouseWheelUp';
          else
             action = 'mouseWheelDown';
          end
      case 'CloseRequestFcn'
          action = 'close request';
      case 'DeleteFcn'
          action = 'close';
      otherwise
          return
  end
  
  if any(strcmp(action, {'help', 'Help'}))
      ShowHelp(action);
  else
      if isempty(action) && ...
         ~any(strcmp(varargin{2}.Key, {'control', 'alt', 'shift', 'capslock'})) && ...
         ~isempty(varargin{2}.Character)

          ShowHelp('Help');
          disp([ 'Wrong key: character "' varargin{2}.Character '", key "' varargin{2}.Key '", modifiers "' varargin{2}.Modifier{:} '".']);
          disp('');
          msg = ListOfActionsToString('short');
          if ispref('CellStar', 'PreviousSessions') && ~isempty(getpref('CellStar', 'PreviousSessions'))
               mapK = questdlg(sprintf(['The key combination you pressed does not correspond to any action.\nDo you want to map it to some action? Press "Map".\nDo you want to load the full key map from previous session? Press "Load".\nOtherwise:\n\n' msg]), 'Wrong key', 'Map', 'Load', 'Cancel', 'Cancel');
          else
               mapK = questdlg(sprintf(['The key combination you pressed does not correspond to any action.\nDo you want to map it to some action?\nOtherwise:\n\n' msg]), 'Wrong key', 'Yes', 'No', 'No');
          end
          if any(strcmp(mapK, {'Yes', 'Map'}))
              RemapKey(varargin{2});
          end
          if strcmp(mapK, 'Load')
              f = getpref('CellStar', 'PreviousSessions');
              if strcmp(f{1}, csui.sessionFile) && (length(f) > 1)
                  idx = 2;
              else
                  idx = 1;
              end
              LoadKeyMapFromFile(f{idx});
          end
      else
          if ~isempty(action)
              DispatchAction(action, mouseClick);
          end
      end
  end
end

