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


function CheckBufferLimit(imChannel, frame, additionalChannel)
    % Checks the memory buffer limit, and removes images if the memory
    % limit is reached. 
    %
    % In order to decide which image(s) has to be removed from the buffer,
    % an access list is stored, which represents a history of the last time
    % each image in the buffer was read (or written). Currently, the
    % "oldest" accessed image(s) is removed from the buffer when the memory 
    % limit is reached.
    %
    % The only exception to the buffer management is the "segments" channel,
    % which is _never_ removed from memory nor taken into account in the memory
    % limit calculation.
    
    global csui;
    AddEntryToBufferLog (imChannel, frame, additionalChannel);
    while true
        imBuf = csui.imBuf;
        s = whos('imBuf');

        if isfield(csui.imBuf, 'segments')
            % Since "segments" images are _never_ removed from the buffer, 
            % the buffer memory limit must not take those images into account.
            segs = csui.imBuf.segments;
            ss = whos('segs');
        else
            ss.bytes = 0;
        end
        if ((s.bytes - ss.bytes) > csui.session.maxImBufSize * 1024 * 1024)
            removed = RemoveFirstAccess ();
            if (~removed)
                break
            end
        else
            break
        end
            
    end
end


function AddEntryToBufferLog(imChannel, frame, additionalChannel)
    global csui;

    if strcmp(imChannel, 'segments')
        % Images in segments channel are never deleted from buffer, because
        % they are part of the segmentation data which is essential.
        % Since they are not added to the accesses list, they
        % are simply not removed by the RemoveFirstAccess() function.
        PrintMsg(csui.session.parameters.debugLevel, 4, 'AddEntryToBufferLog: skipping "segments" channel');
        return
    end
    
    if ~IsSubField(csui, {'imBuf', 'bufferLimit', 'lastAccess'})
       parameters = csui.session.parameters;
       nFrames = length (parameters.files.imagesFiles);
       nAdditionalChannels = length (parameters.files.additionalChannels);

       % 20 is a good approximate upper bound for the max number of
       % channels, but no problem if it is not enough
       csui.imBuf.bufferLimit.lastAccess = uint32 (zeros (20, nFrames, max(nAdditionalChannels, 1)));
    end

    channelN = ChannelToInt (imChannel);
    if (isempty (frame) || (frame == 0))
       frame = 1;
    end
    if (isempty (additionalChannel) || (additionalChannel == 0))
       additionalChannel = 1;
    end
    mmax = max(csui.imBuf.bufferLimit.lastAccess(:));
    if isempty(mmax)
        mmax = 0;
    end
    if (size(csui.imBuf.bufferLimit.lastAccess, 1) < channelN) || ...
       (size(csui.imBuf.bufferLimit.lastAccess, 2) < frame) || ...
       (size(csui.imBuf.bufferLimit.lastAccess, 3) < additionalChannel) || ...
       (csui.imBuf.bufferLimit.lastAccess(channelN, frame, additionalChannel) == 0)
   
       if strcmp(csui.imBuf.bufferLimit.channelMap{channelN}, 'additional')
          addit = [ '    ' num2str(additionalChannel) ];
       else
          addit = '';
       end
       PrintMsg(csui.session.parameters.debugLevel, 4, [ 'AddEntryToBufferLog: setting image ' csui.imBuf.bufferLimit.channelMap{channelN} '  ' num2str(frame) addit ]);
    end
    csui.imBuf.bufferLimit.lastAccess(channelN, frame, additionalChannel) = mmax + 1;
end

function removed = RemoveFirstAccess ()
    global csui;
    removed = false;
    la = csui.imBuf.bufferLimit.lastAccess(:);
    mmin = min (la(la > 0));
    if (isempty (mmin))
        return
    end
    idx = find (csui.imBuf.bufferLimit.lastAccess == mmin, 1);
    if (~isempty (idx))
      [rmChannel, rmFrame, rmAdditional] = ind2sub (size (csui.imBuf.bufferLimit.lastAccess), idx);
      if strcmp(csui.imBuf.bufferLimit.channelMap{rmChannel}, 'additional')
          addit = [ '    ' num2str(rmAdditional) ];
      else
          addit = '';
      end
      PrintMsg(csui.session.parameters.debugLevel, 4, [ 'Unloading image: ' csui.imBuf.bufferLimit.channelMap{rmChannel} '  ' num2str(rmFrame) addit ]);
      csui.imBuf.bufferLimit.lastAccess(rmChannel, rmFrame, rmAdditional) = 0;
      ClearImageBuffer (csui.imBuf.bufferLimit.channelMap{rmChannel}, rmFrame, rmAdditional);
      removed = true;
    end
end

function n = ChannelToInt (channel)
    global csui;
    if ~IsSubField(csui, {'imBuf', 'bufferLimit', 'channelMap'})
         csui.imBuf.bufferLimit.channelMap = {};
    end
    idx = strcmp (channel, csui.imBuf.bufferLimit.channelMap);
    if (~any (idx))
       csui.imBuf.bufferLimit.channelMap{end + 1} = channel;
       n = length (csui.imBuf.bufferLimit.channelMap);
    else
       n = find (idx);
    end
end
