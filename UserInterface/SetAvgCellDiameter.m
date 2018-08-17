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


function ok = SetAvgCellDiameter()
  global csui;
  ok = false;
  msg = 'Set the average cell diameter (in pixel units). Beware: autodetection will take some time.';
  answ = questdlg(msg, 'Set average cell diameter', 'Set manually', 'Try autodetection', 'Set manually');
  if isempty(answ) || isnumeric(answ)
      disp('Canceling...');
  elseif strcmp(answ, 'Set manually')
      cellDiam = inputdlg({'Enter average cell diameter in pixel units:'}, 'Average cell diameter', 1, { num2str(csui.session.parameters.segmentation.avgCellDiameter)});
      cellDiam = str2double(cellDiam);
      if isempty(cellDiam)
          disp('Canceling...');
      else
          if (cellDiam <= 0)
              msg = 'Invalid value...';
              disp(msg); errordlg(msg);
          else
              UILogAction('% Average cell diameter has been manually set.');
          end
      end
  else
      cellDiam = DetectAvgCellSize(csui.session.parameters);
      if (cellDiam <= 0)
          msg = 'Autodetection failed.';
          disp(msg); errordlg(msg);
      else
          UILogAction('% Average cell diameter has been automatically set.');
      end
  end
  if exist('cellDiam', 'var') && ~isempty(cellDiam) && isnumeric(cellDiam) && (cellDiam > 0)
      csui.session.parameters.segmentation.avgCellDiameter = cellDiam;
      disp([ 'Setting avg cell diameter to ' num2str(cellDiam) '.']);
      UILogAction([ '% csui.session.parameters.segmentation.avgCellDiameter = ' num2str(csui.session.parameters.segmentation.avgCellDiameter) ';']);
      csui.sessionNeedsSaving = true;
      ok = true;
  end
end