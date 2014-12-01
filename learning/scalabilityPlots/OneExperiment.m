function aucTab = OneExperiment()
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


% splits saves the random splits used to perform the wilcoxon test
% for a range of lambdas between -6 and +6

% selected_lambdas saves the optimal lambda chosen for that splits

% selected_k saves the optimal lambda chosen for that splits


% do not forget to initialize empty matrices for the first run!!
load('splits.mat')
load('selected_lambdas')
load('selected_k')

splits = []
selected_k = []


blaschkoDisp('nesarc');
[X Y r] = genData('processedData.csv');
r = r';
r = r(1:2000,:);
splits = cat(2,splits,r);

display('2000 samples')
Xtrain = X(1:500,:);
Ytrain = Y(1:500,:);
Xval = X(501:1000,:);
Yval = Y(501:1000,:);
Xtest = X(1001:2000,:);
Ytest = Y(1001:2000,:);

%display('200 samples')
%Xtrain = X(1:50,:);
%Ytrain = Y(1:50,:);
%Xval = X(51:100,:);
%Yval = Y(51:100,:);
%Xtest = X(101:200,:);
%Ytest = Y(101:200,:);

d = size(Xtest,2);

% set of k values to select from for k-support norm
ks = [30, 60, 90, 120, 150, 180, 210, 240, 270, 300]
%ks = [30, 60]
%ks= 3;
% must update ks

%numKsteps = 3;
%ks = [1:max(1,round(d/numKsteps)):d];
% set of regularization parameters to select from

%lambdas = 10.^[-6:6];
lambdas = 10.^-6;

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
    [acc_k,auc_k,mse_k,betak,s_k,s_lambdk] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks);
    blaschkoDisp('l1 regularization');
    [acc_1,auc_1,mse_1,beta1,s_1,s_lambd1] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,1);
    blaschkoDisp('l2 regularization');
    [acc_2,auc_2,mse_2,beta2,s_2,s_lambd2] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,d);
    accTab(:,i) = [acc_k; acc_1; acc_2];
    mseTab(:,i) = [mse_k; mse_1; mse_2];
    aucTab(:,i) = [auc_k; auc_1; auc_2];
end
    s_lambd = s_lambdk + s_lambd1 + s_lambd2;
    selected_lambdas = cat(2,selected_lambdas,s_lambd);
    selected_k = cat(2,selected_k,s_k);
    
    save splits.mat splits;
    save selected_lambdas.mat selected_lambdas;
    save selected_k.mat selected_k;
end

function blaschkoDisp(message)
disp([message ' ' datestr(now)]);
end

function [acc,auc,mse,beta,s_k,s_lambd] = evalMethod(func,Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks)

[beta,s_k,s_lambd] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks);

e = ones(size(Xtest,1),1);
pred = [e Xtest]*beta;
[score,predind] = max(pred,[],2);
[score,Ytestind] = max(Ytest,[],2);
acc = length(find(predind==Ytestind))/length(Ytestind);
[a,b,c,auc]=perfcurve(Ytestind,pred(:,1)-pred(:,2),1);
mse = norm(Ytest-pred).^2;
end

function [beta,s_k,s_lambd] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks)

s_lambd =  zeros(3,1);
s_k = 0;

dd = size(Xtrain,2);
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
                % save the best k
                s_k = ks(j);
                % save the lambdas
                if (ks(j) == 1)
                    s_lambd(2,1) = lambdas(i);    
                elseif(ks(j) == dd)
                    s_lambd(3,1) = lambdas(i);
                else
                    s_lambd(1,1) = lambdas(i);
                end
            end
        end
    end
end

function [X Y r] = genData(filename)

%Try to predict 'YES' or 'NO'
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
Z = Z(r,:);
end
