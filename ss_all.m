function ssds = ss_all(exper, chan_no)


if ischar(exper)
  % first try loading a .ss save file
  ssds = ss_loadss(exper);
  if isempty(ssds)
    % must be an 'exper' or exper-like pattern
    ssds = ss_loadexper(exper);
  end
else
  % it's an already loaded ssds struct array
  ssds = exper;
end

nchan = sum(cellfun(@(x) ~isempty(x.y), ssds));
if nchan == 0
  error('no spike data in exper!');
end

if ~exist('chan_no', 'var')
  % first channel with data
  chan_no = find(cellfun(@(x) ~isempty(x.y), ssds));
  chan_no = chan_no(1);
else
  if isempty(ssds{chan_no}.y)
    error('channel %d has no spike data', chan_no);
  end
end

h = [];
arg = '';
argn = 0;
re_nsigma = 0;
re_nclust = 0;
re_plot = 1;

[plotwin, ~, histwin] = showmsg('-init');

while 1
  if ~isfield(ssds{chan_no}, 'nsigma')
    ssds{chan_no}.nsigma = 4;
    re_nsigma = 1;
  end
  if ~isfield(ssds{chan_no}, 'nclust')
    ssds{chan_no}.nclust = 2;
    re_nclust = 1;
  end
  if ~isfield(ssds{chan_no}, 'stype')
    ssds{chan_no}.stype = 'kmeans';
    re_nclust = 1;
  end
  
  if re_nsigma
    showmsg('busy');

    ssds{chan_no} = ss_snip(ssds{chan_no}, ssds{chan_no}.nsigma);
    re_nsigma = 0;
    re_nclust = 1;
    re_plot = 1;
  end
  if re_nclust
    showmsg('busy');
    
    ssds{chan_no} = ss_cluster(ssds{chan_no}, ...
                               ssds{chan_no}.nclust, ssds{chan_no}.stype);
    re_nclust = 0;
    re_plot = 1;
  end
  
  if re_plot
    figure(histwin);
    ss_plothist(ssds{chan_no});
    figure(plotwin);
    ss_plot(ssds{chan_no});
    re_plot = 0;
  end
  
  if nchan > 1
    ckey = '(n)';
  else
    ckey = '   ';
  end
  
  msg = [ sprintf(' %s\n\n', ssds{chan_no}.exper) ...
          sprintf(' %s  chan no = %d/%d\n', ckey, chan_no, nchan) ...
          sprintf(' (s)  nsigma  = %.1f\n', ssds{chan_no}.nsigma) ...
          sprintf(' (c)  unit    = %d\n', ssds{chan_no}.nclust) ...
          sprintf(' (kg) stype   = %s\n', ssds{chan_no}.stype) ...
          sprintf('\n arg: [%s]\n\n', arg) ...
          sprintf(' w: write .ss file\n') ...
          sprintf(' q: write and quit\n') ...
          sprintf(' x: exit w/o save\n') ...
          ];
  showmsg(msg);
  
  while waitforbuttonpress() == 0
    % nop..
  end
  key = get(gcf, 'CurrentCharacter');

  if any(key == '0123456789.')
    arg = [arg char(key)];
    argn = str2num(arg);
    if isempty(argn)
      argn = 0;
    end
  else
    switch key
      case 8                            % backspace..
        arg = arg(1:end-1);
      case 'n'
        if nchan > 1
          n = chan_no;
          while 1
            n = n + 1;
            if n > length(ssds), n = 1; end
            if ~isempty(ssds{n}.y)
              chan_no = n;
              break
            end
          end
          re_nsigma = 1;
          re_cluster = 1;
        end
        arg = '';
      case 'c'
        if argn > 0
          ssds{chan_no}.nclust = argn;
          re_nclust = 1;
          arg = '';
        end
      case 's'
        if argn > 0
          ssds{chan_no}.nsigma = argn;
          re_nsigma = 1;
          arg = '';
        end
      case 'k'
        ssds{chan_no}.stype = 'kmeans';
        re_nclust = 1;
      case 'g'
        ssds{chan_no}.stype = 'gmm';
        re_nclust = 1;
      case 'w'
        ss_savess(ssds);
      case 'q'
        ss_savess(ssds);
        showmsg('-close');
        break;
      case 'x'
        showmsg('-close');
        break;
    end
  end
end
  

function [plotwin, uifig, histwin] = showmsg(msg)

persistent textbox xplotwin xuifig xhistwin

if strcmp(msg, '-init')
  m = get(0, 'screensize');
  h = 200; w = 300;
  mar = 20;
  try
    xplotwin = figure(90);    
    plotwin = xplotwin;
    set(plotwin, 'name', 'ss:plot', 'numbertitle', 'off', ...
                 'menubar', 'none', ...
                 'position', [w+mar 0 800 m(4)])
    xhistwin = figure(92);
    histwin = xhistwin;
    set(histwin, 'name', 'ss:hists', 'numbertitle', 'off', ...
                 'menubar', 'none', ...
                 'position', [0 0 w m(4)-h-100]);
    xuifig = figure(91);
    uifig = xuifig;
    set(uifig, 'name', 'ss:gui', 'numbertitle', 'off', ...
               'menubar', 'none', ...
               'position', [0 m(4)-h w h]);
    textbox = uicontrol('Style', 'text', ...
                        'Position', [5 5 w-10 h-10],...
                        'FontName', 'Courier',...
                        'HorizontalAlignment', 'left');
    figure(plotwin);
  catch E
    figure(plotwin);
    rethrow(E);
  end
elseif strcmp(msg, '-close')
  set(xhistwin, 'menubar', 'figure', 'numbertitle', 'on');
  set(xplotwin, 'menubar', 'figure', 'numbertitle', 'on');
  close(xuifig);
else
  set(textbox, 'String', msg);
  drawnow;
end
