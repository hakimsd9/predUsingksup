function [variablesTab_k,variablesTab_1,variablesTab_2,bestk] = getMainVar()
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


% Retrieve the column numbers of the variables having the biggest weight
% beta
% To do so:
% 1- run experiments to determine the couple (lambda, k) giving the best
% auc with k-sup
% 2- retrieve the coefficients beta for this value of lambda for k-sup,
% l1 and l2
% 3- get the 50 variables for which the l1 norm is the most important in
% each case

num = 50;
variablesTab_k = zeros(1, num);
variablesTab_1 = zeros(1, num);
variablesTab_2 = zeros(1, num);
bestk = 0;

blaschkoDisp('nesarc');
[X Y] = genData('processedData.csv');

Xtrain = X(1:500,:);
Ytrain = Y(1:500,:);
Xval = X(501:1000,:);
Yval = Y(501:1000,:);
Xtest = X(1001:2000,:);
Ytest = Y(1001:2000,:);

%global d
d = size(Xtest,2);
% set of k values to select from for k-support norm
ks = [2, 4, 8, 16, 32, 64, 128, 256]; 
%ks= [2, 8];
% must update ks

% numKsteps = 3;
% ks = [1:max(1,round(d/numKsteps)):d];
% set of regularization parameters to select from

lambdas = 10.^[-6:6];
%lambdas = 10.^1;

alg = cell(0);
algName = cell(0);
% alg{end+1} = @matlabLogistic; % just to debug and compare to a known
%                              % correct implementation of Logistic regression
% algName{end+1} = 'logistic loss matlab';
alg{end+1} = @ksupMulticlassLogistic; 
algName{end+1} = 'logistic loss';

accTab = zeros(3,length(alg));
mseTab = zeros(3,length(alg));
aucTab = zeros(3,length(alg));
 
% squared loss
for i=1:length(algName)

 %   % global beta_k beta_1 beta_2
  %  [beta_k, beta_1, beta_2] = getBeta(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,aucTab,ks,d);

    blaschkoDisp(['evaluating ' algName{i}])
    blaschkoDisp('k-support validation');
    [acc_k,auc_k,mse_k,beta_k,bestk] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks);
    blaschkoDisp('l1 regularization');
    [acc_1,auc_1,mse_1,beta_1] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,1);
    blaschkoDisp('l2 regularization');
    [acc_2,auc_2,mse_2,beta_2] = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,d);
    accTab(:,i) = [acc_k; acc_1; acc_2];
    mseTab(:,i) = [mse_k; mse_1; mse_2];
    aucTab(:,i) = [auc_k; auc_1; auc_2];
    
    aucTab;    
   % [beta_k, beta_1, beta_2, bestk] = getBeta(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,aucTab,ks,d);
   % [beta_k, bestk] = modelSelection(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,ks);
    %beta_1 = modelSelection(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,1);
    %beta_2 = modelSelection(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,d); 

    display([' ||beta_k - beta_1|| ' num2str(norm(beta_k-beta_1,1))])
    display([' ||beta_k - beta_2|| ' num2str(norm(beta_k-beta_2,1))])
    display([' ||beta_1 - beta_2|| ' num2str(norm(beta_1-beta_2,1))])
    
end

variablesTab_k = indexesColMax(beta_k,num);
variablesTab_1 = indexesColMax(beta_1,num);
variablesTab_2 = indexesColMax(beta_2,num);


ck = size(beta_k,1);
c1 = size(beta_1,1);
c2 = size(beta_2,1);

absbeta_k = zeros(1,ck);
absbeta_1 = zeros(1,c1);
absbeta_2 = zeros(1,c2);

for k=1:ck
    absbeta_k(k,:) = norm(beta_k(k,:),1);
end

for k=1:c1
    absbeta_1(k,:) = norm(beta_1(k,:),1);
end

for k=1:c2
    absbeta_2(k,:) = norm(beta_2(k,:),1);
end
save result.mat variablesTab_k variablesTab_1 variablesTab_2 absbeta_k absbeta_1 absbeta_2

end

function blaschkoDisp(message)
disp([message ' ' datestr(now)]);
end

function [acc,auc,mse,beta,bestk] = evalMethod(func,Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks)

[beta, bestk] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks);

e = ones(size(Xtest,1),1);
pred = [e Xtest]*beta;
[score,predind] = max(pred,[],2);
[score,Ytestind] = max(Ytest,[],2);
acc = length(find(predind==Ytestind))/length(Ytestind);
[a,b,c,auc]=perfcurve(Ytestind,pred(:,1)-pred(:,2),1);
mse = norm(Ytest-pred).^2;
end

function [beta, bestk] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks)

bestk = 0;
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
                bestk = ks(j);
                display(['k ' num2str(ks(j)) ' lambda ' num2str(lambdas(i)) ' aucVal ' num2str(auc)])
            end
        end
    end
end

function [X Y] = genData(filename)

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

end

function indexes = indexesColMax(beta, num)
% beta: The matrix we look for the num largest columns in terms of l1
% num: Number of highest columns in l1 norm we want to keep

% indexes: list of the indexes of the num columns of beta with the 
% highest l1 norm

c = size(beta,1);
l1Val = zeros(1,c);

for k=1:c
    l1Val(1,k) = norm(beta(k,:),1);
end


[l1Val, l1Ind] = sort(l1Val,'descend');
indexes = l1Ind(1,1:num);

end

%function best_k = getBestk(aucTab,ks)
%
%% get the k that gives the best auc
%auc_ksup = aucTab(1,:);
%a = size(auc_ksup,2)
%best_auc = -Inf;
%for g=1:a
%    display(['auc ' num2str(auc_ksup(g))])
%    if auc_ksup(g) > best_auc
%        best_auc = auc_ksup(g);
%        best_k = ks(g);
%    end
%end
%end


%function [beta_k, beta_1, beta_2, bestk] = getBeta(func,Xtrain,Ytrain,Xval,Yval,lambdas,aucTab,ks,d)
%%global beta_k beta_1 beta_2 
%bestk = getBestk(aucTab,ks);
%%bestk = getBestk(auc,ks);
%
%beta_k = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,bestk);
%beta_1 = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,1);
%beta_2 = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,d);
%
%display([' ||beta_k - beta_1|| ' num2str(norm(beta_k-beta_1,1))])
%display([' ||beta_k - beta_2|| ' num2str(norm(beta_k-beta_2,1))])
%display([' ||beta_1 - beta_2|| ' num2str(norm(beta_1-beta_2,1))])
%end

