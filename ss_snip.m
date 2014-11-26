function ssd = ss_snip(ssd, nsigma)
%

% Cut continuous voltage traces into spike snips.
%
% PREV: ss_loadexper
% NEXT: ss_cluster
%
% 9/10/14 amarino
% -adding ginput for thresholding
% -instead of doing circshift (which actually disrupts time continuity in
% the snip), recutting snip from ssd.y
% -saving snip times in ms for later ISI calucation

opts = ss_options;
npre = round((opts.PRE/1000) * ssd.fs);
npost = round((opts.POST/1000) * ssd.fs);
sniptimes = [];

if isempty(ssd.y)
  error('ssd has no data');
end


if ~exist('nsigma', 'var')
    plot(ssd.y(1:min(length(ssd.y),50000))); axis tight;
    [~,thr] = ginput(1);
    ssd.thresh = abs(thr);
    ssd.nsigma = ssd.thresh/nanstd(ssd.y);
else
    ssd.nsigma = abs(nsigma);
    ssd.thresh = ssd.nsigma * nanstd(ssd.y);
end
ix = find([0; diff((ssd.y > ssd.thresh) | (ssd.y < -ssd.thresh))]>0);

% take snips in random sequence.. in case we exceed opts.MAXSNIPS
ix = ix(randperm(length(ix)));
ssd.snips = zeros(npre+npost+1, min(length(ix),opts.MAXSNIPS));
nsnips = 0;
for n = 1:length(ix)
  a = ix(n) - npre;
  b = ix(n) + npost;

  snip = ssd.y(a:b);

  if opts.PEAKALIGN
    % align snip peak to center of window by shifting
    % then we tweak the timestamp, so the s_ts vector indicates
    % the peak time, not the thresh-crossing time..
    p = round(mean(find(abs(snip) == max(abs(snip)))));
    peakix = ix(n) + (p-npre-1);
    a = peakix - npre;
    b = peakix + npost;
    if a < 1 || b > length(ssd.y) || any(isnan(ssd.y(a:b)))
        continue;
    end
      nsnips = nsnips + 1;
    ssd.snips(:,nsnips) = ssd.y(a:b);
    sniptimes = [sniptimes; peakix];
  else
      if a < 1 || b > length(ssd.y) || any(isnan(ssd.y(a:b)))
          continue;
      end
      nsnips = nsnips + 1;
      ssd.snips(:,nsnips) = snip;
      sniptimes = [sniptimes; ix];
  end
  
  if n >= opts.MAXSNIPS
    fprintf('warning: only taking %d/%d (random) snips\n', ...
            opts.MAXSNIPS, length(ix));
    break
  end
end
ssd.snips = ssd.snips(:, 1:nsnips);
ssd.sniptimes = (sniptimes/ssd.fs)*1000;

ssd.t = 1000 * linspace(-npre, npost, size(ssd.snips,1)) / ssd.fs;
ssd.peakalign = opts.PEAKALIGN;
ssd.pre = opts.PRE;
ssd.post = opts.POST;
ssd.npre = npre;
ssd.npost = npost;
