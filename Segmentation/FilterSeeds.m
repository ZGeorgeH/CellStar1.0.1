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


function filteredSeeds = FilterSeeds(seeds, allSeeds, parameters)
  % remove 'duplicates', where two seeds are considered equal if they have
  % very short distance: smart version
  
  distance = parameters.segmentation.stars.step * ...
             parameters.segmentation.avgCellDiameter;
  distance = max(distance, 0.5); % not less than half of pixel length
  
  okSeeds = false(size(seeds));
  
  if IsSubField(parameters, {'segmentation', 'transform', 'originalImDim'}) && ...
      ~isempty(parameters.segmentation.transform.originalImDim)
      
      gridSize = round(max(parameters.segmentation.transform.originalImDim) * 1.1 / distance);
  else
      gridSize = 10;
  end
  seedsGrid = cell([gridSize gridSize 1]);
  
  for i = 1:length(allSeeds)
      currSeed = allSeeds(i);
      x = round(currSeed.x / distance);
      y = round(currSeed.y / distance);
      for xx = x - 1:x + 1
        for yy = y - 1:y + 1
          if (xx > 0) && (yy > 0)
             if ((size (seedsGrid, 1) < xx) || (size (seedsGrid, 2) < yy))
                 seedsGrid{xx, yy} = [];
             end
             seedsGrid{xx, yy} = [seedsGrid{xx, yy} currSeed];
          end
        end
      end
  end

  for i = 1:length(seeds)
      currSeed = seeds(i);
      x = max(1, round(currSeed.x / distance));
      y = max(1, round(currSeed.y / distance));
      s = size(seedsGrid);
      if (x <= s(1) && y <= s(2))
        okSeeds(i) = SeedIsNew(currSeed, seedsGrid{x, y}, distance);
      end
      for xx = x - 1:x + 1
        for yy = y - 1:y + 1
          if (xx > 0) && (yy > 0)
             if ((size (seedsGrid, 1) < xx) || (size (seedsGrid, 2) < yy))
                 seedsGrid{xx, yy} = [];
             end
             seedsGrid{xx, yy} = [seedsGrid{xx, yy} currSeed];
          end
        end
      end
  end
  
  if ~isempty(okSeeds)
      okSeeds = okSeeds & ...
                ([seeds.x] > 0.5) & ...
                ([seeds.y] > 0.5) & ...
                ([seeds.x] < parameters.segmentation.transform.originalImDim(2) - 0.5) & ...
                ([seeds.y] < parameters.segmentation.transform.originalImDim(1) - 0.5);

      filteredSeeds = seeds(okSeeds);
  else
      filteredSeeds = okSeeds;
  end

end


function filteredSeeds = FilterSeedsOld(seeds, allSeeds, parameters)
  % remove 'duplicates', where two seeds are considered equal if they have
  % very short distance: inefficient version
  
  distance = parameters.segmentation.stars.step * ...
             parameters.segmentation.avgCellDiameter;
  distance = max(distance, 0.5); % not less than half of pixel length
  
  okSeeds = false(size(seeds));
  for i = 1:length(seeds)
      okSeeds(i) = SeedIsNew(seeds(i), allSeeds, distance) && ...
                   SeedIsNew(seeds(i), seeds(i ~= (1:end)), distance);
  end
  filteredSeeds = seeds(okSeeds);
end

function isNew = SeedIsNew(seed, allSeeds, distance)
   isNew = true;
   for i = 1:length(allSeeds)
       if (norm([seed.x seed.y] - [allSeeds(i).x allSeeds(i).y]) < distance)
           isNew = false;
           break
       end
   end
end
