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


function saved = UISaveImageToDisk(imChannel, varargin)
   % varargin{1} = frame
   % varargin{2} = 'SkipIfFileExists'
   if (length(varargin) >= 2)
       skipIfExists = strcmpi(varargin{2}, 'skipiffileexists');
   else
       skipIfExists = false;
   end
   global csui;
   outFile = [];
   saved = false;
   switch imChannel
       case 'background'
           outFile = csui.session.parameters.files.background.imageFile;
       otherwise
           if strcmp(imChannel, 'segmentsColorMasked')
               imChannel = 'segmentsColor';
           end
           if strcmp(imChannel, 'trackingMasked')
               imChannel = 'tracking';
           end
           if ~isempty(varargin)
               frame = varargin{1};
               files = OutputFileNames(frame, csui.session.parameters);
               if isfield(files.images, imChannel)
                   outFile = files.images.(imChannel);
               end
           end
   end
   if ~isempty(outFile)
       if ~(skipIfExists && exist(outFile, 'file'))
           im = ImageFromBuffer(imChannel, varargin{:});
           if ~isempty(im)
               ImageSave(im, ...
                         outFile, ...
                         csui.session.parameters.segmentation.transform, ...
                         csui.session.parameters.debugLevel);
               saved = true;
           end
    %    else
    %         disp(['Cannot save channel ' imChannel ' to disk.']);
       end
   end
end
