function ss_plothist(ssd)

cid = ssd.clustern;

pn = 1;
nspikes = size(ssd.snips, 2);

for n = 0:size(ssd.templates,2)
  subplot(1+size(ssd.templates,2), 1, pn); pn = pn + 1;
  if n > 0
    ix = find(cid == n);
  else
    ix = find(~isnan(cid));
  end

  t = repmat(ssd.t, [length(ix) 1])'; t = t(:);
  v = 1e6 * ssd.snips(:,ix); v = v(:);
  [den, c] = hist3([t v], [size(ssd.snips,1) 50]);
  den = 100 * den ./ nspikes;
  imagesc(c{1}, c{2}, den');
  set(gca, 'ydir', 'normal');
  colorbar;
  xlabel('time (s)');
  ylabel('uv');
  if n == 0
    title('all spikes');
  else
    title(sprintf('cluster %d', n));
  end
  yrange(-75, 75);
end



