function [classes,size_classes] = shape_classification_iterative_clustering(classes,coefficient_of_variation,method)
i = 0;
while i<2
    i = i+1;
    size_one = size(classes,1);
    disp(['please wait...',num2str(size_one)])
    [classes,size_classes{i}] = classify_iter(classes,coefficient_of_variation,method);
    size_two = size(classes,1);
    if abs(size_two-size_one) ==0
        break
    end
end
size_classes = horzcat(size_classes{:});
end

function [classes_grouped,size_classes] = classify_iter(classes,coefficient_of_variation,method)
%f = figure();
%set(gcf,'color','w','name','Scatter_plot_clusters','NumberTitle','off','color','w','units','normalized','position',[0.1 0.3 0.7 0.3],'menubar','none')
%close(f)       
i = 0;
size_classes(1) = size(classes,1);
while size(classes,1)>1
    i = i +1;
    [classes,classes_grouped{i}] = classify_clusters(classes,coefficient_of_variation,method);
    size_classes(i+1) = size(classes,1);
    %size_classes(i+1) = size_classes(i) - size(classes_grouped{i}{1},1);    
end
classes_grouped = vertcat(classes_grouped{:});
if isempty(classes)~=1
    classes_grouped(end+1,:) = classes;
end

[~,I] = min(abs(size_classes-size(classes_grouped,1)));
match_value = size_classes(I);
if match_value>size(classes_grouped,1)
    size_classes(I+1:end) = [];
    size_classes(end+1) = size(classes_grouped,1);
elseif match_value<size(classes_grouped,1)
    size_classes(I:end) = [];
    size_classes(end+1) = size(classes_grouped,1);
else
    size_classes(I+1:end) = [];
end

mass = classes_grouped(:,3);
mass = cell2mat(cellfun(@(x) x(1,1), mass,'UniformOutput',false));
[~,I] = sort(mass);
classes_grouped = classes_grouped(I,:);
end