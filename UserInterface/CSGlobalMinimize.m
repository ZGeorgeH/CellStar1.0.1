%     Copyright 2016 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function [x,bestfval] = CSGlobalMinimize(f, startingPoint, LB, UB, stopIfValBelow, stopMaxTime, verbose, algorithm)
        assert(all(size(LB) == size(UB)), 'Invalid bound dimensions');
        switch algorithm
            case 'Global Search'
                if exist('GlobalSearch')
                        if verbose
                            verbose = 'on';
                        else
                            verbose = 'off';
                        end
                        if length(LB) == 1
                            LB = ones(size(startingPoint)) * LB;
                            UB = ones(size(startingPoint)) * UB;
                        end
                        gs = GlobalSearch('Display', verbose, 'MaxTime', stopMaxTime);
                        opts = optimset('Algorithm','interior-point');
                        problem = createOptimProblem('fmincon','x0',startingPoint,...
                            'objective',f,'lb',LB,'ub',UB,...
                            'options',opts);
                        [x,bestfval] = run(gs,problem);
                else if exist('nlopt_minimize')
                        stop.maxtime = stopMaxTime;
                        stop.fmin_max = stopIfValBelow;
                        if verbose
                            stop.verbose = 1;
                        else
                            stop.verbose = 0;
                        end
                        [x,bestfval, retval] = nlopt_minimize(NLOPT_GN_DIRECT_L, f, {}, LB, UB, startingPoint, stop);
                        else
                            disp('I dont know how to optimize, sorry! The optimization package is missing...');
                            x = [];
                            bestfval = [];
                        end
                end
            otherwise 
                disp('Unknown optimization method');
        end
end
