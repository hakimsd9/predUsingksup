function [aucTab,accTab,mseTab,algName] = experiments();
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



% NOTA: NEED TO OUTPUT BETA

blaschkoDisp('nesarc');
[X Y] = genData('processedData.csv');

Xtrain = X(1:500,:);
Ytrain = Y(1:500,:);
Xval = X(501:1000,:);
Yval = Y(501:1000,:);
Xtest = X(1001:2000,:);
Ytest = Y(1001:2000,:);


d = size(Xtest,2);
% set of k values to select from for k-support norm
ks = [2, 4, 8, 16, 32, 64, 128, 256]; 
%ks= 3;
% must update ks

%numKsteps = 3;
%ks = [1:max(1,round(d/numKsteps)):d];
% set of regularization parameters to select from

lambdas = 10.^[-6:6];
%lambdas = 10.^[2];

alg = cell(0);
algName = cell(0);
%alg{end+1} = @matlabLogistic; % just to debug and compare to a known
%                              % correct implementation of Logistic regression
%algName{end+1} = 'logistic loss matlab';
alg{end+1} = @ksupMulticlassLogistic; 
algName{end+1} = 'logistic loss';

accTab = zeros(3,length(alg));
mseTab = zeros(3,length(alg));
aucTab = zeros(3,length(alg));
 

% squared loss
for i=1:length(algName)
    blaschkoDisp(['evaluating ' algName{i}])
    blaschkoDisp('k-support validation');
    [acc_k,auc_k,mse_k] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks);
    blaschkoDisp('l1 regularization');
    [acc_1,auc_1,mse_1] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,1);
    blaschkoDisp('l2 regularization');
    [acc_2,auc_2,mse_2] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,d);
    accTab(:,i) = [acc_k; acc_1; acc_2];
    mseTab(:,i) = [mse_k; mse_1; mse_2];
    aucTab(:,i) = [auc_k; auc_1; auc_2];
end
end

function blaschkoDisp(message)
disp([message ' ' datestr(now)]);
end

function [acc,auc,mse,beta] = evalMethod(func,Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks)

beta = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks);

e = ones(size(Xtest,1),1);
pred = [e Xtest]*beta;
[score,predind] = max(pred,[],2);
[score,Ytestind] = max(Ytest,[],2);
acc = length(find(predind==Ytestind))/length(Ytestind);
[a,b,c,auc]=perfcurve(Ytestind,pred(:,1)-pred(:,2),1);
mse = norm(Ytest-pred).^2;
end

function beta = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks)

e = ones(size(Xval,1),1);
aucval = -Inf;
    beta = zeros(size(Xval,2)*size(Yval,2),1); 
    for i=1:length(lambdas)
        for j = 1:length(ks)
            w = func(Xtrain,Ytrain,lambdas(i),ks(j));
            w = reshape(w,[size(Xtrain,2)+1 size(Ytrain,2)]);
            
            pred = [e Xval]*w;

            [score,predind] = max(pred,[],2);
            [score,Yvalind] = max(Yval,[],2);
            [a,b,c,auc]=perfcurve(Yvalind,pred(:,1)-pred(:,2),1);
            acc = length(find(predind==Yvalind))/length(Yvalind);

            if(auc>aucval)
                aucval = auc;
                beta = w;
            end

        end
    end
end

function [X Y] = genData(filename)

%Try to predict 'YES' or 'No'
numberClasses = 2;
% The columns corresponding to 'S2CQ4A' are columns 60 and 61

formatSpec1 = [repmat('%f',1,59),repmat('%*f',1,2), repmat('%f',1,254)];
formatSpec2 = [repmat('%*f',1,59),repmat('%f',1,2), repmat('%*f',1,254)];

fid = fopen(filename);
X = textscan(fid, formatSpec1, 'Delimiter', ',', 'CollectOutput', 1);
fclose(fid);
fid = fopen(filename);
Z = textscan(fid, formatSpec2, 'Delimiter', ',', 'CollectOutput', 1);
fclose(fid);
X = X{1};
Z = Z{1};

Y = zeros(size(X,1), numberClasses);

% find the indices for which Z(k,1) ~= 0
Z1 = Z(:,1);
ind_nonZ = find(Z1);

% only keep the samples for which this is true
Y = Y(ind_nonZ,:);
X = X(ind_nonZ,:);
Z = Z(ind_nonZ,:);

for k = 1:size(X,1)
     if  Z(k,1) == 1
         Y(k,:) = [1 0];
         
         
     elseif Z(k,1) == -1 
          Y(k,:) = [0 1]; 
     end
 end


% Shuffle the data
r = randperm(size(Y,1));
X = X(r,:);
Y = Y(r,:);

end
