function [metrics_labels] = get_label_metrics(version,node_labels)
% This funtion gets the labels of each metric given the choice of metrics
% and the label of each node

n_nodes=length(node_labels);
if version==1
    BC=strings(1,n_nodes);
    Ci=strings(1,n_nodes);
    EC=strings(1,n_nodes);
    D=strings(1,n_nodes);
    
    for i=1:n_nodes
        BC(i)="BC_"+node_labels(i);
        Ci(i)="Ci_"+node_labels(i);
        EC(i)="EC_"+node_labels(i);
        D(i)="D_"+node_labels(i);
        
    end
    metrics_labels=[BC Ci EC D];
    
elseif version==2
    metrics_labels=["Characteristic Path Length" "Global Efficiency" "Clustering Coefficient" "Modularity" "Average Strength" "Transitivity" "Small-worldness"];
    
elseif version==3
    RC=strings(1,n_nodes-1);

    for i=1:n_nodes-1     
        RC(i)="RC_"+num2str(i);
    end
    
    metrics_labels=RC;
    
    
end

