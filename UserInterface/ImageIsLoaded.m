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


function isLoaded = ImageIsLoaded(imChannel, frame, additionalChannel)
    global csui;
    switch imChannel
        case {'background', 'backgroundMask'}
            isNotLoaded = ~IsSubField(csui, {'imBuf', imChannel}) || ...
                    isempty(csui.imBuf.(imChannel));
        case 'additional'
            isNotLoaded = ~IsSubField(csui, {'imBuf', 'additional'}) || ...
                    isempty(csui.imBuf.additional) || ...
                    (length(csui.imBuf.additional(:, 1)) < additionalChannel) || ...
                    (length(csui.imBuf.additional(additionalChannel, :)) < frame) || ...
                    isempty(csui.imBuf.additional{additionalChannel, frame});
        otherwise
            isNotLoaded = ~IsSubField(csui, {'imBuf', imChannel}) || ...
                    (length(csui.imBuf.(imChannel)) < frame) || ...
                    isempty(csui.imBuf.(imChannel){frame});
    end
    isLoaded = ~isNotLoaded;
end
