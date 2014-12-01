% copyright 2012 Andreas Argyriou
% GPL License http://www.gnu.org/copyleft/gpl.html

function [x, itNum, epsEnd, costs] = overlap_nest(computeP, f, gradf, gamma, L, x0, k, iters_acc, eps_acc,verbosity)

display(['calling overlap_nest for k = ' num2str(k)])
%load('delta_costs.mat')
display(['setting delta_costs to []'])
delta_costs = [];
delta_costs_x = [];

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

%global dk;
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


% Create the delta_cost_k vector
%dk = [];

tic
while (t < iters_acc && abs(prev_cost - curr_cost) > eps_acc)
    %if(mod(t,verbosity)==0)
%    dk = cat(1,dk,abs(prev_cost - curr_cost));
    a = toc;
    delta_costs_x = cat(1,delta_costs_x, a);
    delta_costs = cat(1,delta_costs,abs(prev_cost - curr_cost));
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
  
    % save the delta costs in delta_costs matrix
    % delta_costs:
    % for each value of k:
    % delta_cost_k = k delta1 ... delta_numiters
    
%   delta_costs = dk(2:end,:);

   %   delta_costs{k} = dk(2:end,:);
    %  eval(sprintf('delta_costs_%d = delta_costs{k}[2:end]', k))
    % save delta_cost_k vector in delta_costs.mat
   
    if k==1
        %l1
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 1'])
        save delta_costs1.mat delta_costs delta_costs_x;
    elseif k == 313
        % l2
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 313'])
        save delta_costs313.mat delta_costs delta_costs_x;
    elseif k == 30
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 30'])
        save delta_costs30.mat delta_costs delta_costs_x;
    elseif k == 60
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 60'])
        save delta_costs60.mat delta_costs delta_costs_x;
    elseif k == 90
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 90'])
        save delta_costs90.mat delta_costs delta_costs_x;
    elseif k == 120
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 120'])
        save delta_costs120.mat delta_costs delta_costs_x;
    elseif k == 150
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 150'])
        save delta_costs150.mat delta_costs delta_costs_x;
    elseif k == 180
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 180'])
        save delta_costs180.mat delta_costs delta_costs_x;
    elseif k == 210
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 210'])
        save delta_costs210.mat delta_costs delta_costs_x;
    elseif k == 240
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 240'])
        save delta_costs240.mat delta_costs delta_costs_x;
    elseif k == 270
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 270'])
        save delta_costs270.mat delta_costs delta_costs_x;
    elseif k == 300
        disp(['saving delta_costs of size ' num2str(size(delta_costs)) ' in 300'])
        save delta_costs300.mat delta_costs delta_costs_x;
    end
    
end

