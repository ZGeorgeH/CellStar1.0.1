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


function CopyParametersFields(parameters)
   global csui;
   fields = { 'segmentation', 'debugLevel', 'interfaceMode', 'maxThreads', ...
       'connectivity', 'tracking', 'lineage' };
   fprintf('Trying to copy fields: ');
   for i = 1:length(fields)
       if isfield(parameters, fields{i})
           fprintf([fields{i} '...']);
           csui.session.parameters.(fields{i}) = parameters.(fields{i});
       end
   end
   fprintf('\n');
end
