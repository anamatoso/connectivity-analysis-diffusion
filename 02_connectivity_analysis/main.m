%% Clean
clearvars
close all
maindir=pwd;

%% Load connectivity data

% Define situation
suffix="schaefer100cersubcort"; % AAL116 schaefer100cersubcort
aggregate = false;

% Define variables
folder = "matrix_data_unbiased/"+suffix;
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
else
    % Load data without index mapping since the nodes wont be aggregated
    for s = 1:length(sessions)
        [matrices_struct.(sessions(s)),~, ~, ~, ~] = load_matrices(folder,sessions(s));
    end
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
    metrics_labels.version1=get_label_metrics(1,importdata(maindir+'/'+suffix+'_labels.txt'));
    metrics_labels.version2=get_label_metrics(2,importdata(maindir+'/'+suffix+'_labels.txt'));
    disp(suffix + " not aggregated")
else
    metrics_labels.version1=get_label_metrics(1,importdata(maindir+'/'+suffix+'_regions_labels.txt'));
    metrics_labels.version2=get_label_metrics(2,importdata(maindir+'/'+suffix+'_regions_labels.txt'));
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
            % figure("Color","white")
            % boxplot([x y],[ones(size(x)) 2*ones(size(y))],'Labels',sessions)
            % title(metrics_labels_list(m),"FontSize",20,'Interpreter','none');set(gca,"FontSize",15)
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
                % figure("Color","white")
                % mdl = fitlm(table1(:,d),table2(:,m));
                % plot(mdl,"MarkerSize", 7, "Marker", "o");set(gca,"FontSize",15)
                % xlabel(string(clinical_data_names{d}));
                % ylabel(metrics_labels.(name)(m))
                % disp(v+", "+m+", "+d+", "+R+", "+p+", ")
            end
        end
    end
end

clear g v groups name table1 table2 m d R p mdl i metrics

%% NBS
if ~aggregate
    disp("NBS---------")
    % Load NBS matrix
    load("NBS_results/stats_uncorrected_"+suffix+"unbiased_t31.mat")
    mat = stats.midinter.contrast(2).conmat; mat = full(cell2mat(mat));mat = mat+mat';
    
    % Get remap
    vector=sum(mat);vector(vector>0)=1;
    %idx_map=(1:length(mat)).* vector;
    
    % Create new matrices
    for s = 1:length(sessions)

        % Mask with NBS binary matrix
        new_matrices_struct.(sessions(s))=matrices_struct.(sessions(s)).*mat;
        
        % Remove rows and columns without significant edges
        for v=length(vector):-1:1
            if vector(v)==0
                new_matrices_struct.(sessions(s))(v,:,:)=[];
                new_matrices_struct.(sessions(s))(:,v,:)=[];
            end
        end
    end

    %vector=vector(vector>0);idx_map=idx_map(idx_map>0);


    % Calculate metrics
    for version_metrics = 1:2
        for s = 1:length(sessions)
            new_metrics_struct.("version"+string(version_metrics)).(sessions(s)) = connectivity_metrics(new_matrices_struct.(sessions(s)),version_metrics,"Not Normalize");
        end
    end
    new_metrics_labels.version2=metrics_labels.version2;
    new_metrics_labels.version1=metrics_labels.version1(vector>0);

    % Analysis of metrics
    nnodes=length(vector(vector>0));
    for v=1:2
        name="version"+v;
        metrics_labels_list = new_metrics_labels.(name);
        for m = 1:length(metrics_labels_list)
        
            x = new_metrics_struct.(name).(sessions{1})(m,:);
            y = new_metrics_struct.(name).(sessions{2})(m,:);
            p=ranksum(x,y);
        
            if (p<0.05 && v==2) || (p<0.05/nnodes && v==1)
                disp(m+", "+metrics_labels_list(m)+": "+p)
                % figure("Color","white")
                % boxplot([x y],[ones(size(x)) 2*ones(size(y))],'Labels',sessions)
                % title(metrics_labels_list(m),"FontSize",20,'Interpreter','none');set(gca,"FontSize",15)
            end
        end
    end





end

clear x y p v name metrics_labels_list m nnodes s version_metrics vector new_metrics_struct new_matrices_struct new_metrics_labels maindir
