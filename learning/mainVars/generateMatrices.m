function [X Y] = generateMatrices(filename)


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
end
