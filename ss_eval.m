function ss_eval(ssd, sthresh)

sortcodes = ss_dosort(ssd, ssd.snips);

res = zeros(size(sortcodes));
for n = 1:size(ssd.snips,2)
  re = sum((ssd.snips(:,n) - ssd.templates(:,sortcodes(n))).^2);
  res(n) = re;
end

for n = 1:ssd.nclust
  subplot(2, ssd.nclust, n)
  hist(res(sortcodes==n));
  keyboard
  vline(mean(res(sortcodes==n)));
  vline(mean(res(sortcodes==n))-2*std(res(sortcodes==n)));
  vline(mean(res(sortcodes==n))+2*std(res(sortcodes==n)));
  
  title(n);
  
  ix = 1:size(sortcodes,2);
  r = res(sortcodes==n);
  ix = ix(sortcodes==n);
  
  r = abs((r - mean(r)) ./ std(r));
  
  subplot(2, ssd.nclust, ssd.nclust+n)
  
  plot(ssd.t, ssd.templates(:,n), 'k-');
  if ~isempty(ix(r > sthresh))
    hold on;
    plot(ssd.t, 1e6*ssd.snips(:, ix(r > sthresh)), 'r-');
  end
  hold off;
  
  title(sprintf('%.1f%% excluded', 100 * sum(r>sthresh) ./ size(ix,2)));
end


