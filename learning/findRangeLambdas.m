function aucTab = findRangeLambdas();
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


blaschkoDisp('nesarc');
[X Y] = genData('processedData.csv');
% use the new csv file with respondents who answered 3 or 3 and encoding
Xtrain = X(1:2000,:);
Ytrain = Y(1:2000,:);
Xval = X(2001:3000,:);
Yval = Y(2001:3000,:);
Xtest = X(3001:end,:);
Ytest = Y(3001:end,:);


%Xtrain = X(1:500,:);
%Ytrain = Y(1:500,:);
%Xval = X(501:1000,:);
%Yval = Y(501:1000,:);
%Xtest = X(1001:2000,:);
%Ytest = Y(1001:2000,:);



d = size(Xtest,2);
% set of k values to select from for k-support norm
%ks = 22; 
ks = [2, 4, 8, 16, 32, 64, 128, 256];

% numKsteps = 10;
% ks = [1:max(1,round(d/numKsteps)):d];
% set of regularization parameters to select from

lambdas = 10.^[-15:12];
%lambdas = 10.^[-15];

alg = cell(0);
algName = cell(0);
%alg{end+1} = @matlabLogistic; % just to debug and compare to a known
%                              % correct implementation of Logistic regression
%algName{end+1} = 'logistic loss matlab';
alg{end+1} = @ksupMulticlassLogistic; 
algName{end+1} = 'logistic loss';




% squared loss
for i=1:length(algName)
    blaschkoDisp(['evaluating ' algName{i}])
    blaschkoDisp('k-support validation');
   % beta = evalMethod(alg{i},Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks);
    [aucTab, beta] = modelSelection(alg{i},Xtrain,Ytrain,Xval,Yval,lambdas,ks)
    semilogx(aucTab(:,1),aucTab(:,2), '*')
end

end

function blaschkoDisp(message)
disp([message ' ' datestr(now)]);
end

function beta = evalMethod(func,Xtrain,Ytrain,Xval,Yval,Xtest,Ytest,lambdas,ks)

[aucTab, beta] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks);

e = ones(size(Xtest,1),1);
pred = [e Xtest]*beta;

[score,predind] = max(pred,[],2);
[score,Ytestind] = max(Ytest,[],2);
%acc = length(find(predind==Ytestind))/length(Ytestind);

[a,b,c,auc]=perfcurve(Ytestind,pred(:,1)-pred(:,2),1);

end

function [aucTab, beta] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks)

aucTab = zeros(length(lambdas),2);
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
            % For two classes
            [a,b,c,auc]=perfcurve(Yvalind,pred(:,1)-pred(:,2),1);
            
            %acc = length(find(predind==Yvalind))/length(Yvalind);
            aucTab(i,:) = [lambdas(i), auc];
%             disp('lambda')
%             disp(lambdas(i))
%             
%             disp('k')
%             disp(ks(j))
%             
%             %disp('w')
%             %disp(w(1:5))
%             
%             disp('acc')
%             disp(acc)
%             
%             disp('auc')
%             disp(auc)
            
            %disp('pred')
            %disp(pred(1:5))

            
            if (auc>aucval)
                aucval = auc;
                beta = w;
            end
%             acc=auc;
%             if(acc>accval)
%                 accval = acc;
%                 beta = w;
%             end
        end
    end
end

function [X Y] = genData(filename)

% Try to predict 'YES' or 'NO'
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


for k = 1:size(X,1)
     if  Z(k,1) == 1
         Y(k,:) = [1 0];
         
     elseif Z(k,1) == -1 
          Y(k,:) = [0 1]; 
    
     end
end

% If try to learn the unknown (auc to modify then)
% for k = 1:size(X,1)
%      if  Z(k,1) == 1
%          Y(k,:) = [1 0 0];
%          
%          
%      elseif Z(k,1) == -1 
%           Y(k,:) = [0 1 0]; 
%      
%      elseif Z(k,2) == 1
%          Y(k,:) = [0 0 1];
%      
%      end
%end


% % Shuffle the data
 r = randperm(size(Y,1));
 X = X(r,:);
 Y = Y(r,:);

end


