%     Copyright 2012, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function outfiles = FilesFromRegexps(regexps)
  % Compute list of files from regular expressions
  outfiles = {};
  for i = 1:size(regexps(:), 1)
    files = dir(cell2mat(regexps(i)));
    fdir = fileparts(cell2mat(regexps(i)));
    filenames = {files.name};
    from_ = size(outfiles(:), 1) + 1;
    to_ = from_ + size(filenames(:), 1) - 1;
    for j = from_:to_
      outfiles(j) = mat2cell(fullfile(fdir, cell2mat(filenames(j - from_ + 1))), 1);
    end
  end
end
