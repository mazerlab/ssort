function ssds = ss_savess(ssds, filename)
%function ssds = ss_savess(ssds, filename)
%
% save ss file -- use filename if specified, otherwise figure it
% out from the ssds struct info
%

if ~exist('filename', 'var')
  for n = 1:length(ssds)
    ssd = ssds{n};
    if isfield(ssd, 'experdir'), break; end
  end
  filename = [ssd.experdir '/' ssd.exper '.ss'];
end

save(filename, 'ssds');
fprintf('saved: %s\n', filename);
