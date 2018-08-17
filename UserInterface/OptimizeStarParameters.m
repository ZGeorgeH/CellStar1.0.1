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
%
% Try to optimize parameters for stars, based on segmentation ground
% truth, that is stars added or edited manually, or manually marked as 
% ground truth.
% Currently only one optimization method is made available, which is the
% one that apparently works better: simulated annealing.
% Parameter: 
% - broadness, from 0.001 to 1, which defines how "broad" is the
%   search: it affects the search range, the temperature for simulated
%   annealing, the number of stall iterations before breaking the search.
%   The higher the broadness the longer the search.

% TODO:
% - separate optimization of contour from ranking
% - add ground truth itself to ranking optimization, so that the
% optimization procedure knows how a good snake looks like
% - use as seeds for ranking: 
%     allSeeds generated in last segmentation
%     round, if exist, and some uniformly generated
%   both intersected with dilated ground truth area

function optimizedStarParameters = OptimizeStarParameters(broadness, varargin)
    global csui;

    parameters = csui.session.parameters;
    nFrames = length(parameters.files.imagesFiles);

    if ~isempty(varargin)
      searchStrategy = varargin{1};
    else
      searchStrategy = 'Global Search';
    end

    UILoadSegmentationIfNeeded(1:nFrames);

    % Optimization of contour parameters
    allGTSnakes = cellfun(@(x)ExtractGTSnakes(x.snakes), csui.segBuf, 'UniformOutput', false);

    if IsSubField(parameters, {'segmentation', 'stars', 'parameterLearningRingResize'})
      ringResize = parameters.segmentation.stars.parameterLearningRingResize;
    else
      ringResize = 1;
    end

    internalErosion = 0.10 * ringResize;
    ringTotalArea = internalErosion + max(0.40 * ringResize, 0.10);
    externalErosion = 1 - ringTotalArea;

    [moreGTSnakes, gtstars, gTSeeds, intermediateImages] = GenRandomSeedsFromGT(allGTSnakes, 3, externalErosion, internalErosion);

    if (gtstars == 0)
      disp('No segmentation ground truth available for optimization of stars parameters.');
      optimizedStarParameters = [];
      return
    end

    start = FromParametersToPoint(parameters);
  
    startFitness = StarsDistance( ...
                       moreGTSnakes, ...
                       gTSeeds, ...
                       intermediateImages, ...
                       FromPointToParameters(start, parameters), ...
                       true ...
                    );

    Fitness = @(point)StarsDistance( ...
                       moreGTSnakes, ...
                       gTSeeds, ...
                       intermediateImages, ...
                       FromPointToParameters(point, parameters), ...
                       false ...
                    );

    disp([ ...
          num2str(gtstars) ...
          ' stars found in ground truth in frame(s) ' num2str(find(cellfun(@numel, allGTSnakes))) ...
          ', starting optimization of contour parameters with:  initial-fval=' ...
          num2str(startFitness) ...
       ]);
    %       '   range=' num2str(range * 100) ...
    %      '%   init-temperature=' num2str(temperature) ...
    %       '   stall-iter=' num2str(stallIter) ...
    %       '   reannil=' num2str(reannil) ...

   x = start;
   bestfval = startFitness;
   switch searchStrategy
      case 'Simulated Annealing'
           if ~exist('simulannealbnd')
               disp('Simulated annealing algorithm not found... Missing optimization package?');
           else
              broadness = max(min(1, broadness), 0.001);
              range = broadness * 10;
              temperature = 500 + (range * 100)^2;
              % % % % % % % % % %   stallIter = int32(80 + range^2 * 100);
              stallIter = int32(temperature / 4);
              reannil = double(stallIter / 6);
              exponent = 1 - 0.0002 / max(broadness^2, 0.002);
              mytempfun = @(optimValues, options)TemperatureFun(optimValues, options, exponent);

              LB = [];
              UB = [];
              [x, bestfval] = simulannealbnd(Fitness, start, LB, UB, saoptimset('Display', 'iter', 'DisplayInterval', 100, 'StallIterLimit', stallIter, 'InitialTemperature', temperature, 'ReannealInterval', reannil,  'TemperatureFcn', mytempfun, 'MaxFunEvals', 10^8));
           end
%       case 'gradient'
%           [x, bestfval] = fminsearch(Fitness, start, optimset('Display', 'iter'));
%           [x, bestfval] = lsqnonlin(VectFitness, start, LB, UB, optimset('DiffMinChange', 0.1));
%           bestfval = sqrt(bestfval) / gtstars;
%       case 'ga'
%           A = zeros(5);
%           A(1, 1) = -1;
%           b = zeros(1, 5);
%           [x, bestfval] = ga(Fitness, length(start), A, b, [], [], LB, UB, [], gaoptimset('Display', 'iter', 'CrossoverFraction', 0, 'PopulationSize', 2000));
       otherwise
           % Global Search, seems to work better for contour optimization
           LB = -10e5;
           UB = 10e5;
           stopIfValBelow = 0.10;
           stopMaxTime = 1800;
           verbose = true;
           searchStrategy = 'Global Search';
           [x, bestfval] = CSGlobalMinimize(Fitness, start, LB, UB, stopIfValBelow, stopMaxTime, verbose, searchStrategy);
  end
   

%   switch searchType
%   end
  
  optParams = FromPointToParameters(x, parameters);
  
  s = optParams.segmentation.stars;
  
  origSW = parameters.segmentation.stars.sizeWeight;
  
  s.sizeWeight = OptimizeStarParametersSetSizeWeight(origSW, s.sizeWeight);
  
  optimizedStarParameters = s;

   fprintf('\n');
   if (bestfval == startFitness)
       disp(['Contour parameters optimization terminated, fval unchanged at ' num2str(bestfval)]);
   else
       disp(['Contour parameters optimization terminated with fval reduced from initial value of ' num2str(startFitness) ' to ' num2str(bestfval) '.']);
   end
  
%   % Optimization of ranking parameters
%   
%   [moreGTSnakes, ~, gTSeeds, intermediateImages] = GenRandomSeedsFromGT(allGTSnakes, 50, 0.1, 0);
% 
%   parameters.segmentation.stars = optimizedStarParameters;
%   
%   allSnakes = GrowGTSeeds(gTSeeds, intermediateImages, parameters);
%  
%   snakesCell = [allSnakes{:}];
%   gtSnakesCell = [moreGTSnakes{:}];
%   
%   snakesPropsMatrixCell = cellfun( ...
%        @(s)FromSnakeToRankingPropertiesVect(s, parameters.segmentation.avgCellDiameter), ...
%        snakesCell, ...
%        'UniformOutput', false);
%    
%   snakesPropsMatrix = cell2mat(snakesPropsMatrixCell');
%   
%   oldRanks = snakesPropsMatrix * RankingParametersToVector(parameters.segmentation.ranking)';
%   
%   distanceVect = SnakesDistance(gtSnakesCell, snakesCell)';
% 
%   distanceVect = distanceVect.^0.25;
%   
%   newRankParametersVect = snakesPropsMatrix \ distanceVect;
%   
%   optimizedRankParameters = VectorToRankingParameters(newRankParametersVect, parameters.segmentation.ranking);
% 
%   newRanks = snakesPropsMatrix * newRankParametersVect;
%   
%   
%   oldRanksMin = [oldRanks ones(size(oldRanks))];
%   normf = oldRanksMin \ distanceVect;
%   oldRanksNorm = oldRanksMin * normf;
%   
%   oldRanksFval = norm(distanceVect - oldRanksNorm);
%   newRanksFval = norm(distanceVect - newRanks);
%   
%   disp(['Rank parameters optimization terminated with fval reduced from (supposed) initial value of ' num2str(oldRanksFval) ' to ' num2str(newRanksFval) '.']);
  
%   clf;
%   scatter(distanceVect, oldRanksNorm, 'b');
%   hold on;
%   scatter(distanceVect, newRanks, 'r');
%   hold off;
   
end

function [moreGTSnakes, gtstars, gTSeeds, intermediateImages] = GenRandomSeedsFromGT(allGTSnakes, nAdditionalRandSeeds, erodeOut, erodeIn)
  % nAdditionalRandSeeds = additional random seeds per ground truth seed,
  % chosen around the centroid of the star
  
  gTSeeds = cell(size(allGTSnakes));
  intermediateImages = cell(size(allGTSnakes));
  
  
  moreGTSnakes = cell(size(allGTSnakes));
  
  gtstars = 0;
  for i = length(allGTSnakes):-1:1
      if ~isempty(allGTSnakes{i})
          for j = length(allGTSnakes{i}):-1:1
              currGTSnake = allGTSnakes{i}{j};
              seed.x = currGTSnake.segmentProps.centroidX;
              seed.y = currGTSnake.segmentProps.centroidY;
              seed.from = 'starparameteroptimization';
              
              erodedINPoly = currGTSnake.inPolygon;
              cr = max(1, round(size(erodedINPoly, 1) / 2));
              cc = max(1, round(size(erodedINPoly, 2) / 2));
              
              % erodedINPoly is a sort of ring around the centroid where
              % additional random seeds are chosen
              erodedINPolyOut = erodedINPoly;
              
              if (erodeOut > 0)
                  while (1 - (nnz(erodedINPolyOut) / nnz(erodedINPoly)) < erodeOut)
                      erodedINPolyOut = logical(ImageErode(erodedINPolyOut, 1));
                  end
              end
              erodedINPolyIn = true(size(erodedINPoly));
              erodedINPolyIn(cr, cc) = false;
              if (erodeIn > 0)
                  while (1 - (nnz(erodedINPolyIn & erodedINPoly) / nnz(erodedINPoly)) < erodeIn)
                      erodedINPolyIn = logical(ImageErode(erodedINPolyIn, 1));
                  end
              end
              erodedINPoly = erodedINPolyOut & erodedINPolyIn;
              
              if ~any(erodedINPoly)
                  erodedINPoly(cr, cc) = true;
              end
                            
              % not efficient, but easier to program
              for k = (nAdditionalRandSeeds+1):-1:1
                  starIdx = sub2ind([length(allGTSnakes{i}) nAdditionalRandSeeds+1], j, k);
                  moreGTSnakes{i}{starIdx} = currGTSnake;
                  currSeed = seed;
                  if (k > 1)
                      r = ceil(rand(1) * nnz(erodedINPoly));
                      nz = find(erodedINPoly);
                      e = false(size(erodedINPoly));
                      e(nz(r)) = true;
                      
                      [r, c] = ind2sub(size(e), nz(r));
                      
                      currSeed.x = currGTSnake.inPolygonXY(2) + c - 1;
                      currSeed.y = currGTSnake.inPolygonXY(1) + r - 1;
                      
                  end
                  gTSeeds{i}.seeds(starIdx) = currSeed;
                  
              end
              gtstars = gtstars + 1;
          end
          intermediateImages{i} = ComposeIntermediateImages(i);
      else
          % allGTSnakes{i} = {};
          moreGTSnakes{i} = {};
      end
  end
end

function temperature = TemperatureFun(optimValues, options, exponent)
    temperature = options.InitialTemperature .* exponent.^optimValues.k;
end