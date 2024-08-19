%% Clean
clearvars
close all
maindir=pwd;
maindir=string(maindir);
%% Load connectivity data

% Define situation (CHANGE IF NEEDED)
suffix="AAL116"; % Options: AAL116, schaefer100cersubcort
aggregate = false; % Options: true (for connectivity metrics), false (for NBS)

% Define variables
folder = "matrix_data/"+suffix;
sessions = ["midcycle" "interictal"];
idx_map_s100=[ones(1,9), 2*ones(1,6), 4*ones(1,8), 5*ones(1,7), 7*ones(1,3), 3*ones(1,4), 6*ones(1,13),...
            8*ones(1,8), 9*ones(1,8), 11*ones(1,7), 12*ones(1,5), 14*ones(1,2), 10*ones(1,9), 13*ones(1,11),...
    repmat([15,16],[1,6])...
    repmat([17,18],[1,2]), repmat([19,20],[1,7]),21*ones(1,8)];
idx_map_AAL116=[repmat([3,4],[1,17]), 5,6,9,10,7,8,9,10, repmat([1,2],[1,7]), repmat([5,6],[1,7]), ...
    repmat([9,10],[1,4]),repmat([7,8],[1,6]),...
    repmat([11,12],[1,2]),repmat([13,14],[1,7]),15*ones(1,8)];


if aggregate % If we want to aggregate nodes into bigger regions

    % Check which index mapping to use
    if suffix=="AAL116"
        idx_map=idx_map_AAL116;
    else
        idx_map=idx_map_s100;
    end

    % Load data
    for s = 1:length(sessions)
        [matrices_struct.(sessions(s)),~, ~, ~, ~] = load_matrices(folder,sessions(s),idx_map);
    end

    % Load the node labels
    node_labels=importdata(maindir+'/'+suffix+'_regions_labels.txt');

else
    % Load data without index mapping since the nodes wont be aggregated
    for s = 1:length(sessions)
        [matrices_struct.(sessions(s)),~, ~, ~, ~] = load_matrices(folder,sessions(s));
    end
    % Load the node labels
    node_labels=importdata(maindir+'/'+suffix+'_labels.txt');

end

% Calculate number of nodes
nnodes=size(matrices_struct.(sessions(1)),1);

clear s folder idx_map_s100 idx_map_AAL116 idx_map

%% Calculate metrics

% Calculate nodal and global metrics
for version_metrics = 1:2
    for s = 1:length(sessions)
        metrics_struct.("version"+string(version_metrics)).(sessions(s)) = connectivity_metrics(matrices_struct.(sessions(s)),version_metrics,"Not Normalize");
    end
end

% Get names of metrics depending on whether there is aggregation
if ~aggregate
    metrics_labels.version1=get_label_metrics(1,node_labels);
    metrics_labels.version2=get_label_metrics(2,node_labels);
    disp(suffix + " not aggregated")
else
    metrics_labels.version1=get_label_metrics(1,node_labels);
    metrics_labels.version2=get_label_metrics(2,node_labels);
    disp(suffix + " aggregated")
end

clear version_metrics s

%% Analysis of metrics

for v=1:2
    name="version"+v;
    metrics_labels_list = metrics_labels.(name);
    for m = 1:length(metrics_labels_list)
    
        x = metrics_struct.(name).(sessions{1})(m,:);
        y = metrics_struct.(name).(sessions{2})(m,:);
        p=ranksum(x,y);
        if (p<0.05 && v==2) || (p<0.05/nnodes && v==1)
            disp(m+", "+metrics_labels_list(m)+": "+p)

            % Plot boxplots if significant
            figure("Color","white")
            boxplot([x y],[ones(size(x)) 2*ones(size(y))],'Labels',sessions)
            title(metrics_labels_list(m),"FontSize",20,'Interpreter','none');set(gca,"FontSize",15)
        else
            disp(m+", "+metrics_labels_list(m)+": "+p + " ns")
        end
    end
end

clear x y p m name metrics_labels_list v

%% Dados clínicos
warning('off','all')

% Load clinical data and their names
groups=["controls" "patients"];
for g=1:length(groups)
    dados_clinicos.(groups(g))=readtable("dados_clinicos_"+groups(g)+".csv");
end
clinical_data_names=dados_clinicos.patients.Properties.VariableNames;

for v=1:2
    name="version"+v;
    metrics.(name).controls=metrics_struct.(name).midcycle';
    metrics.(name).patients=metrics_struct.(name).interictal';
end

% Create table with correlation results
results=table('Size',[1,4],'VariableTypes',["string","string","double","double"],'VariableNames',["Metric", "Data", "R", "pvalue"]);
i=1;
for v=1:2
    name="version"+v;
    metrics_labels_list = metrics_labels.(name);
    for m=1:length(metrics_labels_list)
        for d=1:size(dados_clinicos.patients,2)
            table1=table2array(dados_clinicos.patients);
            table2=metrics.(name).patients;
            [R,p]=corrcoef(table1(:,d),table2(:,m),"Rows","complete");
            p=p(1,2);R=R(1,2);
            if ~isnan(p)
                results(i,:)={metrics_labels_list(m), string(clinical_data_names{d}), R, p};
                i=i+1;
            end
            
            if (p<0.05 && v==2) || (p<0.05/nnodes && v==1)
                disp(metrics_labels_list(m)+" x "+string(clinical_data_names{d})+": R="+R+", p="+p)
            end
        end
    end
end

clear g v groups name table1 table2 m d R p mdl i metrics

%% GLM to include age as covariate

for v=1:2
    name="version"+v;
    metrics_labels_list = metrics_labels.(name);
    table_matrics_controls=array2table(metrics_struct.(name).midcycle','VariableNames',metrics_labels_list); %create table
    table_matrics_controls.Age=dados_clinicos.controls.Age;
    table_matrics_controls.Group=zeros(height(table_matrics_controls), 1); % add column for group
    
    table_matrics_patients=array2table(metrics_struct.(name).interictal','VariableNames',metrics_labels_list);
    table_matrics_patients.Age=dados_clinicos.patients.Age;
    table_matrics_patients.Group=ones(height(table_matrics_patients), 1); % add column for group
    
    data = vertcat(table_matrics_controls, table_matrics_patients);
    for m=1:length(metrics_labels_list)
        metric_name=metrics_labels_list(m);
        idx = find(strcmp(data.Properties.VariableNames, metric_name));
        metric_namefinal=strrep(metric_name, ' ', '');metric_namefinal=strrep(metric_namefinal, '_', '');metric_namefinal=strrep(metric_namefinal, '-', '');
        data.Properties.VariableNames{idx} = char(metric_namefinal);
        model = fitglm(data, metric_namefinal+" ~ Group + Age", 'Distribution', 'normal', 'Link', 'identity');
        %disp(model)
        p=model.Coefficients{"Group","pValue"};
        
        if (p<0.05 && v==2) || (p<0.05/nnodes && v==1)
            disp(metrics_labels_list(m)+" corrected for age p="+p)
        else
            disp(metrics_labels_list(m)+" corrected for age p="+p + " ns")
        end

    end
end

%% NBS 
if ~aggregate
    % Turn connectivity matrices csvs into txt to NBS to read
    !./pyenv/bin/python ./auxilliary/csv2txt.py
    
    % Global variables
    UI.method.ui='Run NBS'; 
    UI.test.ui='t-test';
    UI.size.ui='Extent';
    UI.perms.ui='5000';
    UI.alpha.ui='0.05';
    UI.exchange.ui='';
    if suffix == "AAL116"
        UI.node_coor.ui='./NBS1.2/AAL/aalCOG.txt'; % Must be on the NBS folder
        UI.node_label.ui='./NBS1.2/AAL/aalLABELS.txt'; % Must be on the NBS folder
        UI.matrices.ui='./matrix_data_txt/AAL116/sub-control019_ses-midcycle_matrix_mrtrix_AAL116.txt';
    else
        UI.node_coor.ui='./auxilliary/schaefer100subcortcer_coord.txt'; 
        UI.node_label.ui='./auxilliary/schaefer100cersubcort_labels.txt';
        UI.matrices.ui ='./matrix_data_txt/schaefer100cersubcort/sub-control019_ses-midcycle_matrix_mrtrix_schaefer100cersubcort.txt';
    end
    
    UI.thresh.ui='3.1';
    UI.design.ui='./auxilliary/design_matrix.txt';
    
    % Run with -1 1 contrast
    UI.contrast.ui='[-1,1,0]';
    nbs=NBSrun(UI,'');
    p=nbs.NBS.pval;
    disp(p)
    if ~isempty(nbs.NBS.con_mat)
        result=nbs.NBS.con_mat{1};
        save("stat_"+suffix+"c-11","result") % Save run
    end
    
    % Run with 1 -1 contrast
    UI.contrast.ui='[1,-1,0]';
    nbs=NBSrun(UI,'');
    p=nbs.NBS.pval;
    if ~isempty(nbs.NBS.con_mat)
        result=nbs.NBS.con_mat{1};
        save("stat_"+suffix+"_c1-1","result") % Save run
    end
    
    % Display names of pairs of nodes that for a significant connection
    % according to NBS

    disp("NBS contrast [-1,1,0] ---------")
    % Load NBS matrix
    load("stat_"+suffix+"_c-11.mat")
    %mat = stats.midinter.contrast(2).conmat; mat = full(cell2mat(mat));mat = mat+mat';
    result=full(result);result = result+result';
    % Display significant connections
    for i=1:length(result)
        for j=1:length(result)
            if result(i,j)==1
                disp(node_labels(i)+", " +node_labels(j))
            end
        end
    end

    disp("NBS contrast [1,-1,0] ---------")
    % Load NBS matrix
    load("stat_"+suffix+"_c1-1.mat")
    %mat = stats.midinter.contrast(2).conmat; mat = full(cell2mat(mat));mat = mat+mat';
    result=full(result);result = result+result';
    % Display significant connections
    for i=1:length(result)
        for j=1:length(result)
            if result(i,j)==1
                disp(node_labels(i)+", " +node_labels(j))
            end
        end
    end
end

