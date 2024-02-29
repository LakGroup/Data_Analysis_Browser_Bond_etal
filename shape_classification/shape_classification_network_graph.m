function shape_classification_network_graph(classes)
if size(classes,1)<500    
    parameters = shape_classification_normalized_parameters(classes);
    disp('Finding Nodes and Edges')    
    number_of_nodes = size(parameters,1);
    [x,y] = meshgrid(1:number_of_nodes);
    x = triu(x,1);
    y = triu(y,1);    
    x = reshape(x,[number_of_nodes*number_of_nodes 1]);
    y = reshape(y,[number_of_nodes*number_of_nodes 1]);
    x(x==0) = [];
    y(y==0) = [];   
    parameters_average_dist = pdist2(parameters,parameters);
    parameters_average_dist = triu(parameters_average_dist,1);
    parameters_average_dist = reshape(parameters_average_dist,[number_of_nodes*number_of_nodes 1]);    
    parameters_average_dist(parameters_average_dist==0) = [];
    disp('plotting network')
    G = graph(x,y,parameters_average_dist);
    figure()
    plot(G,'EdgeColor','none','NodeColor','b','Layout','force','WeightEffect','direct','NodeLabel',1:number_of_nodes);
    title({[],'Distance Between Classes, Network Graph'},'interpreter','latex','fontsize',18)
    set(gcf,'color','w','units','normalized','position',[0.2 0.2 0.4 0.5])
else
    msgbox('class size is bigger than 500')
end
end