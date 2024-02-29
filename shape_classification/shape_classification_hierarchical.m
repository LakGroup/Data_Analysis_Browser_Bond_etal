function shape_classification_hierarchical(data)
list_selection = listdlg('ListString',{'Inconsistent Cutoff','Distance Cutoff','K-max Cutoff'},'SelectionMode','single');

classes = data.classes;

if isempty(list_selection)~=1  
    parameters = shape_classification_normalized_parameters(classes);
    [link,~,~] = shape_classification_finding_linkage(parameters); 
   
    
    disp('Calculating Inconsistent Value')
    inconsistent_value = inconsistent(link);
    inconsistent_value = inconsistent_value(:,4);
    inconsistent_value = unique(inconsistent_value);
    
    cutoff_inconsistent = 9999*max(inconsistent_value)/10000;
    cutoff_distance = mean(link(:,3));
    cutoff_k_max = ceil(50*size(parameters,1)/100);
    
    if list_selection ==1
        input_values = inputdlg({'cutoff for inconsistent value'},'',1,{num2str(cutoff_inconsistent)});
        if isempty(input_values)==1
            return
        else
            cutoff = str2double(input_values{1,1});
            idx = cluster(link,'cutoff',cutoff,'Criterion','inconsistent');
            answer = questdlg({['Number of clusters using inconsistent measure is: ',num2str(length(unique(idx)))],'Would you like to perform clustering?'},'Yes','No');
            switch answer
                case 'Yes'
                    classes = cluster_classes(idx,classes);
                    data.classes = classes;
                    data.name = [data.name,'_inconsistent_cutoff_',input_values{1}];
                    shape_classification_plot(data)
                case 'No'
                    return
                case 'Cancel'
                    return
            end
        end
    elseif  list_selection ==2
        input_values = inputdlg({'cutoff for distance value'},'',1,{num2str(cutoff_distance)});
        if isempty(input_values)==1
            return
        else
            cutoff = str2double(input_values{1,1});
            idx = cluster(link,'cutoff',cutoff,'Criterion','distance');
            answer = questdlg({['Number of clusters using distance measure is: ',num2str(length(unique(idx)))],'Would you like to perform clustering?'},'Yes','No');
            switch answer
                case 'Yes'
                    classes = cluster_classes(idx,classes);
                    data.classes = classes;
                    data.name = [data.name,'_distance_cutoff_',input_values{1}];
                    shape_classification_plot(data)
                case 'No'
                    return
                case 'Cancel'
                    return
            end
        end
    elseif list_selection ==3
        input_values = inputdlg({'k-max'},'',1,{num2str(cutoff_k_max)});
        if isempty(input_values)==1
            return
        else
            cutoff = str2double(input_values{1,1});
            idx = cluster(link,'maxclust',cutoff);
            classes = cluster_classes(idx,classes);
            data.classes = classes;
            data.name = [data.name,'_maxclust_cutoff_',input_values{1}];
            shape_classification_plot(data)
        end
    end
end
end