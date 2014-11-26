function pf = ss_apply(pf, ssds)
%function pf = ss_apply(pf, ssd)
%
% select spikes based on cluster number and inject back into
% pf.rec(N).spike_times for analysis..
%

if ~isfield(pf, 'spikes') || isempty(pf.spikes)
  error('need spike data from p2muni; try using p2mLoad2()');
end

nspikes = 0;
% trial time chan code
sorted = [];
for n = 1:length(pf.rec)
  for cno = 1:length(ssds)
    ssd = ssds{cno};
    if isnan(ssd.fs), continue; end
    
    t = pf.spikes{cno}.ts{n};           % time series
    y = pf.spikes{cno}.spk{n};          % voltage trace
    [snips, ts] = getsnips(ssd, t, y);    % thresholded snips
  
    ntemplates = size(ssd.templates,2);
    lse = zeros([size(snips,2) ntemplates]);
    for nt = 1:ntemplates
      for ns = 1:size(snips, 2)
        res = snips(:,ns) - ssd.templates(:,nt);
        if 0
            clf
            for ntemplot = 1:ntemplates
                if ntemplot==nt
                    subplot(2,ntemplates,ntemplot,'Color',[1 0.8 0.8]);
                else
                    subplot(2,ntemplates,ntemplot);
                end
                eshade(1:size(snips,1),ssd.templates(:,ntemplot)',ssd.templates_std(:,ntemplot)',[0.8 1 0.8]); hold on;
                plot(ssd.templates(:,ntemplot),'g');
                plot(snips(:,ns)); hold on;
                if ntemplot==nt
                    subplot(2,ntemplates,ntemplot + ntemplates,'Color',[1 0.8 0.8]); hold on; plot(snips(:,ns)-ssd.templates(:,ntemplot));
                else
                    subplot(2,ntemplates,ntemplot + ntemplates); plot(snips(:,ns)-ssd.templates(:,ntemplot));
                end
            end
        end
        
        if any(abs(res) > (3*ssd.templates_std(:,nt)))
          % if any residual value > 3*sigma, exclude from consideration
          lse(ns, nt) = -Inf;
        else
          lse(ns, nt) = -sum(res.^2);
        end
      end
    end  
    best = (lse == repmat(max(lse, [], 2), 1, ntemplates) & ~isinf(lse));
    id = repmat(1:size(ssd.templates,2), [size(lse,1) 1]);
    sortcodes = sum(best.*id, 2);
    for k = 1:length(sortcodes)
      sorted = [sorted; n 1000*ts(k) cno sortcodes(k)];
    end
  end
end

pf.ss.tno = sorted(:,1);
pf.ss.time = sorted(:,2);
pf.ss.cno = sorted(:,3);
pf.ss.scode = sorted(:,4);
pf.ss.sname = {};
for k = 1:length(pf.ss.tno)
  if pf.ss.scode(k)
    pf.ss.sname{k} = sprintf('ss%02d%s', pf.ss.cno(k), 'a'+pf.ss.scode(k)-1);
  else
    pf.ss.sname{k} = sprintf('ss%02d%s', pf.ss.cno(k), 'u');
  end
end

% if 0 %this doesn't work because the snips are in random order in ssds.snips
%   clist = unique(pf.ss.sname);
%   for n = 1:length(clist)
%     subplot(length(clist), 1, n);
%     m = strcmp(pf.ss.sname, clist{n});
%     fprintf('%d\t%s\n', sum(m), clist{n});
%     ix = find(m);
%     if ~isempty(ix)
%       %{
%       plot(1e6 * [mean(ssds{pf.ss.cno(ix(1))}.snips(:,ix),2) ...
%                   mean(ssds{pf.ss.cno(ix(1))}.snips(:,ix),2) - ...
%                   std(ssds{pf.ss.cno(ix(1))}.snips(:,ix),[],2) ...
%                   mean(ssds{pf.ss.cno(ix(1))}.snips(:,ix),2) + ...
%                   std(ssds{pf.ss.cno(ix(1))}.snips(:,ix),[],2)]);
%       %}
%       plot(1e6 * ssds{pf.ss.cno(ix(1))}.snips(:,ix), 'k-');
%       ylabel(clist{n});
%       yrange(-200,200);
%     end
%   end
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [snips, snipts] = getsnips(ssd, t, y)

npre = ssd.npre;
npost = ssd.npost;
ix = find([0; diff((y > ssd.thresh) | (y < -ssd.thresh))]>0);

nsnips = 0;
snips = zeros([npre+npost+1 length(ix)]);
snipts = zeros([1 length(ix)]);
for n = 1:length(ix)
  a = ix(n) - npre;
  b = ix(n) + npost;
  if a < 1 || b > length(y) || any(isnan(y(a:b)))
    continue;
  end
  snip = y(a:b);
  
  if ssd.peakalign
    p = round(mean(find(abs(snip) == max(abs(snip)))));
    peakix = ix(n) + (p-npre-1);
    a = peakix - npre;
    b = peakix + npost;
    nsnips = nsnips + 1;
    snips(:,nsnips) = y(a:b);
  else
      nsnips = nsnips + 1;
      snips(:,nsnips) = snip;
  end
  snipts(nsnips) = t(ix(n)-(npre-p+1)); %saves time of thresh cross, even if peak is aligned for snip
end
snips = snips(:, 1:nsnips);
snipts = snipts(1:nsnips);
