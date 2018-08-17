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


function SetImBuf(im, imChannel, varargin)
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
    
    if ~isempty(im)
         CheckBufferLimit(imChannel, frame, additionalChannel);
    end
    
    if any(strcmp(imChannel, {'background', 'original', 'additional'}))
        % Only the first image channel is kept
        im = im(:, :, 1);
    end
    
    if any(strcmp(imChannel, {'foregroundMask', 'backgroundMask', 'cellContentMask'}))
        im = uint8(im);
    end
    
    if strcmp(imChannel, 'segments')
        im = uint16(im); % never more than 65535 segments...
    end
    
    if ~isempty(im) && (max(im(:)) <= 1) && (min(im(:)) >= 0) && isfloat(im)
        compressed = true;
        if any(strcmp(imChannel, {'segmentsColor', 'tracking', 'segmentsColorMasked', 'trackingMasked'}))
            im = uint8(im * double(intmax('uint8')));
        else
            im = uint16(im * double(intmax('uint16')));
        end
    else
        compressed = false;
    end
    
    switch imChannel
        case {'background', 'backgroundMask'}
            csui.imBuf.(imChannel) = im;
            csui.imBuf.compression.(imChannel) = compressed;
        case 'additional'
            csui.imBuf.(imChannel){additionalChannel, frame} = im;
            csui.imBuf.compression.(imChannel){additionalChannel, frame} = compressed;
        otherwise
            csui.imBuf.(imChannel){frame} = im;
            csui.imBuf.compression.(imChannel){frame} = compressed;
    end
end
