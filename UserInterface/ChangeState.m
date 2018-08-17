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


function ChangeState(newState)
   global csui;
   csui.lock = true;
   switch newState
       case {'BackgroundEditor', 'Editor'}
          if isempty(csui.session.parameters.files.imagesFiles)
              msg = 'No frames selected yet.';
              UISetNewState('MainMenu');
              disp(msg); errordlg(msg);
          elseif ~SaveSession(false)
              msg = 'You need to save the session, first';
              disp(msg); errordlg(msg);
              UISetNewState('MainMenu');
          elseif strcmp(newState, 'Editor') && ...
               ( ...
                  isempty(csui.session.parameters.files.background.imageFile) || ...
                  ~exist(csui.session.parameters.files.background.imageFile, 'file') ...
               )
              if strcmp(csui.session.states.current, 'BackgroundEditor')
                  msg = 'Background is not set yet.';
              else
                  msg = 'You need to edit background image, you will be now switched to background editor.';
                  UISetNewState('BackgroundEditor');
              end
              disp(msg); errordlg(msg);
              ShowHelp('Help');
          else
              SetAvgCellDiameterIfNeeded();
              UISetNewState(newState);
              ShowHelp('Help');
          end
       otherwise
           UISetNewState(newState);
           ShowHelp('Help');
   end
   
end
