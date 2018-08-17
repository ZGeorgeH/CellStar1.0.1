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


function ShowEditor()
    global csui;
    
    ses = csui.session.states.Editor;
    nFrames = length(csui.session.parameters.files.imagesFiles);
    
    if (ses.currentFrame < 1)
        csui.session.states.Editor.currentFrame = 1;
    end
    if (ses.currentFrame > nFrames)
        csui.session.states.Editor.currentFrame = nFrames;
    end
    
    if strcmp(ses.channel, 'additional')
        additional = [ ' ' num2str(ses.currentAdditionalChannel) ];
    else
        additional = '';
    end
    
    im = ImageFromBuffer(ses.channel, ses.currentFrame);

    if ~isempty(im)
       UIShowImage(im, 'drawLater');
       emptyS = '';
    else
       disp('Warning: picture is empty...');
       emptyS = ' (empty)';
    end
    
    name = ['CellStar - Integrated editor - frame ' num2str(ses.currentFrame) '/' num2str(nFrames) ' - channel: ' ses.channel additional emptyS ];
    SetFigureName(name);
    
    drawnow;
end
