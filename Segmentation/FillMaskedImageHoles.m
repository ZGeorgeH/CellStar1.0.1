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


function im = FillMaskedImageHoles(origImage, origMask, radius, steps, debugLevel)
  if min(size(origImage) == 0)
      im = origImage;
  else
      padsize = size(origImage);
      avg = mean(origImage(:));
      image = padarray(origImage, padsize, 'symmetric');
      currIm = image;
      mask = padarray(origMask, padsize, 'symmetric');
      currIm(~mask) = avg;
      %convMask = double([1 2 1; 2 4 2; 1 2 1]) / double(16);
      PrintMsg(debugLevel, 1, [ 'Filling holes: ' num2str(steps) ' steps' ]);
      for i = 1:steps
          if debugLevel >= 1
              fprintf('.');
          end
          %currIm = conv2(double(currIm), convMask, 'same');
          currIm = ImageSmooth(currIm, 1 + round(radius * ((steps - i + 1) / steps)^2));
          currIm(mask) = image(mask);
      end
      if debugLevel >= 1
            fprintf('\n');
      end
      im = currIm(padsize(1) + 1:end - padsize(1), padsize(2) + 1:end - padsize(2));
  end  
end