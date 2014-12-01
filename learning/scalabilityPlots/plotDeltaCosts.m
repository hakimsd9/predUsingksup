function plt = plotDeltaCosts()
% Authors: Matthew Blaschko - matthew.blaschko@inria.fr
%          Hakim Sidahmed  - hakimsd@gmx.com
% Copyright (c) 2013
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
%
% If you use this software in your research, please cite:
%
% M. B. Blaschko, A Note on k-support Norm Regularized Risk Minimization.
% arXiv:1303.6390, 2013.
%
% Argyriou, A., Foygel, R., Srebro, N.: Sparse prediction with the k-support
% norm. NIPS. pp. 1466-1474 (2012)


ks = [1, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 313];

% delta_costs = [delta_costs1, delta_costs30,
%     delta_costs60,delta_costs90,delta_costs120,
%     delta_costs150,delta_costs180,delta_costs210,
%     delta_costs240,delta_costs270,
%     delta_costs300,delta_costs313];

delta_costs_mats = {'delta_costs1.mat', 'delta_costs30.mat',...
    'delta_costs60.mat','delta_costs90.mat','delta_costs120.mat',...
    'delta_costs150.mat','delta_costs180.mat','delta_costs210.mat',...
    'delta_costs240.mat','delta_costs270.mat',...
    'delta_costs300.mat','delta_costs313.mat'};


% compute the delta_costs over several iterations and average
OneExperiment();

% number of iterations

%X1 = 1:size(delta_costs{ks(1)},1);
%X2 = 1:size(delta_costs{ks(2)},1);

%plot(X1,delta_costs{ks(1)},'-ro',X2,delta_costs{ks(2)},'-.b');

% for i=1:size(ks,2)
%     load(delta_costs_mats{i})
%     ks(i)
%     X = delta_costs_x;
%     %X = 1:size(delta_costs,1);
%     h = plot(X,delta_costs);
%     legend(num2str(ks(i)))
%     saveas(h,num2str(ks(i)),'pdf')
%     clear delta_costs delta_costs_x
% end

load(delta_costs_mats{1})
x_1 = delta_costs_x;
y_1 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{2})
x_30 = delta_costs_x;
y_30 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{3})
x_60 = delta_costs_x;
y_60 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{4})
x_90 = delta_costs_x;
y_90 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{5})
x_120 = delta_costs_x;
y_120 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{6})
x_150 = delta_costs_x;
y_150 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{7})
x_180 = delta_costs_x;
y_180 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{8})
x_210 = delta_costs_x;
y_210 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{9})
x_240 = delta_costs_x;
y_240 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{10})
x_270= delta_costs_x;
y_270 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{11})
x_300 = delta_costs_x;
y_300 = delta_costs;
clear delta_costs_x delta_costs

load(delta_costs_mats{12})
x_313 = delta_costs_x;
y_313 = delta_costs;
clear delta_costs_x delta_costs

plot(x_1,y_1,x_30,y_30,x_60,y_60,x_90,y_90,x_120,y_120,...
    x_150,y_150,x_180,y_180,x_210,y_210,x_240,y_240,...
    x_270,y_270,x_300,y_300,x_313,y_313);

title('Variation in cost as a function of time for different values of k')
xlabel('time in seconds')
ylabel('variation in cost between two iterations')
legend('l1','k=30','k=60','k=90','k=120','k=150','k=180','k=210',...
    'k=240','k=270','k=300','l2')

end
