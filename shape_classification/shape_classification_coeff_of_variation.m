function shape_classification_coeff_of_variation(data)
classes = data.classes;
N = cellfun(@(x) length(x), classes(:,1));
for i=1:size(classes,1)
    variation(i,:) = abs(std(classes{i,2},0,1)./mean(classes{i,2},1));
end
similarity_measure = sum(N.*variation);
variation = variation(:,[1:2,7:8]);
similarity_measure = similarity_measure([1,2,7,8]);
variation(:,end+1) = N;
variation(end+1,1:4) = similarity_measure;
variation(end,5) = sum(N);
f=figure('Name','Coefficient of Variation for each Class','Position',[810 100 500 800],'MenuBar','none','ToolBar','none');
uitable(f,'Data',variation,'ColumnName',{'Mass','Area','Length','Width','Number of Clusters'},'Position',[10 10 490 790],'FontSize',10,'ForegroundColor','r');
end