% copyright 2012 Andreas Argyriou
% GPL License http://www.gnu.org/copyleft/gpl.html

function [x, itNum, epsEnd, costs] = overlap_nest(computeP, f, gradf, gamma, L, x0, k, iters_acc, eps_acc,verbosity)

% Minimizes regularization functional 
% f(w) + gamma/2 ||w||^2
% where ||.|| is the k overlap norm
% uses Nesterov's accelerated method 
% L                : Lipschitz constant for gradf
% x0               : initial value
% iters_acc     : maximum #iterations
% eps_acc	   : tolerance used as termination criterion  

if(~exist('verbosity','var'))
    %verbosity = Inf;
    verbosity = 10;
end

t = 1;
alpha = x0;
x = x0;
P = feval(computeP,x0);
d = length(x);
prev_cost = inf;
curr_cost = feval(f,P) + gamma/2 * ( norm_overlap(x0,k) )^2;
theta = 1;


% modification
gradalpha = feval(gradf,P);
costs = zeros(1,iters_acc-1);
%end modification



while (t < iters_acc && abs(prev_cost - curr_cost) > eps_acc)
    %if(mod(t,verbosity)==0)
    if(t == iters_acc)
        disp(sprintf(['overlap_nest - iteration number %d ' datestr(now)],t));
    end
 
  prevx = x;
  x = prox_overlap( -1/L* gradalpha + alpha, k, L/gamma);
  theta = (theta/2)*(sqrt(theta^2+4)-theta);
  rho = 1-theta+sqrt(1-theta);
  alpha = rho*x - (rho-1)*prevx;
  P = computeP(alpha);
  t = t+1;
  prev_cost = curr_cost;
  curr_cost = feval(f,P) + gamma/2 * ( norm_overlap(alpha,k) )^2;
  costs(t-1) = curr_cost;
  gradalpha = feval(gradf,P);
    
  
end
  itNum = t;
  epsEnd = abs(prev_cost - curr_cost);
  
end

