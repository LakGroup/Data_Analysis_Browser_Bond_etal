function shape_classification_clustergram(classes)
if size(classes,1)<500
    parameters = shape_classification_normalized_parameters(classes);      
    disp('plotting clustergram')
    clustergram(parameters,'Standardize','row', 'RowPdist', 'correlation', 'ColumnPdist', 'correlation', 'ImputeFun', @knnimpute)
    set(gca,'box','on','boxstyle','full')
    set(gcf,'color','w')
else
    msgbox('number of classes should be less than 500')
end
end