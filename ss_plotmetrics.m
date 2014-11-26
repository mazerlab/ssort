function ss_plotmetrics(ssd)
%plots ISI, spike rate
COLORSEQ = 'rgbmycrgbmycrgbmyc';
legtext = {};
nspikes = size(ssd.snips, 2);


nspikes = size(ssd.snips, 2);

for c = 1:ssd.nclust
    subplot(5,ssd.nclust,c)
    st = ssd.sniptimes(ssd.clustern==c);
    sTimes = sort(ssd.sniptimes);
    latestTime = sTimes(end);
    st = diff(sort(st));
    hist(st(st<200),600);
    title(sprintf('cluster %d ISI',c))
    set(gca,'YTickLabel',{}) ; box off; 
    
    subplot(5,ssd.nclust,[ssd.nclust+1 2*ssd.nclust])
    ts = sort(round(ssd.sniptimes(ssd.clustern==c)));
    rates = hist(ts,floor(latestTime/5000));
    plot(rates,[COLORSEQ(c)]); hold on;
    legtext = cat(1,legtext,sprintf('%d',c));
     set(gca,'XTickLabel',{})   
end

ylabel('rate (arbitrary units)')
legend(legtext);



for c = 1:ssd.nclust
    csnips = ssd.snips(:,ssd.clustern==c);
    
    %plot peak-threshold
    subplot(5,ssd.nclust,3*ssd.nclust+c)
    hist(max(abs(csnips))-ssd.thresh,50);
    xlabel('peak - threshold')
    if c==1
        ylabel('# spikes')
    end
    set(gca,'XTickLabel',{},'YTickLabel',{}); 
    
    %plot histogram of residuals    
    subplot(5,ssd.nclust,4*ssd.nclust+c)
    ix = find(ssd.clustern == c);
    t = repmat(ssd.t, [length(ix) 1])'; t = t(:);
    v = 1e6 * (ssd.snips(:,ix)-repmat(ssd.templates(:,c),1,length(ix))); v = v(:);
    [den, c1] = hist3([t v], [size(ssd.snips,1) 20]);
    den = 100 * den ./ nspikes;
    imagesc(c1{1}, c1{2}, den');
    set(gca, 'ydir', 'normal','Ylim',[-75 75]); axis off;
    
    subplot(5,ssd.nclust,[2*ssd.nclust+1 3*ssd.nclust])
    peaks = max(abs(csnips));
    amplitudes = max(csnips) - min(csnips);
    
    plot(ssd.sniptimes(ssd.clustern==c),amplitudes,['.',COLORSEQ(c)],'MarkerSize',5); hold on;
    
end
axis tight; ylabel('amplitude')
xlabel('time')
set(gca,'XTickLabel',{},'YTickLabel',{});


