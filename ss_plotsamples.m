function ss_plotsamples(ssd)

cid = ssd.clustern;
%cid = ss_dosort(ssd, ssd.snips);

yr = 1e6 * [min(ssd.snips(:)) max(ssd.snips(:))];

pn = 1;
for n = 1:size(ssd.templates,2)
  subplot(size(ssd.templates,2),4+1,pn); pn = pn + 1;
  plot(1e6.*ssd.templates(:,n));
  yrange(yr(1), yr(2));
  ylabel(sprintf('cluster %d (uv)', n));
  for draw = 1:4
    subplot(size(ssd.templates,2),4+1,pn); pn = pn + 1;
    cla
    plot(1e6.*ssd.snips(:,(rand(size(cid))>0.90).*cid==n), 'k-')
    yrange(yr(1), yr(2));
    grid on;
  end
end
return
