function ss_plot(ssd, raw)

if ~exist('raw', 'var'), raw=0; end

COLORSEQ = 'rgbmycrgbmycrgbmyc';

clf;
subplot = @(m,n,p) subtightplot (m, n, p, [0.03 0.03], [0.03 0.03], [0.03 0.03]);
labels = {};
for n = 1:ssd.npc
  b = linspace(mean(ssd.scores(:,n))-2*std(ssd.scores(:,n)), ...
               max(ssd.scores(:,n))-2*std(ssd.scores(:,n)), 50);
  subplot(2.5*ssd.npc,5,3+(n-1)*5);
  hist(ssd.scores(:, n), 100);
  axis off; axis tight;
  ax = axis;
  set(text(ax(2),0,ssd.pclabels{n}), 'VerticalAlignment', 'bottom');
end

pn = 0;
for pc1 = 1:ssd.npc
  for pc2 = 1:ssd.npc
    pn = pn + 1;
    if pc1 <= pc2, continue; end
    subplot(1+ssd.npc,ssd.npc,pn);
    for cn = 1:ssd.nclust
      ix = find(ssd.clustern==cn);
      set(plot(ssd.scores(ix, pc1), ssd.scores(ix, pc2), ...
               ['.' COLORSEQ(cn)]), 'MarkerSize', 1);
      hold on;
    end
    hold off;
    axis tight; axis square;
    set(gca, 'YTickLabel', {}, 'XTickLabel', {});
    xlabel(ssd.pclabels{pc1});
    ylabel(ssd.pclabels{pc2});
  end
end

% plot results of the initial clustering (PCA-based)
subplot(1+ssd.npc,ssd.npc,1);
hist(ssd.clustern, 1:ssd.nclust);
ylabel('count');
title('train: spikes/cluster');

% plot results from template matching based of cluster time-domain means
subplot(1+ssd.npc,ssd.npc,2);
sortcodes = ss_dosort(ssd, ssd.snips);
hist(sortcodes, 1:max(sortcodes));
title('sort: spikes/cluster');

subplot(6,3,3);
for n = 1:ssd.nclust
  if raw
    plot(ssd.t, 1e6 * ssd.snips(:, ssd.clustern==n), ...
         ['-' COLORSEQ(n)]);
    hold on;
  else
    m = 1e6 * mean(ssd.snips(:, ssd.clustern==n), 2);
    sd = 1e6 * std(ssd.snips(:, ssd.clustern==n), [], 2);
    set(eshade(ssd.t, m', sd', COLORSEQ(n)), ...
        'facealpha', 0.10);
    hold on;
    plot(ssd.t, m, [COLORSEQ(n) '.-']);
  end
end
hold off; axis tight;
ylabel('uv');
title(sprintf('%s: nclust=%d %s', ...
              ssd.exper, ssd.nclust, ssd.stype));
vline(0, 'linestyle', '-');
hline(0, 'linestyle', '-');
hline(1e6*ssd.thresh);
hline(-1e6*ssd.thresh);

subplot(6,3,6);
for n = 1:ssd.nclust
  plot(ssd.t, ssd.templates(:,n), ['.-' COLORSEQ(n)]);
  hold on;
end
hold off;
ylabel('uv');
vline(0, 'linestyle', '-');
hline(0, 'linestyle', '-');
axis tight;

if raw
  subplot(6,3,9);
  for n = 1:ssd.nclust
    m = mean(ssd.snips(:, ssd.clustern==n), 2);
    sd = std(ssd.snips(:, ssd.clustern==n), [], 2);
    sd = (sd - max(m)) ./ (max(m)-min(m));
    m = (m - max(m)) ./ (max(m)-min(m));
    
    set(eshade(ssd.t, m', sd', COLORSEQ(n)), 'facealpha', 0.10);
    hold on;
    plot(ssd.t, m, [COLORSEQ(n) '.-']);
  end
  hold off;
  ylabel('norm V');
  vline(0, 'linestyle', '-');
  hline(0, 'linestyle', '-');
  axis tight;
end

if 1
  subplot(7,1,7);
  t = (1:length(ssd.y)) ./ ssd.fs;
  plot(t, 1e6*ssd.y, 'k-');
  axis tight;
  hline(0, 'linestyle', '-', 'color', 'b');
  hline(1e6*ssd.thresh, 'linestyle', '-', 'color', 'r');
  hline(-1e6*ssd.thresh, 'linestyle', '-', 'color', 'r');
  ylabel('uv');
  ylabel('time (s)');
end
