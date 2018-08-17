%     Copyright 2013, 2015 Cristian Versari
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

function imDigits = PlotDigitsOnImage(im, height, csDigits, x, y)
  % Plot numbers (with font height "height") on image im, given cell 
  % array of strings "csDigits", and x y are arrays of coordinates 
  % of same length as csDigits
  
  bwDigits = LoadDigits(height);
  
  imDigits = zeros([size(im, 1), size(im, 2)]);
  for i = 1:length(csDigits)
      imDigits = PlotDigitsOnImage1(imDigits, csDigits{i}, x(i), y(i), bwDigits);
  end
  mask = imDigits;
  for i = 2:size(im, 3)
      mask = cat(3, mask, imDigits);
  end
  im(mask > 0) = mask(mask > 0);
  
  imDigits = im;
end

function imDigits = PlotDigitsOnImage1(im, digitString, x, y, bwDigits)
  % digitString = string with numbers to plot
  % x y = real numbers, coordinates of text center
  
  if isempty(im)
      imDigits = [];
      return
  end
  
  mask = DigitMask(digitString, bwDigits);
  
  height = size(mask, 1);
  width = size(mask, 2);

  x = round(x);
  y = round(y);
  
  xstart = x - ceil(width / 2) + 1;
  ystart = y - ceil(height / 2) + 1;
  if (xstart < 1)
      x1 = 2 - xstart;
      xstart = 1;
  else
      x1 = 1;
  end
  if (ystart < 1)
      y1 = 2 - ystart;
      ystart = 1;
  else
      y1 = 1;
  end

  xend = x + floor(width / 2);
  yend = y + floor(height / 2);
  if (xend > size(im, 2))
      x2 = width + size(im, 2) - xend;
      xend = size(im, 2);
  else
      x2 = width;
  end
  if (yend > size(im, 1))
      y2 = height + size(im, 1) - yend;
      yend = size(im, 1);
  else
      y2 = height;
  end
  
  bigMask = zeros(size(im));
  bigMask(ystart:yend, xstart:xend) = mask(y1:y2, x1:x2);
  
  contour = logical(ImageDilate(bigMask > 0.2, 1, 'square'));
  
  imDigits = im;
  imDigits(contour) = 0.0001;
  imDigits(bigMask > 0) = bigMask(bigMask > 0);
%   imshow(imDigits);
%   drawnow
end