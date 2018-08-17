%     Copyright 2012, 2013, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function ImageShow(im, msg, debugLevel, parameterDebugLevel, interfaceMode)
  %Shows an image depending on the current interfaceMode.
  if ((debugLevel <= parameterDebugLevel) && (strcmp(interfaceMode, 'interactive') || strcmp(interfaceMode, 'confirm')))
    PrintMsg(parameterDebugLevel, debugLevel, msg);
    myImShow(double(im));
  end
  if (strcmp(interfaceMode, 'confirm'))
    input('Press enter to continue...', 's');
  end
end

function myImShow(im)
    if isempty(im)
        return;
    end

    if (min(im(:)) < 0) || (max(im(:)) > 1)
        im = ImageNormalize(im);
    end

    newImage = false;
    
    f = findobj('tag', 'CellStar User Interface');
    if isempty(f)
       f = figure('tag', 'CellStar User Interface', 'WindowStyle', 'docked', 'NumberTitle', 'off');
    else
       figure(f);
    end

    imHandle = findobj('tag', 'CellStar User Interface cdata');
    if (isempty(imHandle) || ~ishandle(imHandle))
        newImage = true;
    else
        displayedSize = size(get(imHandle, 'cdata'));
        imSize = size(im);
        if length(displayedSize) ~= imSize
            if length(displayedSize) == 3 && length(imSize) == 1
                im = cat(3, im, im, im); % faster this way...
            else
                newImage = true;
            end
        else
            if sum(displayedSize == imSize) < length(imSize)
                newImage = true;
            end
        end
    end

    if newImage
        imHandle = imshow(im, 'border', 'tight');
        set(imHandle, 'tag', 'CellStar User Interface cdata');
    else
        set(imHandle, 'cdata', im);
    end
    drawnow;    
end
