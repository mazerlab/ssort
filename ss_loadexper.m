function ssds = ss_loadexper(exper, select)

% Use elog to find files associated with this EXPER and load
% associated p2m files. Then use unispike tools to suck in the
% continues per-trial spike traces.
%
% This loads all channels..
%
% PREV: (none)
% NEXT: ss_snip

if ~exist('select', 'var'), select = 1; end

if isempty(exper)
  exper = getpref('ss', exper, '');
  if isempty(exper)
    error('must specify EXPER');
  end
end

% allow use to select a limited number of files for training/clustering
fnames = dbfind(exper, 'noload', 'all','list');
if select && length(fnames) > 1
  d = ss_dirname(fnames{1});
  x = uigetfile(sprintf('%s/%s.*.*.p2m', d, exper), 'MultiSelect', 'on');

  if length(x) > 1
    fnames = {};
    if ischar(x)
      fnames{1} = sprintf('%s/%s', d, x);
    else
      for n = 1:length(x)
        fnames{n} = sprintf('%s/%s', d, x{n});
      end
    end
  end
end
setpref('ss', 'exper', exper);

for chan_no = 1:16
  ssds{chan_no} = struct();
  ssds{chan_no}.fs = NaN;
  ssds{chan_no}.y = [];
end
for n = 1:length(fnames)
  us = uni();
  try
    uni(1);
    pf = p2mLoad2(fnames{n});
    uni(us);
  catch E
    uni(us);
    rethrow(E);
  end
  spikes = pf.spikes;
  for chan_no = 1:16
    if ~isempty(spikes{chan_no})
      for k = 1:length(spikes{chan_no}.spk)
        ssds{chan_no}.y = [ssds{chan_no}.y; NaN; spikes{chan_no}.spk{k}];
        if isnan(ssds{chan_no}.fs)
          ssds{chan_no}.fs = 1.0 / (spikes{chan_no}.ts{3}(3) - ...
                          spikes{chan_no}.ts{2}(2));
          ssds{chan_no}.experdir = dirname(pf.src);
          ssds{chan_no}.ssfile = [ssds{chan_no}.experdir '/' exper '.ss'];
          ssds{chan_no}.exper = exper;
          ssds{chan_no}.fnames = fnames;
        end
      end
    end
  end
end

