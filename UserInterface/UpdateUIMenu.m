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


function UpdateUIMenu()
    % Updates uimenu structure for CellStar submenu.
    % Currently only one level of nesting is supported, which seems to be
    % enough.
    global csui;
    
    if ~IsSubField(csui, {'session', 'keys'})
        return
    end
    keymap = csui.session.keys;
    
    currState = csui.session.states.current;
    
    FixHandles();
    
    DeleteHandles(get(csui.handles.uimenu, 'Children'));
    
    notEmptySubMenu = ~cellfun(@isempty, {keymap.(currState).subMenu});
    
    notEmptyKeyMap = [keymap.(currState)(notEmptySubMenu)];
    
    submenus = unique([notEmptyKeyMap.subMenu]);
    
    for i = 1:length(submenus)
        h = uimenu(csui.handles.uimenu, 'Label', submenus{i});
        entries = strcmp(submenus{i}, [notEmptyKeyMap.subMenu]);
        subkeymap = [notEmptyKeyMap(entries)];
        PlaceSubListUIMenu(h, subkeymap, currState);
    end
    
    PlaceSubListUIMenu(csui.handles.uimenu, ...
                       keymap.(currState)(~notEmptySubMenu), ...
                       currState);
end


function h = PlaceSubListUIMenu(handle, list, functionName)
    h = nan(size(list));
    for i = 1:length(list)
%         callback = [ functionName '(''' list(i).action ''', [])' ];
        callback = [ 'DispatchAction(''' list(i).action ''', [])' ];
        h(i) = uimenu(handle, 'Label', [ list(i).action '  [ ' KeyComboToString(list(i)) ' ]' ], 'Callback', callback);
    end
end