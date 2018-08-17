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


function MainMenu(action, mouseClick)
  global csui;

  switch action
      case { 'mouse1', 'mouse2' }
          ShowHelp('Help');
      case 'show session info'
          DisplaySessionInfo();
      case {'load session from file', 'load key map from file', 'load all parameters from file'}
          disp('Select session file...');
          [f, p, ~] = uigetfile(csui.session.parameters.files.destinationDirectory, action);
          if ischar(f)
              switch action
                  case 'load session from file'
                      LoadSession(fullfile(p, f));
                      UILogAction(['% LoadSession(''' fullfile(p, f) ''');']);
                  case 'load key map from file'
                      LoadKeyMapFromFile(fullfile(p, f));
                      UILogAction(['% LoadKeyMapFromFile(''' fullfile(p, f) ''');']);
                  case 'load all parameters from file'
                      LoadParametersFromFile(fullfile(p, f));
                      UILogAction(['% LoadParametersFromFile(''' fullfile(p, f) ''');']);
              end
              csui.lock = true;
          else
              disp('Canceling...');
          end
      case {'load last session', 'load key map from last session', 'load all parameters from last session', ...
            'load recent session', 'load key map from recent session', 'load all parameters from recent session'}  
          lastSession =  any(strcmp(action, { ...
                  'load last session', ...
                  'load key map from last session', ...
                  'load all parameters from last session'}));
          sessionFile = LoadRecentSession(lastSession);
          switch action
              case {'load last session', 'load recent session'}
                  LoadSession(sessionFile);
                  UILogAction(['% LoadSession(''' sessionFile ''');']);
              case {'load key map from last session', 'load key map from recent session'}
                  LoadKeyMapFromFile(sessionFile);
                  UILogAction(['% LoadKeyMapFromFile(''' sessionFile ''');']);
              case {'load all parameters from last session', 'load all parameters from recent session'}
                  LoadParametersFromFile(sessionFile);
                  UILogAction(['% LoadParametersFromFile(''' sessionFile ''');']);
          end
      case 'load empty session'
          disp('Loading defaults...');
          LoadSession('');
      case 'load default key map'
          csui.session.keys = KeyBindings();
          UpdateUIMenu();
          disp('Default key map loaded.');
          csui.lock = true;
      case 'load defaults for all parameters'
          parameters = DefaultParameters();
          CopyParametersFields(parameters);
          disp('Default parameters loaded.');
      case 'save current session'
          SaveSession(false);
      case 'save current session as'
          SaveSession(true);
      case 'show command history'
          fprintf('\nCommand history: \n\n');
          for i = 1:length(csui.session.log)
              fprintf('%s\n', csui.session.log{i});
          end
          fprintf('\n                                                      \n');
      case 'export command history'
          msg = 'Select file name to export command history...';
          disp(msg);
          [a, b] = uiputfile(csui.session.parameters.files.destinationDirectory, msg);
          if isnumeric(a)
              disp('Canceling...');
          else
              historyFile = fullfile(b, a);
              fid = fopen(historyFile, 'w');
              for i = 1:length(csui.session.log)
                  fprintf(fid, '%s\n', csui.session.log{i});
              end
              fclose(fid);
          end
      case 'change default destination directory'
          destDir = uigetdir(pwd, 'Select destination directory');
          if ischar(destDir)
              csui.session.parameters.files.destinationDirectory = destDir;
              disp([ 'Setting "' csui.session.parameters.files.destinationDirectory '" as destination directory.' ]);
              UILogAction(['% csui.session.parameters.files.destinationDirectory = ''' csui.session.parameters.files.destinationDirectory ''';']);
              csui.sessionNeedsSaving = true;
              csui.lock = true;
          else
              disp('Canceling...');
          end
      case 'load movie frames by file selection'
          if isempty(csui.session.parameters.files.imagesFiles)
              f = MultiSelectFiles(csui.session.parameters, 'Select one or more movie frames');
              if ~isnumeric(f)
                  if ischar(f)
                      csui.session.parameters.files.imagesFiles = {f};
                  else
                      csui.session.parameters.files.imagesFiles = f;
                  end
                  UILogAction([ '% ' num2str(length(csui.session.parameters.files.imagesFiles)) ' files have been selected']);
                  csui.sessionNeedsSaving = true;
                  SetDestinationDirectory();
                  ClearImageBuffer('all channels');
                  csui.lock = true;
              end
          else
              msgbox('You have already selected some images in this session. Adding or replacing frames is not (yet?) supported: start a new session instead.', 'Operation not supported');
          end
      case 'select additional channel (fluorescence)'
          curChannel = length(csui.session.parameters.files.additionalChannels) + 1;

          msg = ['You need to specify the way the file names of this channel \n' ...
                 'are mapped to the file names of the main channel. Choose among:\n' ...
                 'Time:   \t each file will be associated to the frame in the main channel\n' ...
                 '        \t with closest creation/modification date and time;\n' ...
                 'Regexp: \t file names in this channel are obtained by replacement\n' ... 
                 '        \t of some string in the file name of the corresponding\n' ...
                 '        \t frame in the main channel: type "doc regexprep"\n'...
                 '        \t in console for further details;\n' ...
                 'Map:    \t specify a mapping function as either the identity function\n' ...
                 '        \t (first -> first, second -> second, etc.) or as an array\n' ...
                 '        \t (e.g. [1 3 5 7 ...] if you want to map first to\n' ...
                 '        \t first, second to third, third to fifth, etc.)' ];
          choice = questdlg(sprintf(msg), 'Select mapping type', 'Time', 'Regexp', 'Map', 'Map');
          switch choice
               case 'Time'
                  f = MultiSelectFiles(csui.session.parameters, ['Select one or more files for the additional channel ' num2str(curChannel) ]);
                  if ~isnumeric(f)
                      if ischar(f)
                          c.files = {f};
                      else
                          c.files = f;
                      end
                      c.computeFluorescence = AskWhichFluorescence();
                      c.fileMap = 'date';
                      csui.session.parameters.files.additionalChannels{curChannel} = c;
                  else
                      disp('Canceling...');
                  end
               case 'Regexp'
                   desc = {'Match string with regular expression:', 'Replace match with string:'};
                   title = ['Specify string replacement for mapping of additional channel ' num2str(curChannel) ];
                   strings = inputdlg(desc, title, 1);
                   if ~isempty(strings)
                      c.files = {};
                      c.computeFluorescence = AskWhichFluorescence();
                      c.fileMap = { 'regexp', strings{1}, strings{2} };
                      csui.session.parameters.files.additionalChannels{curChannel} = c;
                   else
                      disp('Canceling...');
                   end
               case 'Map'
                  f = MultiSelectFiles(csui.session.parameters, ['Select one or more files for the additional channel ' num2str(curChannel) ]);
                  if ~isnumeric(f)
                      if ischar(f)
                          c.files = {f};
                      else
                          c.files = f;
                      end
                      msg = [ ...
                          'Specify the map here (empty = identity map). Some equivalent examples:\n' ...
                          '       [ 1 3 5 7 9 11 13 15 17 19 ]\n' ...
                          '       1:2:20\n' ...
                          '       1 + (0:2:18)\n' ...
                          ];
                      s = inputdlg(msg, ['Specify map for additional channel ' num2str(curChannel) ], 1);
                      if isempty(s)
                          disp('Canceling...');
                      else
                          if isempty(s{1})
                              c.fileMap = '';
                              c.computeFluorescence = AskWhichFluorescence();
                              csui.session.parameters.files.additionalChannels{curChannel} = c;
                          else
                              try 
                                 eval([ 'c.fileMap = ' s{1} ';' ]);
                                 c.computeFluorescence = AskWhichFluorescence();
                                 csui.session.parameters.files.additionalChannels{curChannel} = c;
                              catch
                                 msg = 'You typed an invalid expression.'; 
                                 errordlg(msg); disp('Canceling....');
                              end
                          end
                      end
                  else
                      disp('Canceling...');
                  end
              case ''
                  disp('Canceling...');
          end
          csui.sessionNeedsSaving = true;
          csui.lock = true;
      case 'set memory limit for image buffer'
          msg = 'Set memory limit for image buffer in megabytes';
          limit = inputdlg({ msg }, 'Memory limit', 1, { num2str(csui.session.maxImBufSize)});
          limit = str2double(limit);
          if isempty(limit)
              disp('Canceling...');
          else
              csui.session.maxImBufSize = max(20, limit); % not less than 20 megabytes...
              UILogAction(['% csui.session.maxImBufSize = ' num2str(csui.session.maxImBufSize) ';']);
          end
      case 'start background editor'
          ChangeState('BackgroundEditor');
      case 'start segmentation+tracking editor'
          ChangeState('Editor');
      case 'close request'
          disp('You should not quit like that, press "h" for further help.');
      case 'set debug level'
          SetDebugLevel();
      case {'close', 'quit'}
          Quit();
      otherwise
          if ~isempty(action)
              disp(['Action "' action '" mispelled or not yet implemented.']);
          end
  end
end

function c = AskWhichFluorescence()
  choice = questdlg('Compute fluorescence for this channel?', 'Choose method for fluorescence computation', 'As mean', 'As max', 'No', 'No');
  c = '';
  switch choice
      case 'As mean'
          c = 'avg';
      case 'As max'
          c = 'max';
      case 'No'
          c = 'none';
  end
end
