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


function ShowHelp(help)
   global csui;
   switch csui.session.states.current
       case 'Editor'
           premise = [ ...
               'You are now in the main editor, where you can edit segmentation ' ...
               'and tracking. By mouse click you can select or delete existing segments, ' ...
               'modify their shape or add new segments. Keyboard actions: ' ];
       case 'BackgroundEditor'
           premise = [ ...
               'You are now in the background editor. ' ...
               'By mouse click you can modify the background mask. Keyboard actions: ' ];
       case 'MainMenu'
           premise = 'You are now in the main menu. Available actions:';
       otherwise
           premise = '';
   end

   if strcmp(help, 'help')
       msg = ListOfActionsToString('short');
       msg = sprintf([ premise '\n\n' msg]);
       msgbox(msg, 'Available actions');
   end
   disp('');
   disp('Available actions:');
   msg = ListOfActionsToString();
   disp(msg);
end
