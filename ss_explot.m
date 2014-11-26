function ss_explot(ssd)
% brushing plot

COLORSEQ = 'rgbmycrgbmycrgbmyc';

clf;

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
    axis square;
    set(gca, 'YTickLabel', {}, 'XTickLabel', {});
    xlabel(ssd.pclabels{pc1});
    ylabel(ssd.pclabels{pc2});
  end
end
