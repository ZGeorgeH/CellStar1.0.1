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


function UILogAction(actionString, varargin)
   global csui;
   
   if ~isfield(csui.session, 'log')
       csui.session.log{1} = ...
           [ '% Starting logging, CellStar version ' ...
             num2str(csui.session.parameters.cellStarVersion) ];
   end
   
   idx = length(csui.session.log) + 1; 
   if ~isempty(varargin)
       if strcmp(varargin{1}, 'appendToLast')
           idx = length(csui.session.log);
       end
       if strcmp(varargin{1}, 'replaceLast')
           idx = length(csui.session.log);
           csui.session.log{idx} = '';
       end
   end
   
   if (length(csui.session.log) < idx)
        csui.session.log{idx, 1} = actionString;
   else
       csui.session.log{idx, 1} = [ csui.session.log{idx, 1} ' ' actionString ] ;
   end
   csui.sessionNeedsSaving = true;
end
