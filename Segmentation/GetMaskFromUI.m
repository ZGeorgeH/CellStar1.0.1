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


function mask = GetMaskFromUI(image, keys, initialSize)
  % It is a very inefficient partial clone of Paint.
  % Returns a mask for the given image: the mask is
  % 1 where the pixels are not masked, and 0 where
  % the pixels are masked. The "keys" structure
  % stores the key codes for the user interface.
  

  disp('Press');
  disp([ '  ' keys.newPoint.name ' to add a new point' ]);
  disp([ '  ' keys.increaseSize.name ' to increase size of last point' ]);
  disp([ '  ' keys.decreaseSize.name ' to decrease size of last point' ]);
  disp([ '  ' keys.switchShape.name ' to change shape of the last point' ]);
  disp([ '  ' keys.delLastPoint.name ' to delete last point' ]);
  disp([ '  ' keys.undelLastPoint.name ' to undelete last deleted point (if not overwritten by a new point meanwhile)' ]);
  disp([ '  ' keys.toggleEqualization.name ' to toggle equalization of the image' ]);
  disp([ '  ' keys.invertMaskVisualization.name ' to invert mask visualization' ]);
  disp([ '  ' keys.restart.name ' to ignore current changes and restart' ]);
  
  disp(  '  enter to accept changes and continue');
  
  nshapes = 2;    % circle or square, currently
  
  X = [];
  Y = [];
  shape = [];
  sizes = [];
  npoints = 0;
  currShape = 1;
  currSize = initialSize;
  equalization = true;
  invertMaskVisualization = false;
  dispImage = histeq(ImageNormalize(image));
  while true
      mask = CalcMask(size(image), npoints, X, Y, shape, sizes);
      if invertMaskVisualization
        visumask = ~mask;
      else
        visumask = mask;
      end
      tmpImage = double(dispImage) .* double(visumask);
      ImageShow(tmpImage, '', 0, 4, 'interactive');
      [x, y, code] = ginput(1);
      if isempty(code)
          break
      else
        switch code
          case 13   % Octave behaves differently...
            break;
          case keys.newPoint.key
              npoints = npoints + 1;
              X(npoints) = x;
              Y(npoints) = y;
              shape(npoints) = currShape;
              sizes(npoints) = currSize;
          case keys.increaseSize.key
              currSize = currSize + 1;
              if npoints > 0
                  sizes(npoints) = currSize;
              end
          case keys.decreaseSize.key
              currSize = currSize - 1;
              if currSize < 0
                  currSize = 0;
              else
                  if npoints > 0
                      sizes(npoints) = currSize;
                  end
              end
              case keys.switchShape.key
              currShape = mod(currShape, nshapes) + 1;
              if npoints > 0
                  shape(npoints) = currShape;
              end
          case keys.delLastPoint.key
              npoints = max(npoints - 1, 0);
              if npoints > 0
                currSize = sizes(npoints);
              end
          case keys.undelLastPoint.key
              npoints = min(npoints + 1, size(X(:), 1));
              if npoints <= size(X(:), 1)
                currSize = sizes(npoints);
              end
          case keys.restart.key
              npoints = 0;
          case keys.invertMaskVisualization.key
              invertMaskVisualization = ~invertMaskVisualization;
          case keys.toggleEqualization.key
              equalization = ~equalization;
              if equalization
                dispImage = histeq(ImageNormalize(image));
              else
                dispImage = ImageNormalize(image);
              end
        end
      end
  end
end

function mask = CalcMask(imSize, npoints, X, Y, shape, sizes)
  if (max(size(sizes)) == 0)
      mask = zeros(imSize) + 1;
  else
      shift = max(sizes) + 1;
      mask = zeros(imSize + 2 * shift) + 1;
      for i = 1:npoints
          switch shape(i)
              case 1
                shapeName = 'circle';
              case 2
                shapeName = 'square';
          end
          shapeMatrix = BuildShape(sizes(i), shapeName);
          fromR = shift + round(Y(i)) - sizes(i);
          fromC = shift + round(X(i)) - sizes(i);
          idxR = fromR:(fromR + size(shapeMatrix, 1) - 1);
          idxC = fromC:(fromC + size(shapeMatrix, 2) - 1);
          mask(idxR, idxC) = mask(idxR, idxC) & ~shapeMatrix;
      end
      mask = mask((shift + 1):(shift + imSize(1)), ...
                  (shift + 1):(shift + imSize(2)));
  end
  mask = logical(mask);
end