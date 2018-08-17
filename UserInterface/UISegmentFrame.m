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


function UISegmentFrame(varargin)
   % Apply segmentation from scratch

   global csui;
    
    if isempty(varargin) || isempty(varargin{1})
        frame = csui.session.states.Editor.currentFrame;
    else
        frame = varargin{1};
    end
    
    intermediateImages = ComposeIntermediateImages(frame);

    [segments, snakes, allSeeds] = ...
        SegmentOneImage(intermediateImages, ...
                        DecodeSeeds(csui.segBuf{frame}.allSeeds), ...
                        csui.segBuf{frame}.snakes, ...
                        csui.session.parameters);
                    
    SetImBuf(segments, 'segments', frame);
    csui.segBuf{frame}.snakes = snakes;
    csui.segBuf{frame}.allSeeds = EncodeSeeds(allSeeds);
    
    ClearImageBuffer('segmentsColor', frame);
    DeleteImage('segmentsColor', frame);
end

