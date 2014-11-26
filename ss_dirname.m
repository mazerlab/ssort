function f = ss_dirname(f)
%function f = ss_dirname(f)
%
%  extract dirname from filename:
%   /a/b/c/file --> /a/b/c
%
% Wed Feb  7 12:09:18 2001 mazer 


ix = find(f == '/');
l = length(ix);

if l > 0
  f = f(1:(ix(l)-1));
end

