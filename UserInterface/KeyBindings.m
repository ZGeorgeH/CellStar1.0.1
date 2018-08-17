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


function keys = KeyBindings()
    % User interface key bindings
    %
    % Keys can be specified as follows:
    % keys.MainMenu(end + 1).modifiers = { 'mod1', 'mod2', ... };
    % keys.MainMenu(end).key = { 'key1', 'key2', ... };
    % keys.MainMenu(end).action = 'action string';
    % where
    %   'modN' can be any of 'control', 'alt', 'shift'; _all_ the modifiers at
    %          once are required to fire the corresponding action
    %   'keyN' is any key (e.g. 'a', 'b', 'c', 'd', '1', etc)
    %          if more than one key is listed, _any_ of those keys can fire
    %          the corresponding action, when all the modifiers are present
    %          as previously remarked
    %
    % Octave and Matlab behave differently:
    % - if you want to catch the 'return' key and be compatible with both, 
    %   use { 'return', [ 10 ''] } as actionMap().key

    keys.MainMenu = [];

    % Remember that: 'h' is reserved for help, independently of modifiers!
    % Indeed the following would appear in the help but would not work:
    %   keys.MainMenu(end + 1).modifiers = { 'control', 'alt', 'shift' };
    %   keys.MainMenu(end).key = { 'h', 'H' };
    %   keys.MainMenu(end).action = 'This key will not work because it is reserved';

    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'l' };
    keys.MainMenu(end).action = 'load last session';
    keys.MainMenu(end).subMenu = { 'Load session' };

    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'l' };
    keys.MainMenu(end).action = 'load recent session';
    keys.MainMenu(end).subMenu = { 'Load session' };

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'l' };
    keys.MainMenu(end).action = 'load session from file';
    keys.MainMenu(end).subMenu = { 'Load session' };

    keys.MainMenu(end + 1).modifiers = { 'alt' 'shift' };
    keys.MainMenu(end).key = { 'l' };
    keys.MainMenu(end).action = 'load empty session';
    keys.MainMenu(end).subMenu = { 'Load session' };
   
    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'k' };
    keys.MainMenu(end).action = 'load key map from last session';
    keys.MainMenu(end).subMenu = { 'Key map' };

    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'k' };
    keys.MainMenu(end).action = 'load key map from recent session';
    keys.MainMenu(end).subMenu = { 'Key map' };

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'k' };
    keys.MainMenu(end).action = 'load key map from file';
    keys.MainMenu(end).subMenu = { 'Key map' };

    keys.MainMenu(end + 1).modifiers = { 'alt' 'shift' };
    keys.MainMenu(end).key = { 'k' };
    keys.MainMenu(end).action = 'load default key map';
    keys.MainMenu(end).subMenu = { 'Key map' };
    
    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'p' };
    keys.MainMenu(end).action = 'load all parameters from last session';
    keys.MainMenu(end).subMenu = { 'Load parameters' };

    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'p' };
    keys.MainMenu(end).action = 'load all parameters from recent session';
    keys.MainMenu(end).subMenu = { 'Load parameters' };

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'p' };
    keys.MainMenu(end).action = 'load all parameters from file';
    keys.MainMenu(end).subMenu = { 'Load parameters' };

    keys.MainMenu(end + 1).modifiers = { 'alt' 'shift' };
    keys.MainMenu(end).key = { 'p' };
    keys.MainMenu(end).action = 'load defaults for all parameters';
    keys.MainMenu(end).subMenu = { 'Load parameters' };

    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'i' };
    keys.MainMenu(end).action = 'show session info';
    keys.MainMenu(end).subMenu = { 'Current session' };

    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 's' };
    keys.MainMenu(end).action = 'save current session';
    keys.MainMenu(end).subMenu = { 'Current session' };

    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 's' };
    keys.MainMenu(end).action = 'save current session as';
    keys.MainMenu(end).subMenu = { 'Current session' };

    keys.MainMenu(end + 1).modifiers = { '' };
    keys.MainMenu(end).key = { 'c' };
    keys.MainMenu(end).action = 'show command history';
    keys.MainMenu(end).subMenu = { 'Current session' };

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'c' };
    keys.MainMenu(end).action = 'export command history';
    keys.MainMenu(end).subMenu = { 'Current session' };

    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'm' };
    keys.MainMenu(end).action = 'load movie frames by file selection';
    keys.MainMenu(end).subMenu = {};
    
    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'm' };
    keys.MainMenu(end).action = 'select additional channel (fluorescence)';
    keys.MainMenu(end).subMenu = {};
    
    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'b' };
    keys.MainMenu(end).action = 'start background editor';
    keys.MainMenu(end).subMenu = {};

    keys.MainMenu(end + 1).modifiers = { 'shift' };
    keys.MainMenu(end).key = { 'e' };
    keys.MainMenu(end).action = 'start segmentation+tracking editor';
    keys.MainMenu(end).subMenu = {};

    keys.MainMenu(end + 1).modifiers = {};
    keys.MainMenu(end).key = { 'd' };
    keys.MainMenu(end).action = 'change default destination directory';
    keys.MainMenu(end).subMenu = {};

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'm' };
    keys.MainMenu(end).action = 'set memory limit for image buffer';
    keys.MainMenu(end).subMenu = {};

    keys.MainMenu(end + 1).modifiers = { };
    keys.MainMenu(end).key = { 'v' };
    keys.MainMenu(end).action = 'set debug level';
    keys.MainMenu(end).subMenu = {};

    keys.MainMenu(end + 1).modifiers = { 'alt' };
    keys.MainMenu(end).key = { 'q' };
    keys.MainMenu(end).action = 'quit';
    keys.MainMenu(end).subMenu = {};

    
    keys.BackgroundEditor = [];

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'a' };
    keys.BackgroundEditor(end).action = 'select frames to average to compute background';
    keys.BackgroundEditor(end).subMenu = { 'Set background as...' };

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'a' };
    keys.BackgroundEditor(end).action = 'set background as average of all frames';
    keys.BackgroundEditor(end).subMenu = { 'Set background as...' };
    
    keys.BackgroundEditor(end + 1).modifiers = { 'alt' 'shift' };
    keys.BackgroundEditor(end).key = { 'a' };
    keys.BackgroundEditor(end).action = 'set background as mean brightness of first frame';
    keys.BackgroundEditor(end).subMenu = { 'Set background as...' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'l' };
    keys.BackgroundEditor(end).action = 'load background from file';
    keys.BackgroundEditor(end).subMenu = {};

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 't' };
    keys.BackgroundEditor(end).action = 'toggle background mask';
    keys.BackgroundEditor(end).subMenu = { 'Toggle...' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'e' };
    keys.BackgroundEditor(end).action = 'toggle histogram equalization';
    keys.BackgroundEditor(end).subMenu = { 'Toggle...' };
    
      % Showing inverted mask is currently disabled
%     keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
%     keys.BackgroundEditor(end).key = { 'i' };
%     keys.BackgroundEditor(end).action = 'show normal-inverted background mask';
%     keys.BackgroundEditor(end).subMenu = { 'Toggle...' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'i' };
    keys.BackgroundEditor(end).action = 'invert background mask';
    keys.BackgroundEditor(end).subMenu = { 'Edit background mask' };

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'm' };
    keys.BackgroundEditor(end).action = 'autodetect background mask';
    keys.BackgroundEditor(end).subMenu = { 'Edit background mask' };

    keys.BackgroundEditor(end + 1).modifiers = { };
    keys.BackgroundEditor(end).key = { 'w' };
    keys.BackgroundEditor(end).action = 'widen background mask';
    keys.BackgroundEditor(end).subMenu = { 'Edit background mask' };

    keys.BackgroundEditor(end + 1).modifiers = { };
    keys.BackgroundEditor(end).key = { 's' };
    keys.BackgroundEditor(end).action = 'shrink background mask';
    keys.BackgroundEditor(end).subMenu = { 'Edit background mask' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'r' };
    keys.BackgroundEditor(end).action = 'reset background mask';
    keys.BackgroundEditor(end).subMenu = { 'Edit background mask' };
    
    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'b' };
    keys.BackgroundEditor(end).action = 'blur by neighbor pixels';
    keys.BackgroundEditor(end).subMenu = { 'Blur background' };

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'd' };
    keys.BackgroundEditor(end).action = 'blur by circle size';
    keys.BackgroundEditor(end).subMenu = { 'Blur background' };

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'f' };
    keys.BackgroundEditor(end).action = 'apply low-pass filter by circle size';
    keys.BackgroundEditor(end).subMenu = { 'Blur background' };
    
    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { '0' };
    keys.BackgroundEditor(end).action = 'swap mouse buttons (paint-erase)';
    keys.BackgroundEditor(end).subMenu = {};

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { '2' };
    keys.BackgroundEditor(end).action = 'increase circle size';
    keys.BackgroundEditor(end).subMenu = { 'Circle size' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { '1' };
    keys.BackgroundEditor(end).action = 'decrease circle size';
    keys.BackgroundEditor(end).subMenu = { 'Circle size' };

    keys.BackgroundEditor(end + 1).modifiers = {};
    keys.BackgroundEditor(end).key = { 'c' };
    keys.BackgroundEditor(end).action = 'set average (adult) cell diameter';
    keys.BackgroundEditor(end).subMenu = {};

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'e' };
    keys.BackgroundEditor(end).action = 'start segmentation-tracking editor';
    keys.BackgroundEditor(end).subMenu = {};

    keys.BackgroundEditor(end + 1).modifiers = { 'shift' };
    keys.BackgroundEditor(end).key = { 'x' };
    keys.BackgroundEditor(end).action = 'return to main menu';
    keys.BackgroundEditor(end).subMenu = {};

    keys.BackgroundEditor(end + 1).modifiers = { 'alt' };
    keys.BackgroundEditor(end).key = { 'q' };
    keys.BackgroundEditor(end).action = 'quit';
    keys.BackgroundEditor(end).subMenu = {};

    
    keys.Editor = [];

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'v' };
    keys.Editor(end).action = 'set debug level';
    keys.Editor(end).actionShort = 'set debug level';
    keys.Editor(end).subMenu = {};
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { '0' };
    keys.Editor(end).action = 'swap mouse buttons';
    keys.Editor(end).actionShort = 'swap mouse buttons';
    keys.Editor(end).subMenu = {};
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'd' };
    keys.Editor(end).action = 'delete selected segment';
    keys.Editor(end).actionShort = 'del selected segment';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'd' };
    keys.Editor(end).action = 'delete all segments in frame except ground truth';
    keys.Editor(end).actionShort = 'del segs';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'd' };
    keys.Editor(end).action = 'delete all segments in frame including ground truth';
    keys.Editor(end).actionShort = 'del segs+GT';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'r' };
    keys.Editor(end).action = 'remove last added seed';
    keys.Editor(end).actionShort = 'rem last seed';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'r' };
    keys.Editor(end).action = 'remove all seeds in current frame';
    keys.Editor(end).actionShort = 'rem seeds in frame';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'r' };
    keys.Editor(end).action = 'remove all seeds in all frames';
    keys.Editor(end).actionShort = 'rem all seeds';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'u' };
    keys.Editor(end).action = 'undelete last deleted segment';
    keys.Editor(end).actionShort = 'undel segment';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'u' };
    keys.Editor(end).action = 'undelete all segments in current frame';
    keys.Editor(end).actionShort = 'undel segs in frame';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { };
    keys.Editor(end).key = { '9' };
    keys.Editor(end).action = 'add selected star to segmentation ground truth';
    keys.Editor(end).actionShort = 'add selected to GT';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { '9' };
    keys.Editor(end).action = 'add all stars in frame to segmentation ground truth';
    keys.Editor(end).actionShort = 'add frame to GT';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { '9' };
    keys.Editor(end).action = 'add all stars in all frames to segmentation ground truth';
    keys.Editor(end).actionShort = 'add all to GT';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { };
    keys.Editor(end).key = { '8' };
    keys.Editor(end).action = 'add selected star to segmentation ground truth for parameter learning';
    keys.Editor(end).actionShort = 'add selected to GT+';
    keys.Editor(end).subMenu = { 'Edit segmentation' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { '8' };
    keys.Editor(end).action = 'add all stars in frame to segmentation ground truth for parameter learning';
    keys.Editor(end).actionShort = 'add frame to GT+';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { '8' };
    keys.Editor(end).action = 'add all stars in all frames to segmentation ground truth for parameter learning';
    keys.Editor(end).actionShort = 'add all to GT+';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'i' };
    keys.Editor(end).action = 'import ground truth seeds from CSV file';
    keys.Editor(end).actionShort = 'import seg GT';
    keys.Editor(end).subMenu = { 'Edit segmentation' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'y' };
    keys.Editor(end).action = 'apply changes quickly';
    keys.Editor(end).actionShort = 'apply quickly';
    keys.Editor(end).subMenu = { 'Apply changes' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'y' };
    keys.Editor(end).action = 'apply changes properly';
    keys.Editor(end).actionShort = 'apply properly';
    keys.Editor(end).subMenu = { 'Apply changes' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { '.', 'period' };
    keys.Editor(end).action = 'trace for selected segment ends here';
    keys.Editor(end).actionShort = 'trace ends';
    keys.Editor(end).subMenu = { 'Edit tracking ground truth' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { '.', 'period' };
    keys.Editor(end).action = 'trace for selected segment starts here';
    keys.Editor(end).actionShort = 'trace starts';
    keys.Editor(end).subMenu = { 'Edit tracking ground truth' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { '-', 'hyphen' };
    keys.Editor(end).action = 'connect selected segment to trace in next frame';
    keys.Editor(end).actionShort = 'join tr. next';
    keys.Editor(end).subMenu = { 'Edit tracking ground truth' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { '-', 'hyphen' };
    keys.Editor(end).action = 'connect selected segment to trace in previous frame';
    keys.Editor(end).actionShort = 'join tr. prev';
    keys.Editor(end).subMenu = { 'Edit tracking ground truth' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { '-', 'hyphen' };
    keys.Editor(end).action = 'remove tracking ground truth for selected segment';
    keys.Editor(end).actionShort = 'del tr. GT';
    keys.Editor(end).subMenu = { 'Edit tracking ground truth' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'l' 'rightarrow' 'right' };
    keys.Editor(end).action = 'next frame';
    keys.Editor(end).actionShort = 'next frame';
    keys.Editor(end).subMenu = { 'Switch to other frame' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'l' 'rightarrow' 'right' };
    keys.Editor(end).action = 'go forward 5 frames';
    keys.Editor(end).actionShort = 'forward 5 frames';
    keys.Editor(end).subMenu = { 'Switch to other frame' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'l' 'rightarrow' 'right' };
    keys.Editor(end).action = 'jump to last frame';
    keys.Editor(end).actionShort = 'last frame';
    keys.Editor(end).subMenu = { 'Switch to other frame' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'j' 'leftarrow' 'left' };
    keys.Editor(end).action = 'previous frame';
    keys.Editor(end).actionShort = 'previous frame';
    keys.Editor(end).subMenu = { 'Switch to other frame' };
    
    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'j' 'leftarrow' };
    keys.Editor(end).action = 'go back 5 frames';
    keys.Editor(end).actionShort = 'back 5 frames';
    keys.Editor(end).subMenu = { 'Switch to other frame' };
    
    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'j' 'leftarrow' };
    keys.Editor(end).action = 'jump to first frame';
    keys.Editor(end).actionShort = 'first frame';
    keys.Editor(end).subMenu = { 'Switch to other frame' };
    
    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'j' };
    keys.Editor(end).action = 'choose frame to jump to';
    keys.Editor(end).actionShort = 'choose frame';
    keys.Editor(end).subMenu = { 'Switch to other frame' };
    
    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'l' };
    keys.Editor(end).action = 'preload (and save) all frames for current channel';
    keys.Editor(end).actionShort = 'load+save curr chan';
    keys.Editor(end).subMenu = {};

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'i' 'uparrow' 'up' };
    keys.Editor(end).action = 'toggle original image (clean)';
    keys.Editor(end).actionShort = 'orig. image clean';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'o' };
    keys.Editor(end).action = 'toggle original image';
    keys.Editor(end).actionShort = 'original image';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'b' };
    keys.Editor(end).action = 'toggle cell border image';
    keys.Editor(end).actionShort = 'cell border';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'c' };
    keys.Editor(end).action = 'toggle cell content image';
    keys.Editor(end).actionShort = 'cell content';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'c' };
    keys.Editor(end).action = 'toggle cell content mask';
    keys.Editor(end).actionShort = 'cell cont mask';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'm' };
    keys.Editor(end).action = 'toggle foreground mask';
    keys.Editor(end).actionShort = 'foreground mask';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'n' };
    keys.Editor(end).action = 'toggle tracking numbers';
    keys.Editor(end).actionShort = 'toggle numbers';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'toggle current additional (fluorescence) channel';
    keys.Editor(end).actionShort = 'additional channel';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'switch to next additional (fluorescence) channel';
    keys.Editor(end).actionShort = 'cycle additional channels';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 's' };
    keys.Editor(end).action = 'toggle segments image';
    keys.Editor(end).actionShort = 'show segments';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 't' };
    keys.Editor(end).action = 'toggle tracking image';
    keys.Editor(end).actionShort = 'show tracking';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };
    
    keys.Editor(end + 1).modifiers = { 'control' };
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'plot fluorescence graph of all traces';
    keys.Editor(end).actionShort = 'all fluo graph';
    keys.Editor(end).subMenu = { 'Fluorescence analysis' };
    
    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'plot fluorescence graph of selected trace';
    keys.Editor(end).actionShort = '1 fluo graph';
    keys.Editor(end).subMenu = { 'Fluorescence analysis' };
    
    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'store fluorescence in a variable';
    keys.Editor(end).actionShort = 'fluo in var';
    keys.Editor(end).subMenu = { 'Fluorescence analysis' };
    
    keys.Editor(end + 1).modifiers = { 'control' 'shift' };
    keys.Editor(end).key = { 'f' };
    keys.Editor(end).action = 'export fluorescence to a csv file';
    keys.Editor(end).actionShort = 'fluo to csv';
    keys.Editor(end).subMenu = { 'Fluorescence analysis' };
    
    

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'p' };
    keys.Editor(end).action = 'set segmentation+tracking stubbornness';
    keys.Editor(end).actionShort = 'set seg+track stubb.';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    
    
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'e' };
    keys.Editor(end).action = 'automatically tune contour parameters (quick search)';
    keys.Editor(end).actionShort = 'tune c. params fast';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'e' };
    keys.Editor(end).action = 'automatically tune contour parameters (standard search)';
    keys.Editor(end).actionShort = 'tune c. params';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'e' };
    keys.Editor(end).action = 'automatically tune contour parameters (extensive search)';
    keys.Editor(end).actionShort = 'tune c. params slow';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'e' };
    keys.Editor(end).action = 'stars contour: reset parameters to default';
    keys.Editor(end).actionShort = 'default c. params';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'g' };
    keys.Editor(end).action = 'automatically tune ranking parameters (quick search)';
    keys.Editor(end).actionShort = 'tune r. params fast';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'g' };
    keys.Editor(end).action = 'automatically tune ranking parameters (standard search)';
    keys.Editor(end).actionShort = 'tune r. params';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'g' };
    keys.Editor(end).action = 'automatically tune ranking parameters (extensive search)';
    keys.Editor(end).actionShort = 'tune r. params slow';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'g' };
    keys.Editor(end).action = 'stars ranking: reset parameters to default';
    keys.Editor(end).actionShort = 'default r. params';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };
    
    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'm' };
    keys.Editor(end).action = 'stars ranking: change maximum allowed rank';
    keys.Editor(end).actionShort = 'max rank';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { '6' };
    keys.Editor(end).action = 'stars: change maximum allowed area';
    keys.Editor(end).actionShort = 'max area';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { '6' };
    keys.Editor(end).action = 'stars: change minimum allowed area';
    keys.Editor(end).actionShort = 'min area';
    keys.Editor(end).subMenu = { 'Change segmentation+tracking parameters' };
    
    
    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { '7' };
    keys.Editor(end).action = 'show-hide all seeds placed automatically';
    keys.Editor(end).actionShort = 'toggle all seeds';
    keys.Editor(end).subMenu = { 'Toggle channel-info' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 's' };
    keys.Editor(end).action = '(re)do segmentation for current frame';
    keys.Editor(end).actionShort = 'segment frame';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 's' };
    keys.Editor(end).action = 'select frames for which to (re)do segmentation';
    keys.Editor(end).actionShort = 'select frames to segment';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 's' };
    keys.Editor(end).action = '(re)do segmentation for all frames';
    keys.Editor(end).actionShort = 'segment all';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 't' };
    keys.Editor(end).action = '(re)do tracking for current frame';
    keys.Editor(end).actionShort = 'track frame';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 't' };
    keys.Editor(end).action = 'select frames for which to (re)do tracking';
    keys.Editor(end).actionShort = 'select frames to track';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 't' };
    keys.Editor(end).action = '(re)do tracking for all frames';
    keys.Editor(end).actionShort = 'track all';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'z' };
    keys.Editor(end).action = '(re)do segmentation and tracking for current frame';
    keys.Editor(end).actionShort = 'seg+track frame';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'z' };
    keys.Editor(end).action = 'select frames for which to (re)do segmentation and tracking';
    keys.Editor(end).actionShort = 'select frames to seg+track';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'z' };
    keys.Editor(end).action = '(re)do segmentation and tracking for all frames';
    keys.Editor(end).actionShort = 'seg+track all';
    keys.Editor(end).subMenu = { '(re)Do segmentation-tracking' };

    keys.Editor(end + 1).modifiers = { 'alt' 'shift' };
    keys.Editor(end).key = { 'p' };
    keys.Editor(end).action = 'recompute image preprocessing';
    keys.Editor(end).actionShort = 'redo preprocessing';
    keys.Editor(end).subMenu = { 'Preprocessing' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { 'w' };
    keys.Editor(end).action = 'change cell content threshold';
    keys.Editor(end).actionShort = 'set content thr.';
    keys.Editor(end).subMenu = { 'Preprocessing' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'w' };
    keys.Editor(end).action = 'change foreground threshold';
    keys.Editor(end).actionShort = 'set foreground thr.';
    keys.Editor(end).subMenu = { 'Preprocessing' };

    keys.Editor(end + 1).modifiers = {};
    keys.Editor(end).key = { ',' 'comma' };
    keys.Editor(end).action = 'list unresolved tracking problems';
    keys.Editor(end).actionShort = 'list problems';
    keys.Editor(end).subMenu = { 'Detected problems' };

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { ',' 'comma' };
    keys.Editor(end).action = 'list all tracking problems';
    keys.Editor(end).actionShort = 'list all problems';
    keys.Editor(end).subMenu = { 'Detected problems' };

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { ',' 'comma' };
    keys.Editor(end).action = 'jump to next unresolved problem';
    keys.Editor(end).actionShort = 'go to problem';
    keys.Editor(end).subMenu = { 'Detected problems' };
    
%%%%%%%%%% Lineage
%    Ground truth:
%    - mark mother of selected segment (or orphan)
%    - delete lineage ground truth
%    - show-hide lineage ground truth
%    Automatic detection:
%    - do automatic detection of lineage
%    - show-hide automatic lineage
%    - show statistics with ground truth
%    - automatically optimize lineage parameters?

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'b' };
    keys.Editor(end).action = 'apply changes and go to background editor';
    keys.Editor(end).actionShort = 'bg editor';
    keys.Editor(end).subMenu = {};

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { 'x' };
    keys.Editor(end).action = 'apply changes and return to main menu';
    keys.Editor(end).actionShort = 'main menu';
    keys.Editor(end).subMenu = {};

    keys.Editor(end + 1).modifiers = { 'shift' };
    keys.Editor(end).key = { ' ', 'spacebar' };
    keys.Editor(end).action = 'reset user interface';
    keys.Editor(end).actionShort = 'reset interface';
    keys.Editor(end).subMenu = {};

    keys.Editor(end + 1).modifiers = { 'alt' };
    keys.Editor(end).key = { 'q' };
    keys.Editor(end).action = 'apply changes and quit';
    keys.Editor(end).actionShort = 'apply and quit';
    keys.Editor(end).subMenu = {};

    
end
