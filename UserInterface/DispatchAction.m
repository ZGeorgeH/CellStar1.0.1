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


function DispatchAction(action, mouseClick)
  global csui;
  cr = 'Console ready.';
  fprintf(repmat('\b', [1 length(cr)]));
  fprintf('\n');
  ticID = tic;
  if exist('csui', 'var') && IsSubField(csui, {'session', 'states', 'current'})
      
      % Creating a string representing the equivalent of the current action
      % as a command line statement.
      % This ad hoc implementation might be much better generalized...
      if (~isfield(mouseClick, 'button') || isempty(mouseClick.button))
          mouseClickToString = 'struct(''button'', '''')';
      else
          mouseClickToString = ...
               [ 'struct(''button'', ''' mouseClick.button ...
                 ''', ''x'', ' num2str(mouseClick.x) ...
                 ', ''y'', ' num2str(mouseClick.y) ')' ];
      end
      actionString = [ csui.session.states.current '(''' action ''', ' mouseClickToString ');' ];
      PrintMsg(csui.session.parameters.debugLevel, 4, [ 'New action:' actionString ]);
      UILogAction(actionString);

      % Dispatching action to the function corresponding to the current
      % state
      feval(csui.session.states.current, action, mouseClick);
      if exist('csui', 'var') && IsSubField(csui, {'session', 'states', 'current'})
          t = toc(ticID);
          if (csui.session.parameters.debugLevel > 3) || ...
             ((csui.session.parameters.debugLevel == 3) && (t > 30))
                 disp(['Elapsed time: ' num2str(t)]);
          end
          UILogAction([ '% Time: ' num2str(t) ' s.'], 'appendToLast');
          fprintf(cr);
      end
  end
end
