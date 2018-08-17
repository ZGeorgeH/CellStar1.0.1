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


function ComputeDeletedSegmentsMask(frame)
    global csui;
    
    if ~isfield(csui.segBuf{frame}, 'deletedSegments')
        csui.segBuf{frame}.deletedSegments = [];
    end
    
    if isempty(csui.segBuf{frame}.deletedSegments)
        SetImBuf([], 'deletedSegmentsMask', frame);
    end

    segments = ImageFromBuffer('segments', frame);
    deletedSegmentsMask = false(size(segments));
    
    deletedSegments = csui.segBuf{frame}.deletedSegments;
    for i = 1:length(deletedSegments)
        deletedSegmentsMask(segments == deletedSegments(i)) = true;
    end
    SetImBuf(deletedSegmentsMask, 'deletedSegmentsMask', frame);
    ClearImageBuffer('segmentsColorMasked', frame);
    ClearImageBuffer('trackingMasked', frame);
end