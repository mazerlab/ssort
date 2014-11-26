function sortcodes = ss_dosort(ssd, snips)

% 'project' all snips onto all templates and pick best match to
% assign final sort code
%
% note: this really doesn't do projection, but rather takes the
% template with minimal LSE. This seems to work better.

ntemplates = size(ssd.templates,2);

if 1
  % minimal LSE
  scores = zeros([size(snips,2) ntemplates]);
  for nt = 1:ntemplates
    for ns = 1:size(snips, 2)
      scores(ns, nt) = -sum((ssd.templates(:,nt) - snips(:,ns)).^2);
    end
  end
  best = (scores == repmat(max(scores, [], 2), 1, ntemplates));
else
  % maximal projection
  scores = snips' * ssd.templates;
end

id = repmat(1:size(ssd.templates,2), [size(scores,1) 1]);
sortcodes = sum(best.*id, 2);
