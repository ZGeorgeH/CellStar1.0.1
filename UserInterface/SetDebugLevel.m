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


function SetDebugLevel()
    global csui;
    debugList = cellfun(@num2str, num2cell(0:5), 'UniformOutput', false);
    debugJava = listdlg('PromptString', 'Select debug level:', 'ListString', debugList, 'SelectionMode', 'Single', 'InitialValue', csui.session.parameters.debugLevel + 1);
    if ~isempty(debugJava)
      debugLevel = debugJava(1) - 1;
      disp([ 'Setting debug level to ' num2str(debugLevel) '.' ]);
      csui.session.parameters.debugLevel = debugLevel;
      UILogAction(['% csui.session.parameters.debugLevel = ' num2str(csui.session.parameters.debugLevel) ';']);
    else
      disp('Canceling...');
    end
end