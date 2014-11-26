function ssds = ss_loadss(exper)
%function ssds = ss_loadss(exper)
%
% load ss file -- saved ssds datastruct
%

fnames = dbfind(exper, 'noload', 'all');
if isempty(fnames)
  error('no exper: %s', exper);
end
fname = [ss_dirname(fnames{1}) '/' exper '.ss'];
if ~exist(fname, 'file')
  ssds = [];
else
  x = load('-mat', fname);
  ssds = x.ssds;
  fprintf('loaded: %s\n', fname);
end
