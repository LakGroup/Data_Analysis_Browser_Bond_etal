function shape_classification_som(data)
classes = data.classes;
input_values = inputdlg({'number of nodes'},'',1,{'8'});
if isempty(input_values)~=1
    parameters = shape_classification_normalized_parameters(classes);    
    nn_dim = str2double(input_values{1,1});
    disp('finding k clusters form som')
    dimension1 = nn_dim;
    dimension2 = nn_dim;
    net = selforgmap([dimension1 dimension2]);
    net = train(net,parameters');
    y = net(parameters');
    for i=1:size(y,2)
        idx(i) = find(y(:,i)==1);
    end
    classes = cluster_classes(idx',classes);    
    classes = classes(~cellfun(@isempty, classes(:,1)),:); 
    data.classes = classes;
    shape_classification_plot(data)
end
end