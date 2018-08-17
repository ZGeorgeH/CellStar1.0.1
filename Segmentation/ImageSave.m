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


function ImageSave(imo, fileName, transform, debugLevel)
  PrintMsg(debugLevel, 4, [ 'Saving "' fileName '" ... ' ]);
%    if max(im(:)) <= 1
%      PrintMsg(debugLevel, 4, [ 'Stretching image, which I guess was normalized... ' ]);
%      imn = uint16(min(round(im * 65536), 65535));
%    else
%      imn = uint16(im);
%    end

  %%%%%% TODO must be improved
  im = imo;
  if transform.invert
      if (max(imo(:)) > 1)
         PrintMsg(debugLevel, 0, 'Image values out of range, cannot invert...');
      else
         im = 1 - imo;
      end
  end
  %%%%%%

  if transform.scale ~= 1
      if transform.clip.apply
          newSize =  [transform.clip.Y2 - transform.clip.Y1 + 1, transform.clip.X2 - transform.clip.X1 + 1];
      else
          newSize = transform.originalImDim;
      end
      im = imresize(im, newSize);
  end

  if transform.clip.apply
    imb = zeros([transform.originalImDim size(im, 3)]);
    for i = 1:size(im, 3)
      imb(transform.clip.Y1:transform.clip.Y2,transform.clip.X1:transform.clip.X2,i) = im(:,:,i);
    end
  else
    imb = im;
  end
  if isfloat(imb) && (min(imb(:)) >= 0) && (max(imb(:)) <= 1)
      imb = uint16(imb * double(intmax('uint16')));
  end
  
  h = DetectHost ();
  if (islogical(imb) && strcmp (h, 'matlab'))
      % Matlab bug when saving logical images to 16bit?
      imb = double (imb);
  end

  colorLevels = length (unique (imb(:)));
  if ((colorLevels == 2) && (strcmp (h, 'octave')))
      % octave bug when saving logical images as double?
      imb = (imb ~= min (imb(:)));
  end
  
  try
      imwrite(imb, fileName, 'BitDepth', 16);
  catch
      imwrite(imb, fileName);
  end
end
