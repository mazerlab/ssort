function ssd = ss_cluster(ssd, nclust, stype)
%
% use PCA + (kmeans|gmm) to cluster spikes and generate time-domain
% templates
%
% PREV: ss_snip
% NEXT: ss_plot
%


opts = ss_options;

if ~exist('stype', 'var')
  stype = opts.STYPE;
end

% compute PCs and projects of each snip on PCs ('scores')
[pcs, scores, latent] = pca(ssd.snips');

% use some hacks + scores for first NPC PCsto cluster and plot
% templates -- hacks are max (ie, sign of spike) and max-min (spike
% height)
%
% Probably more correct to call 'scores', 'features' at this point
% to be more consistent with the spike sorting literature.

if opts.USE_HEURISTICS
  % calculate time between peak and trough
  w = zeros([1 size(ssd.snips,2)]);
  for n = 1:size(ssd.snips,2)
    snip = ssd.snips(:,n);
    w(n) = mean(find(snip==max(snip)))-mean(find(snip==min(snip)));
  end
  X = [max(ssd.snips)' w' (max(ssd.snips)-min(ssd.snips))' ...
       scores(:,1:(opts.NPC-2))];
  npc = opts.NPC;
  labels = {'ht', 'wd', 'mod'};
else
  X = scores(:,1:opts.NPC);
  npc = opts.NPC;
  labels = {};
end

x = {};
for n = 1:npc
  if isempty(labels)
    x{n} = sprintf('PC%d', n);
  else
    try
      x{n} = labels{n};
    catch
      x{n} = sprintf('PC%d', n-length(labels));
    end
  end
end
labels = x;

if strcmp(stype, 'kmeans')
  clustern = kmeans(X, nclust, 'replicates', 10);
elseif strcmp(stype, 'gmm')
  obj = gmdistribution.fit(X, nclust, 'Replicates', 5);
  clustern = cluster(obj,X);
else
  error('unrecognized sort type: %s', stype);
end
  

% sort clusters from largest amp to smallest for consistency
p = [];
for n = 1:nclust
  x = mean(ssd.snips(:, clustern==n), 2);
  p(n) = abs(max(x)-min(x));
end
[~, p] = sort(-p);
c = zeros(size(clustern));
for n = 1:nclust
  c(clustern == p(n)) = n;
end
clustern = c;

ssd.stype = stype;
ssd.nclust = nclust;
ssd.clustern = clustern;
ssd.scores = X;
ssd.npc = npc;
ssd.pclabels = labels;

% Compute time-domain templates by taking MEAN waveform of each
% k-means defined cluster. Also store STD for each waveform so
% bounds can be used later to identify 'unclustered' or 'unclassified'
% events.

ssd.templates = [];
ssd.templates_std = [];
for n = 1:ssd.nclust
  ssd.templates(:,n) = mean(ssd.snips(:, ssd.clustern==n), 2);
  ssd.templates_std(:,n) = std(ssd.snips(:, ssd.clustern==n), [], 2);
end
