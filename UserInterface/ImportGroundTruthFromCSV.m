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


function ImportGroundTruthFromCSV(fileName)
    global csui
    
    fid = fopen(fileName);
    
    CSVData = textscan(fid, '%f %f %f %f %f', 'delimiter', ',', 'HeaderLines', 1);
    
    currFrame = csui.session.states.Editor.currentFrame;

    nFiles = length(csui.session.parameters.files.imagesFiles);
    
    onceF = true;
    onceS = true;
    % Emulate mouse clicks
    for i = 1:length(CSVData{1})
        if (CSVData{1}(i) <= nFiles)
            mouseClick.x = CSVData{4}(i);
            mouseClick.y = CSVData{5}(i);
            if (mouseClick.x > 0) && ...
               (mouseClick.x < csui.session.parameters.segmentation.transform.originalImDim(1)) && ...
               (mouseClick.y > 0) && ...
               (mouseClick.y < csui.session.parameters.segmentation.transform.originalImDim(2))
           
                csui.session.states.Editor.currentFrame = CSVData{1}(i);
                EditorAddSeed(mouseClick)
            else
            if onceS
                    disp('Ground truth data out of image surface: wrong CSV file?');
                onceS = false;
            end
            end
        else
            if onceF
                disp('Ground truth data beyond last frame: wrong CSV file?');
                onceF = false;
            end
        end
    end
    EditorStopEditingLastSeed();
    
    csui.session.states.Editor.currentFrame = currFrame;
end
