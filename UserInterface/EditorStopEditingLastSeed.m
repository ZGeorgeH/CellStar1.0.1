%     Copyright 2014, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function EditorStopEditingLastSeed()
    global csui;
    currFrame = csui.session.states.Editor.currentFrame;
    EditorFixNewSeedsField();
    currSeedN = length(csui.segBuf{currFrame}.newSeeds);
    csui.session.states.Editor.editingLastSeed = false;
    if (currSeedN > 0)
       if isfield(csui.handles.currentFrame, 'lastSeed')
           csui.handles.currentFrame.lastSeed = DeleteHandles(csui.handles.currentFrame.lastSeed);
       end
       
       if isfield(csui.handles.currentFrame, 'seeds') && (length(csui.handles.currentFrame.seeds) >= currSeedN) && ...
               ~any(~ishandle(csui.handles.currentFrame.seeds{currSeedN}))
           set(csui.handles.currentFrame.seeds{currSeedN}, 'Color', [1 0 0]);
       end
    end
end
