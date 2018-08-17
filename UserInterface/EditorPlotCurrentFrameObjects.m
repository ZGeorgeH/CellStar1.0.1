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


function EditorPlotCurrentFrameObjects()
    global csui;
    
    if ~strcmp (csui.session.states.current, 'Editor')
        return
    end
    
    currFrame = csui.session.states.Editor.currentFrame;

    EditorFixNewSeedsField();
    nSeeds = length(csui.segBuf{currFrame}.newSeeds);
    for i = 1:nSeeds
        EditorPlotSeed(i)
    end
    if IsSubField(csui, {'session', 'states', 'Editor', 'editingLastSeed'}) &&  ...
        csui.session.states.Editor.editingLastSeed
        EditorEditLastSeed();
    end
    
    if EditorSegmentIsSelected()
        EditorDrawSelectedSegment();
    end
    
    if any(strcmp(csui.session.states.Editor.channel, {'tracking', 'trackingMasked'}))
        PlotTrackingGroundTruth();
    end
    
    ShowHideAllSeeds();
end
