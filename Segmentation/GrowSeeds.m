%     Copyright 2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function snakes = GrowSeeds(seeds, currentImage, parameters)

    nSeeds = length(seeds(:));
    
    snakes = {};
    %snakes = zeros(parameters.segmentation.snakes.points + 1, 2, nSeeds);
    %Fsnake = zeros(nSeeds, 1);

    %snakes_enclosed_cell_border_average = zeros(nSeeds, 1);
    %snakes_enclosed_cell_content_average = zeros(nSeeds, 1);
    %snakes_enclosed_cell_border_max = zeros(nSeeds, 1);
    %snakes_border_brightness_ratio = zeros(nSeeds, 1);

    %[X,Y] = meshgrid(1:size(currentImage.original,2), 1:size(currentImage.original,1));
    
    %GrowSeed = @(sxone, syone)Snake(sxone, syone, currentImage, parameters, currentStep, fromBorder);
    %GrowSeed = @(seed)StarMulti(seed, currentImage, parameters, false);
    fromPolar = GetPolarTransform( ...
       parameters.segmentation.stars, ...
       parameters.segmentation.avgCellDiameter, ...
       parameters.debugLevel);
    GrowSeed = @(seed)StarMultiVect(seed, currentImage, parameters, false, fromPolar);

    %snakes = arrayfun(GrowSeed, sx, sy, 'UniformOutput', false);
    

    if (size(seeds(:), 1) == 0)
      PrintMsg(parameters.debugLevel, 2, 'No seeds to grow...'); 
    else
        if ((parameters.maxThreads > 0) && (strcmp(parameters.hostLanguage, 'matlab') || strcmp(parameters.hostLanguage, 'octave')))
            if (strcmp(parameters.hostLanguage, 'matlab'))
                parfor i=1:nSeeds
                   snakes{i} = GrowSeed(seeds(i));
                end
            end
            if (strcmp(parameters.hostLanguage, 'octave'))
                snakes = pararrayfun(parameters.maxThreads, GrowSeed, seeds);
                snakes = mat2cell(snakes(:), [ones(1, size(snakes(:),1))], [1]);
                snakes = snakes';
            end
        else
            interactive = (parameters.maxThreads == 0) && (parameters.debugLevel > 2) && (strcmp(parameters.interfaceMode, 'interactive') || strcmp(parameters.interfaceMode, 'confirm'));
            if (interactive)
               hold off;
               imshow(currentImage.brighter, 'border', 'tight');
               hold on;
               plot([seeds.x], [seeds.y], '.');
               drawnow;
               set(0, 'defaulttextcolor', 'white');
               %text([seeds(:).x] + 2, [seeds(:).y], num2str([1:size(seeds(:), 1)]'));
            end
            
            snakes = arrayfun(GrowSeed, seeds);
            snakes = mat2cell(snakes(:), [ones(1, size(snakes(:),1))], [1]);
            snakes = snakes';

            if (interactive)
              hold off;
            end
        end
    end
end
