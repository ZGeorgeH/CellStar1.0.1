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


function EditorEditLastSeed()
    global csui;
    currFrame = csui.session.states.Editor.currentFrame;
    currSeedN = length(csui.segBuf{currFrame}.newSeeds);
    if (currSeedN > 0)
       csui.session.states.Editor.editingLastSeed = true;
       set(csui.handles.currentFrame.seeds{currSeedN}, 'Color', [0 1 0]);
       if isfield(csui.segBuf{currFrame}.newSeeds{currSeedN}.contour, 'groundTruth')
           gt = csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.groundTruth;
           x = csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.x(gt);
           y = csui.segBuf{currFrame}.newSeeds{currSeedN}.contour.y(gt);
           
           if ~isfield(csui.handles.currentFrame, 'lastSeed')
               csui.handles.currentFrame.lastSeed = [];
           end
           csui.handles.currentFrame.lastSeed = DeleteHandles(csui.handles.currentFrame.lastSeed);

           hold on;
           % csui.handles.currentFrame.lastSeed = scatter(x, y, 16, 'b', 'filled');
           csui.handles.currentFrame.lastSeed = plot(x, y, '.b');
           hold off;
       end
       if (currSeedN > 1) && ~any(~ishandle(csui.handles.currentFrame.seeds{currSeedN - 1}))
           set(csui.handles.currentFrame.seeds{currSeedN - 1}, 'Color', [1 0 0]);
       end
    end
end
