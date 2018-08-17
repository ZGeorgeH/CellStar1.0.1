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


function im = GetImBuf(imChannel, varargin)
    global csui;
    
    if ~isempty(varargin)
        frame = varargin{1};
    else
        frame = [];
    end
    if length(varargin) > 1
        additionalChannel = varargin{2};
    else
        additionalChannel = [];
    end
    
    
    if ImageIsLoaded(imChannel, frame, additionalChannel)
        switch imChannel
        case {'background', 'backgroundMask'}
                im = csui.imBuf.(imChannel);
                compressed = csui.imBuf.compression.(imChannel);
            case 'additional'
                im = csui.imBuf.(imChannel){additionalChannel, frame};
                compressed = csui.imBuf.compression.(imChannel){additionalChannel, frame};
            otherwise
                im = csui.imBuf.(imChannel){frame};
                compressed = csui.imBuf.compression.(imChannel){frame};
        end
        if any(strcmp(imChannel, {'foregroundMask', 'backgroundMask', 'cellContentMask'})) && ...
                ~islogical(im)
            im = logical(im);
        end
        if compressed
            imClass = class(im);
            im = double(im) / double(intmax(imClass));
        end
    else
        im = [];
    end
    
    if ~isempty(im)
         CheckBufferLimit(imChannel, frame, additionalChannel);
    end

end


