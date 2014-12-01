function auc = computeAUC()
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


% Perform a Wilcoxon sign rank test
% Use the training and validation data to choose the best value of lambda
% 

% wilcoxon.mat saves the auc table for each run of OneExperiment
% do not forget to initialize an empty matrix for the first run!!


% Deleting existing results!!
splits = []; selected_k = []; selected_lambdas = []; auc = [];
save auc.mat auc; save splits.mat splits;
save selected_k.mat selected_k; save selected_lambdas.mat selected_lambdas;
%

%load('wilcoxon.mat')
load('auc.mat')
n = 50;
aucCurrent = zeros(3,n);

for k=1:n
    display(['Experiment number' num2str(k)])
    aucCurrent(:,k) = OneExperiment();
end
    auc = cat(2,auc,aucCurrent);

save auc.mat auc;
end
