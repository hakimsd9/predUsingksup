function correlations()

    M = csvread('topVarsOneCol.csv');
    [rho, pval] = corr(M, 'rows','all');

    
    labels = cell(0);

    labels{length(labels)+1} = 'S2CQ1';
    labels{length(labels)+1} = 'S2DQ4C2';
    labels{length(labels)+1} = 'SEDP12ABDEP';
    labels{length(labels)+1} = 'TRANP12ABDEP';
    labels{length(labels)+1} = 'PANP12ABDEP';
    labels{length(labels)+1} = 'HERP12ABDEP';
    labels{length(labels)+1} = 'SED12ABDEP';
    labels{length(labels)+1} = 'S2DQ14A';
    labels{length(labels)+1} = 'SOLP12ABDEP';
    labels{length(labels)+1} = 'DAPANDXSNISP12';
    labels{length(labels)+1} = 'DGPANDXSNIS12';
    labels{length(labels)+1} = 'SOL12ABDEP';
    labels{length(labels)+1} = 'HER12ABDEP';
    labels{length(labels)+1} = 'DGPANDXSNISP12';
    labels{length(labels)+1} = 'COC12ABDEP';
    labels{length(labels)+1} = 'TRAN12ABDEP';
    labels{length(labels)+1} = 'S2DQ14B';
    labels{length(labels)+1} = 'STIMP12ABDEP';
    labels{length(labels)+1} = 'STIM12ABDEP';
    labels{length(labels)+1} = 'HAL12ABDEP';
    labels{length(labels)+1} = 'HALP12ABDEP';
    labels{length(labels)+1} = 'DAPANDXSNIS12';
    labels{length(labels)+1} = 'PAN12ABDEP';
    labels{length(labels)+1} = 'DNMANDXSNIS12';
    labels{length(labels)+1} = 'COCP12ABDEP';
    labels{length(labels)+1} = 'S4AQ16';
    labels{length(labels)+1} = 'S4CQ15A';
    labels{length(labels)+1} = 'S4CQ15B';
    labels{length(labels)+1} = 'S4CQ16';
    labels{length(labels)+1} = 'DDYSSNIS12';
    labels{length(labels)+1} = 'DNMANDXSNISP12';
    labels{length(labels)+1} = 'DGENAXDXSNIS12';
    labels{length(labels)+1} = 'S2DQ2';
    labels{length(labels)+1} = 'MAR12ABDEP';
    labels{length(labels)+1} = 'S3EQ2';
    labels{length(labels)+1} = 'ALCABDEPP12DX';
    labels{length(labels)+1} = 'DDYSSNISP12';
    labels{length(labels)+1} = 'DNHYPOSNIS12';
    labels{length(labels)+1} = 'S2DQ3C2';
    labels{length(labels)+1} = 'S6Q21';
    labels{length(labels)+1} = 'S6Q22';
    labels{length(labels)+1} = 'S6Q23';
    labels{length(labels)+1} = 'S6Q24';
    labels{length(labels)+1} = 'S2DQ13B';
    labels{length(labels)+1} = 'S9Q17';
   
    
    plotMatrix(rho,labels);

    
    
end
