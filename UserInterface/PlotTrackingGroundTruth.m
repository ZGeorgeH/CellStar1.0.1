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


function PlotTrackingGroundTruth()
   global csui;
   currFrame = csui.session.states.Editor.currentFrame;
   
   HideTrackingGroundTruth();
   UILoadTrackingIfNeeded();
   
   hold on;
   for i = 1:size(csui.trackingBuf.groundTruth, 1)
       if (csui.trackingBuf.groundTruth(i, 1) == currFrame) || (csui.trackingBuf.groundTruth(i, 4) == currFrame)
           if csui.trackingBuf.groundTruth(i, 4) == 0
               csui.handles.currentFrame.trackingGroundTruth{i} = ...
                   rectangle('Position', [(csui.trackingBuf.groundTruth(i, 2:3) - [0 5]) [2 10]], 'EdgeColor', 'w', 'FaceColor','g');
           end
           if csui.trackingBuf.groundTruth(i, 1) == 0
               csui.handles.currentFrame.trackingGroundTruth{i} = ...
                   rectangle('Position', [(csui.trackingBuf.groundTruth(i, 5:6) - [2 5]) [2 10]],  'EdgeColor', 'w', 'FaceColor','r');
           end
           if (csui.trackingBuf.groundTruth(i, 1) ~= 0) && (csui.trackingBuf.groundTruth(i, 4) ~= 0)
               if (csui.trackingBuf.groundTruth(i, 1) == currFrame) 
                   theOtherFrame = csui.trackingBuf.groundTruth(i, 4);
               else
                   theOtherFrame = csui.trackingBuf.groundTruth(i, 1);
               end
               if theOtherFrame > currFrame
                   pColor = 'g';
               else
                   pColor = 'r';
               end
               csui.handles.currentFrame.trackingGroundTruth{i} = ...
                   plot(...
                           [csui.trackingBuf.groundTruth(i, 2) csui.trackingBuf.groundTruth(i, 5)],  ...
                           [csui.trackingBuf.groundTruth(i, 3) csui.trackingBuf.groundTruth(i, 6)], ...
                           pColor, 'LineWidth', 2);
           end
           if (csui.trackingBuf.groundTruth(i, 1) == currFrame)
               nhpos = 1;
           else
               nhpos = 4;
           end
           newHandles = plot(csui.trackingBuf.groundTruth(i, nhpos + 1), csui.trackingBuf.groundTruth(i, nhpos + 2), 's', 'MarkerEdgeColor','b','MarkerFaceColor','b','MarkerSize', 4);
           csui.handles.currentFrame.trackingGroundTruth{i} = [ csui.handles.currentFrame.trackingGroundTruth{i} newHandles ];
       end
   end
   hold off;
end
