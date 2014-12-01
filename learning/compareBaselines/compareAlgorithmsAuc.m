function [au] = compareAlgorithmsAuc(N)
% N: number of experiments to perform

% Deleting existing results!!
splits = []; selected_k = []; selected_lambdas = []; selected_ridgek = [];
save splits.mat splits;
save selected_k.mat selected_k; save selected_lambdas.mat selected_lambdas;
save selected_ridgek.mat selected_ridgek;
%


% save the splits
% => don't forget to initialize them
load('splits.mat')
load('selected_lambdas.mat')
load('selected_k.mat')


alg = cell(3);
algName = cell(3);

alg{1} = @ridgeRegression;
%alg{2}
alg{3} = @ksupMulticlassLogistic;


%b_ridge_regression = cell(N);
%betas_ksup = cell(N);
%selected_lambda = zeros(1,N);
%selected_k = zeros(1,N);
%selected_ridgek = zeros(1,N);

lambdas = 10.^[-6:6];
ks = [2, 4, 8, 16, 32, 64, 128, 256];

%lambdas = 10.^[-1:1];
%ks = [1, 30];

auc_test = zeros(3,N);

for i=1:N
    % split the data into training, validation and test sets
    blaschkoDisp(['experiment number ' num2str(i)]);
    [X Y Z r] = genData('processedData.csv');
    r = r';
    r = r(1:2000,:);
    splits = cat(2,splits,r);

    display('splits')
    splits(1:15,:)
    Xtrain = X(1:500,:);
    Ytrain = Y(1:500,:);
    Ztrain = Z(1:500,:);
    Xval = X(501:1000,:);
    Yval = Y(501:1000,:);
    Zval = Z(501:1000,:);
    Xtest = X(1001:2000,:);
    Ytest = Y(1001:2000,:);
    Ztest = Z(1001:2000,:);

    % use Y for KSUP and Z for others
    
    [n F] = size(Xtrain);

    % 1 - ridge regression
    % 2 - single best variable
    % 3 - ksupLR
%    aucVal{i} = cell(3);
%    aucTest{i} = cell(3);
    
%    b_ridge_regression{i} = zeros(1, F);
%    betas_ksup{i} = cell(F);
    
    % for each feature different from 'S2CQ4A'
    % predict 'S2CQ4A' using this feature only
    % compute the auc/acc on the validation set for each algorithm
    % save them
    
%    X = Xtrain;
%    Y = Ytrain;
%    Z = Ztrain;
    
    % train ridge regression
    display(['ridge regression'])
    [b, s_ridgek] = modelSelectionRidge(Xtrain, Ztrain, Xval, Zval, ks);
    
    % train single best variable
    display(['single best variable'])
    wbest = useSingleVariable(Xtrain,Ztrain);
    
    % save selected ridge_k
%    selected_ridgek(1,i) = s_ridgek;
    % save parameter b
 %   b_ridge_regression{i} = b;

    display(['k support'])
    % train ksupLogistic
    [beta,s_k,s_lambd] = modelSelection(alg{3},Xtrain,Ytrain,Xval,Yval,lambdas,ks);
    
    % save selected lambda
 %   selected_lambda(1,i) = s_lambd(1,1);
    
    % save selected k
 %   selected_k(1,i) = s_k;
    
    % save selected beta
%    betas_ksup{i} = beta;
    
    % ========================
    
    % compute auc on val set
    % not for single best variable (no parameter selection)
    % for ridge regression
%    display(['prediction val with ridge regression'])
%    pred1 = Xval*b;
    
%    [a1, b1, c1, auc1] = perfcurve(Zval,pred1,1);
    
 %   aucValTab1 = auc1;
        
    % compute auc on val set
    % for ksupLR (k = 1)
 %   e = ones(size(Xval,1),1);
 %   pred3 = [e Xval]*beta;
 %   [score,predind] = max(pred3,[],2);
 %   [score,Yvalind] = max(Yval,[],2);
 %   [a3,b3,c3,auc3]=perfcurve(Yvalind,pred3(:,1)-pred3(:,2),1);
  %  aucValTab3 = auc3;
    
  %  aucVal{1} = aucValTab1;
  %  aucVal{3} = aucValTab3;
    
    % TODO save predicted variable
    
    % use it to predict 'S2CQ4A' on the test set
    % compute the auc/acc on this test set and save it
    
    
    % using ridge regression
    display(['ridge regression on test set'])
   % b = b_ridge_regression{i};
    pred_test1 = Xtest*b;
    
    % pred_test
    [x1, y1, c1, auc_test1] = perfcurve(Ztest,pred_test1,1);
    
    % aucTest{i}{1} = auc_test;
    display(['auc_test ridge ' num2str(auc_test1)])
    
    % using single best variable
    display(['single best variable on test set'])
    pred_test2 = Xtest*wbest;
    [x2, y2, c2, auc_test2] = perfcurve(Ztest,pred_test2,1);
    
    % using ksupLR
   % beta_test = betas_ksup{i};
    beta_test = beta;
    
    e = ones(size(Xtest,1),1);
    pred3 = [e Xtest]*beta_test;
    [score,predind] = max(pred3,[],2);
    [score,Ytestind] = max(Ytest,[],2);
   % acc = length(find(predind==Ytestind))/length(Ytestind);
    [x3,y3,c3,auc_test3]=perfcurve(Ytestind,pred3(:,1)-pred3(:,2),1);
    
    display(['auc_test ksup ' num2str(auc_test3)])
   
    auc_test(:,i) = [auc_test1; auc_test2; auc_test3]

    filename = strcat('roc_',num2str(i));
    filename = strcat(filename,'.mat');
    
    if exist(filename,'file')==2
        delete(filename);
    end
    save(filename,'x1','y1','x2','y2','x3','y3', 'auc_test1', 'auc_test2', 'auc_test3');

end
save auc_test.mat auc_test;
save splits.mat splits;
%save all_aucTest aucTest;

end

function [X Y Z r] = genData(filename)

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
Z = Z(ind_nonZ,:);
Y = Y(ind_nonZ,:);
X = X(ind_nonZ,:);

for k = 1:size(X,1)
     if  Z(k,1) == 1
         Y(k,:) = [1 0];
         
     elseif Z(k,1) == -1
          Y(k,:) = [0 1]; 
     end
end

% added for ridge and svm
 Z = Z(:,1);
% ===
 
% Shuffle the data
r = randperm(size(Y,1));
X = X(r,:);
Y = Y(r,:);
% added for ridge regression
Z = Z(r,:);
% ===

end


function blaschkoDisp(message)
disp([message ' ' datestr(now)]);
end

function b = ridgeRegression(y, X, k)
    %The model does not include a constant term,
    % and X should not contain a column of 1s
    
    b = ridge(y,X,k);
end


function [beta,s_k,s_lambd] = modelSelection(func,Xtrain,Ytrain,Xval,Yval,lambdas,ks)

s_lambd = zeros(3,1);
s_k = 0;

dd = size(Xtrain,2);
e = ones(size(Xval,1),1);
aucval = -Inf;
%accval = -Inf;
    display('model selection ksup')

    beta = zeros(size(Xval,2)*size(Yval,2),1); 
    for i=1:length(lambdas)
        for j = 1:length(ks)
            display(['\lambda = ' num2str(lambdas(i)) ' k = ' num2str(ks(j))])
            w = func(Xtrain,Ytrain,lambdas(i),ks(j));
            w = reshape(w,[size(Xtrain,2)+1 size(Ytrain,2)]);
            
            pred = [e Xval]*w;

            [score,predind] = max(pred,[],2);
            [score,Yvalind] = max(Yval,[],2);
            [a,b,c,auc]=perfcurve(Yvalind,pred(:,1)-pred(:,2),1);
%            acc = length(find(predind==Yvalind))/length(Yvalind);
            
            if(auc>aucval)
%             if(acc>accval)
                aucval = auc;
                %accval = acc;
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

function [b,s_ridgek] = modelSelectionRidge(Xtrain,Ytrain,Xval,Yval,ks)

s_ridgek = 0;

dd = size(Xtrain,2);

display(['model selection in ridge regression'])
aucval = -Inf;
%accval = -Inf;
    b = zeros(size(Xval,2),1);
    for j = 1:length(ks)
        w = ridge(Ytrain,Xtrain,ks(j));
%        w = func(Xtrain,Ytrain,ks(j));
%        w = reshape(w,[size(Xtrain,2)+1 size(Ytrain,2)]);
        
        pred = Xval*w;

%        [score,predind] = max(pred,[],2);
 %       [score,Yvalind] = max(Yval,[],2);
        [a,b,c,auc]=perfcurve(Yval,pred,1);
%            acc = length(find(predind==Yvalind))/length(Yvalind);
            
        if(auc>aucval)
%             if(acc>accval)
            aucval = auc;
            %accval = acc;
            b = w;
            % save the best k
            s_ridgek = ks(j);
            % save the lambdas
        end
    end
end

function [w] = useSingleVariable(X,Y)
% Authors: Matthew Blaschko - matthew.blaschko@inria.fr
%          Hakim Sidahmed - hakimsd@gmx.com
% Copyright (c) 2014
%
% very simple baseline asked for by reviewer to use only one variable

  ws = [eye(size(X,2)) -eye(size(X,2))];

bestAuc = -Inf;
bestw = zeros(size(X,2),1);
for i=1:size(ws,2)
  pred = X*ws(:,i);
  if(calcAUC(pred,Y) > bestAuc)
    bestw = ws(:,i);
    bestAuc = calcAUC(pred,Y);
  end
end

w = bestw;
end

function auc = calcAUC(pred, Y)
    [a2, b2, c2, auc] = perfcurve(Y, pred, 1);
end
% end of file

