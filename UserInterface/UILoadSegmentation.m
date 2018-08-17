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


function UILoadSegmentation(frames)
    global csui;
    
    for i = 1:length(frames)
        frame = frames(i);
        fileNames = OutputFileNames(frame, csui.session.parameters);

        [segments, snakes, allSeeds, ~, fluorescence, connectivity] = LoadSegmentationData(fileNames.segmentation, fileNames.segmentationGroundTruth, csui.session.parameters.debugLevel);

        csui.segBuf{frame}.snakes = snakes;
        csui.segBuf{frame}.allSeeds = allSeeds;
        csui.segBuf{frame}.fluorescence = fluorescence;
        csui.segBuf{frame}.connectivity = connectivity;
        SetImBuf(segments, 'segments', frame);
    end
end
