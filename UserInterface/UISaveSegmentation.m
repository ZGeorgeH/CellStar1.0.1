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


function UISaveSegmentation(frame)
    global csui;
    parameters = csui.session.parameters;
    
    fileNames = OutputFileNames(frame, parameters);

    segments = ImageFromBuffer('segments', frame);
    snakes = csui.segBuf{frame}.snakes;
    fluorescence = ComputeFluorescence(segments, frame, parameters);
    segImage = ImageFromBuffer('segmentsColor', frame);
    allSeeds = csui.segBuf{frame}.allSeeds;
    if isfield(csui.segBuf{frame}, 'connectivity') && ...
         ( ~isnumeric(csui.segBuf{frame}.connectivity) || ...
           (numel(csui.segBuf{frame}.connectivity) ~= 1) || ...
           (csui.segBuf{frame}.connectivity ~= -1))
        segmentsConnectivity = csui.segBuf{frame}.connectivity;
    else
        segmentsConnectivity = [];
    end
    intermediateImages = ComposeIntermediateImages(frame);
    ims = fieldnames(intermediateImages);
    for i = 1:length(ims)
        if isempty(intermediateImages.(ims{i}))
             intermediateImages.(ims{i}) = zeros(size(ImageFromBuffer('original', frame)));
        end
    end
    if isempty(segImage)
        segImage = zeros(size(intermediateImages.original));
    end

    SaveSegmentation(intermediateImages, segImage, snakes, fluorescence, allSeeds, segmentsConnectivity, fileNames, parameters);
end
