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

% TODO: stop when optimum is reached, which is stochastic but known as soon
% as contours are settled

function optRankingParams = OptimizeRankingParameters(broadness, varargin)
   global csui;

    if ~isempty(varargin)
        searchStrategy = varargin{1};
    else
        if exist('simulannealbnd')
            searchStrategy = 'Simulated Annealing';
        else
            searchStrategy = 'Global Search';
        end
    end

   optRankingParams = [];
   parameters = csui.session.parameters;
   nFrames = length(parameters.files.imagesFiles);
   
   UILoadSegmentationIfNeeded(1:nFrames);
  
   gTSnakesPerFrame = cellfun(@(x)cellfun(@StarGroundTruth, x.snakes), csui.segBuf, 'UniformOutput', false);
   
   gTStars = nnz([gTSnakesPerFrame{:}]);
   
   if (gTStars == 0)
      disp('No segmentation ground truth available for optimization of ranking parameters.');
      rankingParams = [];
      return
   else
      framesWithGTIdx = cellfun(@any, gTSnakesPerFrame);
      disp(['Found ' num2str(gTStars) ' stars in ground truth in frame(s) ' num2str(find(framesWithGTIdx)) ', starting optimization of ranking parameters...']);
   end
       
   [gTMasks, gTSegments] = arrayfun(@GetGTMask, find(framesWithGTIdx), 'UniformOutput', false);
   
   dilatedGTMasks = cellfun(@ImageDilate, ...
                            gTMasks, ...
                            CellRepmat(round(parameters.segmentation.avgCellDiameter / 5), length(gTMasks)), ...
                            'UniformOutput', false);
                        
   allSeedsInGTFrames = cellfun(@(x)DecodeSeeds(x.allSeeds), csui.segBuf(framesWithGTIdx), 'UniformOutput', false);
                        
   disp('Collecting seeds...');
   manySeeds = cellfun(@GetSeeds, ...
                   CellRepmat(50, length(gTMasks)), ...
                   CellRepmat(parameters.segmentation.avgCellDiameter, length(gTMasks)), ...
                   allSeedsInGTFrames, dilatedGTMasks, ...
                   'UniformOutput', false);
   LocalFilterSeeds = @(s)FilterSeeds(s, [], parameters);
   seeds = cellfun(LocalFilterSeeds, manySeeds, 'UniformOutput', false);
   disp([ num2str(numel([seeds{:}])) ' seeds placed, growing snakes...']);
   
   intermediateImages = cellfun(@ComposeIntermediateImages, num2cell(find(framesWithGTIdx)), 'UniformOutput', false);
  
   LocalGrowSeeds = @(s, i)GrowSeedsAllSizeWeights(s, i, parameters);
   snakes = cellfun(LocalGrowSeeds, seeds, intermediateImages, 'UniformOutput', false);

   LocalMapSnakesToGroundTruth = ...
       @(s, g)MapSnakesToGroundTruth(s, ...
                                     g, ...
                                     parameters.segmentation.maxOverlap, ...
                                     parameters.segmentation.avgCellDiameter);
   smaps = cellfun(LocalMapSnakesToGroundTruth, snakes, gTSegments, 'UniformOutput', false);
   
   rankingParams = parameters.segmentation.ranking;

   nRankingFeatures = length(RankingParametersToVector(rankingParams));
   
   nStars = length([smaps{:}]);
   fromStarToQueue = zeros([nStars 2]);
   distances = zeros([nStars 1]);
   currStarIdx = 0;
   currQueueIdx = 0;
   featuresMatrix = zeros([nStars nRankingFeatures]);
   for i = 1:length(smaps)
       gTSegs = unique([smaps{i}.gTSegment]);
       for j = 1:length(gTSegs)
           currQueueIdx = currQueueIdx + 1;
           currQueueStars = [smaps{i}.gTSegment] == gTSegs(j);
           currQueueStars = find(currQueueStars);
           for k = 1:length(currQueueStars)
               currStarIdx = currStarIdx + 1;
               currMap = smaps{i}(currQueueStars(k));
               distances(currStarIdx) = currMap.distance;
               fromStarToQueue(currStarIdx, :) = [currQueueIdx k];
               featuresMatrix(currStarIdx, :) = currMap.rankingFeatures;
               
%                tmpSnakes{currStarIdx} = currMap.snake;
%                tmpSegments{currStarIdx} = currMap.gtsegmentArea;
           end
       end
   end
   
   distanceMatrix = Inf(max(fromStarToQueue));
   
   fromStarToQueueIdx = sub2ind(size(distanceMatrix), fromStarToQueue(:, 1), fromStarToQueue(:, 2));
   
   distanceMatrix(fromStarToQueueIdx) = distances;

   minTotalRank = norm(min(distanceMatrix, [], 2)) / sqrt(size(distanceMatrix, 1));
   disp(['Best possible result: ' num2str(minTotalRank)]);
   
   start = RankingParametersToVector(rankingParams);
  
   startFitness = RankingFVal(start, distanceMatrix, fromStarToQueueIdx, featuresMatrix, true);

   Fitness = @(r)RankingFVal(r, distanceMatrix, fromStarToQueueIdx, featuresMatrix, false);

   disp([ ...
          num2str(nStars) ...
          ' stars mapped to ground truth, starting optimization with:  initial-fval=' ...
          num2str(startFitness) ...
       ]);
%           '%   init-temperature=' num2str(temperature) ...
%            '   stall-iter=' num2str(stallIter) ...
%            '   reannil=' num2str(reannil) ...
   
   x = start;
   bestfval = startFitness;
   switch searchStrategy
       case 'Global Search'
           LB = -10e5;
           UB = 10e5;
           stopIfValBelow = 0.10;
           stopMaxTime = 1800;
           verbose = true;
           searchStrategy = 'Global Search';
           [x, bestfval] = CSGlobalMinimize(Fitness, start, LB, UB, stopIfValBelow, stopMaxTime, verbose, searchStrategy);
       otherwise
           % Simulated annealing, seems to work better for ranking
           % optimization
           if ~exist('simulannealbnd')
               disp('Simulated annealing algorithm not found... Missing optimization package?');
           else
               broadness = max(min(1, broadness), 0.001);
               range = broadness * 10;
               temperature = 10 + (range * 1000)^3;
               stallIter = int32(60 + range^3 * 1000);
               reannil = round(200 + range * 100);

               mytempfun = @(optimValues, options)TemperatureFun(optimValues, options, 0.999);

               UB = [];
               LB = [];

               [x, bestfval] = simulannealbnd(Fitness, start, LB, UB, saoptimset('Display', 'iter', 'DisplayInterval', 100, 'StallIterLimit', stallIter, 'InitialTemperature', temperature, 'ReannealInterval', reannil,  'TemperatureFcn', mytempfun, 'MaxFunEvals', 10^8, 'ObjectiveLimit', minTotalRank));
           end
   end

   optRankingParams = VectorToRankingParameters(x / max(abs(x)), rankingParams);
  
   fprintf('\n');
   if (bestfval == startFitness)
       disp(['Contour parameters optimization terminated, fval unchanged at ' num2str(bestfval)]);
   else
       disp(['Contour parameters optimization terminated with fval reduced from initial value of ' num2str(startFitness) ' to ' num2str(bestfval) '.']);
   end
end

function [fval, totCalls, best] = RankingFVal(rankingParams, distanceMatrix, fromStarToQueueIdx, featuresMatrix, boolReset)
    global csui;
    persistent currBestFval;

    % keep trace of how many times the function is called
    persistent howManyTimes;
    if isempty(howManyTimes)
        howManyTimes = 0;
    end
    howManyTimes = howManyTimes + 1;
    totCalls = howManyTimes;
    
    ranks = featuresMatrix * rankingParams';
    ranksMatrix = distanceMatrix;
    ranksMatrix(fromStarToQueueIdx) = ranks;
    
    [~, minRanksSub] = min(ranksMatrix, [], 2);
    
    minRanksIdx = sub2ind(size(distanceMatrix), 1:size(distanceMatrix, 1), minRanksSub');

    currMinDistances = distanceMatrix(minRanksIdx);
    
    currMinDistances = currMinDistances(currMinDistances < Inf);
    
    fval = norm(currMinDistances) / sqrt(length(currMinDistances));
    
    % fprintf('.');
    
    if isempty(currBestFval) || boolReset 
        currBestFval = fval;
    elseif (currBestFval > fval)
        optRankingParams = VectorToRankingParameters(rankingParams / max(abs(rankingParams)), csui.session.parameters.segmentation.ranking);
        if ~isempty(optRankingParams)
            PrintMsg(csui.session.parameters.debugLevel, 3, ['New best for ranking: ' num2str(fval) ]);
            csui.session.parameters.segmentation.ranking = optRankingParams;
            currBestFval = fval;          
        end
    end
    
end


function snakes = GrowSeedsAllSizeWeights(seeds, currentImage, parameters)
   tmpParameters = parameters;
   sizeWeights = parameters.segmentation.stars.sizeWeight;
   
   snakes = {};
   for i = 1:length(sizeWeights)
       tmpParameters.segmentation.stars.sizeWeight = sizeWeights(i);
       snakes = [ snakes GrowSeeds(seeds, currentImage, tmpParameters) ];
   end
end

function c = CellRepmat(v, n)
   c = num2cell(repmat(v, [1 n]));
end

function [mask, segments] = GetGTMask(frame)
    global csui;
    segments = ImageFromBuffer('segments', frame);
    gt = find(cellfun(@StarGroundTruth, csui.segBuf{frame}.snakes));
    mask = ismember(segments, gt);
    segments(~mask) = 0;
end

function r = imRound(x, maxX)
   r = min(maxX, max(1, round(x)));
end

function seeds = GetSeeds(nRandomSeedsPerAvgSnake, avgCellDiameter, allSeeds, mask)
    rX = @(x)imRound(x, size(mask, 2));
    rY = @(y)imRound(y, size(mask, 1));
    
    nRandSeeds = round(double(numel(mask) * nRandomSeedsPerAvgSnake) / (avgCellDiameter^2 * pi * 0.25));
    
    
    sx = rX(rand([1 nRandSeeds]) * size(mask, 2));
    sy = rY(rand([1 nRandSeeds]) * size(mask, 1));

    % not very efficient but easy to program
    randSeeds = SeedsFromXY(sx, sy, 'rankingparameteroptimization');
    randSeedsInMask = logical(arrayfun(@(s)mask(rY(s.y), rX(s.x)), randSeeds));
    
    allSeedsInMask = logical(arrayfun(@(s)mask(rY(s.y), rX(s.x)), allSeeds));

%     hold off
%     imshow(mask);
%     hold on
%     for i = find(allSeedsInMask)
%         plot(allSeeds(i).x, allSeeds(i).y, '.b');
%     end
%     for i = find(randSeedsInMask)
%         plot(randSeeds(i).x, randSeeds(i).y, '.r');
%     end
%     hold off

    seeds = [ allSeeds(allSeedsInMask) randSeeds(randSeedsInMask) ];
    
    
end

function [smap, maxQueueLength] = MapSnakesToGroundTruth(snakes, gTSegments, maxOverlap, avgCellDiameter)
   maxQueueLength = 0;
   
   alternativeMinOverlap = 0.5;
   
   minOverlap = min(maxOverlap, alternativeMinOverlap);
%    smap = struct('gTSegment', {}, 'distance', {}, 'rankingFeatures', {}, 'snake', {}, 'gtsegmentArea', {});
   smap = struct('gTSegment', {}, 'distance', {}, 'rankingFeatures', {});
   
   allSegmentsIdx = double(unique(gTSegments)); % including zero...
   allSegmentsIdx = allSegmentsIdx(:)';
   
   segAreas = hist(double(gTSegments(:)), double(allSegmentsIdx));

   for i = 1:length(snakes)
       segment = logical(FullSegment(snakes{i}, size(gTSegments)));
       
       segHistMasked = hist(double(gTSegments(segment)), allSegmentsIdx);
       
       overlapping1 = segHistMasked ./ segAreas;
       overlapping2 = segHistMasked / nnz(segment);
       
       gTSegmentsOverlappingIdx = (allSegmentsIdx > 0) & (segAreas > 0) & ((overlapping1 > minOverlap) | (overlapping2 > alternativeMinOverlap));
       gTSegmentsOverlapping = allSegmentsIdx(gTSegmentsOverlappingIdx);
       
       for j = 1:length(gTSegmentsOverlapping)
           m.gTSegment = gTSegmentsOverlapping(j);
           m.distance = double(nnz(xor(gTSegments == m.gTSegment, segment))) / (0.25 * pi * avgCellDiameter^2); % / segAreas(allSegmentsIdx == m.gTSegment);
           m.rankingFeatures = FromSnakeToRankingPropertiesVect(snakes{i}, avgCellDiameter);

%            m.snake = snakes{i};
%            m.gtsegmentArea = (gTSegments == m.gTSegment);

           smap(end + 1) = m;
           
%            m
% 
%            clf
%            imshow(mat2gray(gTSegments), 'Border', 'tight');
%            hold on
%            plot(snakes{i}.x, snakes{i}.y, 'b');
%            clf
%            imshow(mat2gray(gTSegments == m.gTSegment), 'Border', 'tight');
%            hold on
%            plot(snakes{i}.x, snakes{i}.y, 'b');
%            hold off
       end
   end
end
