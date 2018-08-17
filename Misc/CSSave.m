%     Copyright 2014, 2015 Cristian Versari
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

function CSSave(fileName, varargin)

    if isempty(varargin)
        disp('CSSave: cannot save all the workspace!');
        return
    end

    for i = 1:length(varargin)
        tmpVar = evalin('caller', varargin{i});
        eval([ varargin{i} ' = tmpVar;' ]);
    end
    
    defaultParams = DefaultParameters();
    cellStarVersion = defaultParams.cellStarVersion;
    
    % This is dangerous if the caller is using a variable
    % with name "cellStarVersion" ...
    
    fields = varargin;

    if strcmp(defaultParams.hostLanguage, 'octave')
      matFormat = '-z';
    else
      matFormat = '-mat';
    end
    
    fields{end+1} = 'cellStarVersion';
    fields{end+1} = matFormat;
    
    save(fileName, fields{:});
end
