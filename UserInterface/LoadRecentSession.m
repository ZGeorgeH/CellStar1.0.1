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


function sessionFile = LoadRecentSession(loadLast)
    % returns the file name of the chosen session
    sessionFile = '';
    if ~ispref('CellStar', 'PreviousSessions') || isempty(getpref('CellStar', 'PreviousSessions'))
        errordlg('No sessions previously saved.');
    else
        ps = getpref('CellStar', 'PreviousSessions');
        if loadLast
%             ok = LoadSession(ps{1});
            sessionFile = ps{1};
        else
            psrev = cell(size(ps));
            for i = 1:length(ps)
                [~,n,e] = fileparts(ps{i});
                psrev{1, i} = [ [n, e] '   (' ps{i} ')' ];
            end
            [s, ok1] = listdlg('ListString', psrev, 'PromptString', 'Select recent session:', 'SelectionMode', 'Single');
            if ok1
%                 ok = LoadSession(ps{s(1)});
                sessionFile = ps{s(1)};
            else
                disp('Canceling...');
            end
        end
    end
end
