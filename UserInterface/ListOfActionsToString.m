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


function msg = ListOfActionsToString(varargin)
   global csui;
   
   if ~isempty(varargin) && strcmp(varargin{1}, 'short')
       field = 'actionShort';
   else
       field = 'action';
   end
       

   actionMap = csui.session.keys.(csui.session.states.current);
   
%    msg = '=============================\n Menu:\n';
   msg = '';

   for i = 1:length(actionMap)
       sfield = field;
       if ~isfield(actionMap(i), 'actionShort') || isempty(actionMap(i).actionShort)
           sfield = 'action';
       end
       keyCombo = [ KeyComboToString(actionMap(i)) ': ' ];
       if strcmp(field, 'action')
           keyCombo = SFormat(keyCombo, 20);
       end
       addMsg = [ keyCombo actionMap(i).(sfield) ];
       if strcmp(sfield, 'actionShort')
           if ~mod(i, 2)
               newLine = '\n';
               sep = '          ';
           else
               newLine = '';
               sep = '';
           end
       else
           newLine = '\n';
           sep = '';
       end
       msg = [ msg sep SFormat(addMsg, 25) newLine ];
   end
   
   msg = [ msg ...
           '\n  h / shift+h   -   show help in dialog box/console  \n\n' ...
           '  Current task: ' csui.session.states.current '\n' ...
           ];
   
   msg = sprintf(msg);
end

function s2 = SFormat(s, nspaces)
   s2 = [s int16(int16(' ') * int16(ones(1, max(0, nspaces - length(s)))))];
end

