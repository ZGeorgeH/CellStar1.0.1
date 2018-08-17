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


function ok = LoadSession(sessionFile)
   % sessionFile = file name containing the session to be loaded;
   %               if empty, the default (empty) session is loaded.
   global csui;
   ok = true;
   if isfield(csui, 'session') && isfield(csui, 'sessionNeedsSaving') && ...
           csui.sessionNeedsSaving && ...
           IsSubField(csui, {'session', 'parameters', 'files', 'imagesFiles'}) && ...
           ~isempty(csui.session.parameters.files.imagesFiles)
       choice = questdlg('You are leaving an open session', 'Leaving session...', 'Leave', 'Cancel', 'Cancel');
       switch choice
%            case 'Leave without saving' 
%                % do nothing here...
           case 'Leave'
               SaveSession(false, 'force');
           case 'Cancel'
               ok = false;
               return
       end
   end

   if isempty(sessionFile)
       disp('Resetting session...');
       
       csui = [];
       UIReset('force');
       
       csui.segBuf = {};
       csui.trackingBuf = {};

       csui.session.maxImBufSize = 500; % in megabytes
       csui.session.parameters = DefaultParameters();
       csui.session.keys = KeyBindings();
       UISetNewState('MainMenu');
       csui.sessionFile = '';
       csui.sessionNeedsSaving = false;
       
       csui.session.states.BackgroundEditor.showMask = true;
       % Showing inverted mask is currently disabled
       % csui.session.states.BackgroundEditor.invertedMask = false;
       csui.session.states.BackgroundEditor.circleSize = -1;
       csui.session.states.BackgroundEditor.invertMouseButtons = false;
       csui.session.states.BackgroundEditor.histogramEqualization = true;
       
       csui.session.states.Editor.currentFrame = 1;
       csui.session.states.Editor.channel = 'segmentsColorMasked';
       csui.session.states.Editor.previousChannel = 'originalClean';
       csui.session.states.Editor.currentAdditionalChannel = 1;
       csui.session.states.Editor.showTrackingNumbers = true;
       csui.session.states.Editor.invertMouseButtons = false;
       csui.session.states.Editor.selectedSegment = 0;
       csui.session.states.Editor.editingLastSeed = false;
       csui.session.states.Editor.trackingGTAction.started = false;
       csui.session.states.Editor.showAllSeeds = false;
   else
       fprintf(1, 'Loading previous session from %s...', sessionFile);
       
       session = CSLoad('session', sessionFile);
       if isempty(session)
           disp('Error loading file: session not loaded.');
           msgbox('Error loading file: session not loaded.');
           SetRecentSession(sessionFile, 'remove');
           ok = false;
           return
       end
           
%        try
%            session = load(sessionFile);
%        catch
%            disp('Error loading file: session not loaded.');
%            msgbox('Error loading file: session not loaded.');
%            SetRecentSession(sessionFile, 'remove');
%            ok = false;
%            return
%        end
       
       csui = [];
       csui.imBuf = {};
       csui.segBuf = {};
       csui.session = session.session;
       csui.sessionFile = sessionFile;
       SetRecentSession(sessionFile, 'add');
       csui.sessionNeedsSaving = false;
       tmpState = csui.session.states.current;
       csui.session.states.current = 'MainMenu';
       csui.session.states.Editor.trackingGTAction.started = false;
       ChangeState(tmpState); % just check that everything is fine
       DisplaySessionInfo();
       UIReset('force');

   end
end