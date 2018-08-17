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


function ShowHideAllSeeds()
    global csui;
    currFrame = csui.session.states.Editor.currentFrame;

    if ~IsSubField(csui, {'handles', 'currentFrame', 'allSeeds'})
        csui.handles.currentFrame.allSeeds = [];
    end
    csui.handles.currentFrame.allSeeds = ...
        DeleteHandles(csui.handles.currentFrame.allSeeds);
    if csui.session.states.Editor.showAllSeeds
        allSeeds = csui.segBuf{currFrame}.allSeeds;
        if ~isempty(allSeeds)
          hold on;
          csui.handles.currentFrame.allSeeds = ...
              plot(allSeeds(1, :), allSeeds(2, :), 'b.');
%               plot([allSeeds.x], [allSeeds.y], 'b.');
          hold off;
        end
    end
end
