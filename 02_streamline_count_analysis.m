%% Clean
clearvars
close all
clc

%% Load streamline data

atlas = "JHUlabels"; % Selecct white matter atlas
atlas_labels=importdata(atlas+"_labels_short.txt"); % import labels of atlas
sessions = ["midcycle" "interictal"];

% Load streamlines of all groups
for s = 1:length(sessions)
    [streamlines.(sessions(s)),n_nodes] = load_streamlines("streamline_count/streamlines_"+atlas, sessions(s));
end

clear s

%% Compare streamlines

for region = 1:n_nodes
    x = streamlines.(sessions(1))(region,:);
    y = streamlines.(sessions(2))(region,:);
    p = ranksum(x,y,"method","exact");
    if p<0.05/length(atlas_labels) % correct for number of regions
        disp(sessions(1)+"-"+sessions(2)+", "+atlas_labels{region}+": "+p)
   
        % Make boxplot if significant difference
        figure("Color","white","Position",[360,178,769,420])
        x = cat(2,streamlines.(sessions{1})(region,:),streamlines.(sessions{2})(region,:));
        group = cat(2,ones(1,length(streamlines.(sessions{1})(region,:))),2*ones(1,length(streamlines.(sessions{2})(region,:))));    
        boxplot(x,group,"Labels",sessions)
        title(atlas_labels{region},"FontSize",20)
        ylim([0.95*min(x) 1.05*max(x)])
        set(gca,"FontSize",15)
    else
        disp(sessions(1)+"-"+sessions(2)+", "+atlas_labels{region}+": "+p+ " ns")
    end

end

clear p x group region

%% GLM including age as covariate

groups=["controls" "patients"];
for g=1:length(groups)
    dados_clinicos.(groups(g))=readtable("dados_clinicos_"+groups(g)+".csv");
end

table_matrics_controls=array2table(streamlines.midcycle','VariableNames',atlas_labels); %create table
table_matrics_controls.Age=dados_clinicos.controls.Age;
table_matrics_controls.Group=zeros(height(table_matrics_controls), 1); % add column for group

table_matrics_patients=array2table(streamlines.interictal','VariableNames',atlas_labels);
table_matrics_patients.Age=dados_clinicos.patients.Age;
table_matrics_patients.Group=ones(height(table_matrics_patients), 1); % add column for group

data = vertcat(table_matrics_controls, table_matrics_patients);
for m=1:length(atlas_labels)
    metric_name=atlas_labels(m);
    idx = find(strcmp(data.Properties.VariableNames, metric_name));
    metric_namefinal=strrep(metric_name, ' ', '');metric_namefinal=strrep(metric_namefinal, '_', '');metric_namefinal=strrep(metric_namefinal, '-', '');
    data.Properties.VariableNames{idx} = char(metric_namefinal);
    model = fitglm(data, metric_namefinal+" ~ Group + Age", 'Distribution', 'normal', 'Link', 'identity');
    %disp(model)
    p=model.Coefficients{"Group","pValue"};
    if p<0.05/length(atlas_labels)
        disp(atlas_labels(m)+" corrected for age p="+p)
    else 
        disp(atlas_labels(m)+" corrected for age p="+p + " ns")
    end
end