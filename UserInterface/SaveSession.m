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


function ok = SaveSession(newFile, varargin)
    global csui;
    
    force = ~isempty(varargin) && strcmp(varargin{1}, 'force');
    
    if newFile || force || csui.sessionNeedsSaving
        ok = false;
        session = csui.session;    

        if newFile || isempty(csui.sessionFile)
            mkdir(csui.session.parameters.files.destinationDirectory);
            disp('Select file name to save current session...');
            [a, b] = uiputfile( ...
                         fullfile(csui.session.parameters.files.destinationDirectory, ...
                                  'session.mat'), ...
                         'Select file name to save current session...');
            if isnumeric(a)
                disp('Session not saved...');
                return
            else
                csui.sessionFile = fullfile(b, a);
            end
        end
        csui.session = session;
        PrintMsg(csui.session.parameters.debugLevel, 4, ['Saving session to ' csui.sessionFile ' ...']);
        CSSave(csui.sessionFile, 'session');
        SetRecentSession(csui.sessionFile, 'add');
        ok = true;
        csui.sessionNeedsSaving = false;
    else
        disp('Nothing to save yet.');
        ok = true;
    end
end
