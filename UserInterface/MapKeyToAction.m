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


function action = MapKeyToAction(actionMap, event)
  % maps an input event to an action, given an action map

  action = '';
  
  %event.Key
  
  if strcmp(['' event.Key], 'h')
      if isempty(cell2mat(event.Modifier(:)'))
          action = 'help';
      else
          action = 'Help';
      end          
  else
      for i=1:length(actionMap)
          if strcmp(num2str(cell2mat(sort(event.Modifier(:)'))), num2str(cell2mat(sort(actionMap(i).modifiers(:)'))))
              if any(strcmp(['' event.Key], actionMap(i).key)) || ...
                 any(strcmp(['' event.Character], actionMap(i).key)) 
                  
                  action = actionMap(i).action;
                  break
              end
          end
      end
  end
end
