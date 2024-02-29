function shape_classification_supervised_clustering(data)
classes = data.classes;
if size(classes,1)<200
    disp('calculating nodes and edges')
    parameters = classes(:,3);
    parameters = vertcat(parameters{:});
    parameters = zscore(parameters);
    number_of_nodes = size(parameters,1);
    [x,y] = meshgrid(1:number_of_nodes);
    x = triu(x,1);
    y = triu(y,1);
    x = reshape(x,[number_of_nodes*number_of_nodes 1]);
    y = reshape(y,[number_of_nodes*number_of_nodes 1]);
    x(x==0) = [];
    y(y==0) = [];
    dist_cityblock = pdist(parameters,'cityblock');
    linkage_average = linkage(dist_cityblock,'average');
    m = 0;
    I = 0;
    for p=1:size(linkage_average,1)
        if linkage_average(p,1)>size(classes,1)
            m = m+1;
            I(m) = p;
        end
    end
    if I~=0
        linkage_average(I,:) = [];
    end
    for p=1:size(linkage_average,1)
        if linkage_average(p,2)>size(classes,1)
            linkage_average(p,2) = linkage_average(p,1);
        end
    end
    
    G = graph(linkage_average(:,1),linkage_average(:,2),linkage_average(:,3));
    figure()
    h = plot(G,'EdgeColor','k','NodeColor','b','MarkerSize',10,'Layout','force','WeightEffect','direct','NodeLabel',1:number_of_nodes);
    set(gcf,'color','w','units','normalized','position',[0.1 0.1 0.8 0.8])
    set(gcf,'WindowButtonDownFcn',@(f,~)edit_graph(f,h,classes))
    uicontrol('style','pushbutton','units','normalized','position',[0,0,0.2,0.08],'string','Classify Adjacent Nodes','Callback',{@classify_nodes});
    xlim([min(h.XData)-min(h.XData) max(h.XData)+min(h.XData)])
    ylim([min(h.YData)-min(h.YData) max(h.YData)+min(h.YData)])
else
    msgbox('classes size is bigger than 200')
end

    function classify_nodes(~,~,~)
        x = h.XData;
        y = h.YData;
        input_values = inputdlg({'number of clusters to bundle'},'',1,{'5'});
        if isempty(input_values)==1
            return
        else
            kmeans_k = str2double(input_values{1,1});
            data_classify = [x',y'];
            idx = kmeans(data_classify,kmeans_k);
            figure()
            gscatter(x,y,idx)
            for i=1:size(data_classify,1)
                text(x(i),y(i),num2str(i))
            end
        end
        data.classes = cluster_classes(idx,classes);        
        shape_classification_plot(data)
    end
end


function edit_graph(f,h,classes)

% Figure out which node is closest to the mouse.
a = ancestor(h,'axes');
pt = a.CurrentPoint(1,1:2);
dx = h.XData - pt(1);
dy = h.YData - pt(2);
len = sqrt(dx.^2 + dy.^2);
[lmin,idx] = min(len);

% If we're too far from a node, just return
tol = max(diff(a.XLim),diff(a.YLim))/20;
if lmin > tol || isempty(idx)
    return
end
node = idx(1);

% Install new callbacks on figure
f.WindowButtonMotionFcn = @motion_fcn;
f.WindowButtonUpFcn = @mouse_up;

% A ButtonMotionFcn that changes XData & YData
    function motion_fcn(~,~)
        newx = a.CurrentPoint(1,1);
        newy = a.CurrentPoint(1,2);
        h.XData(node) = newx;
        h.YData(node) = newy;
        drawnow;
    end

% A ButtonUpFcn which stops dragging
    function mouse_up(~,~)
        f.WindowButtonMotionFcn = [];
        f.WindowButtonUpFcn = [];
        
        if isequal(get(gcf,'SelectionType'),'alt')
            try
                index = randperm(length(classes{idx,1}),10);
            catch
                index = 1:length(classes{idx,1});
            end
            figure()
            set(gcf,'color','w','units','normalized','outerposition',[0.2 0.2 0.7 0.7])
            m = 0;
            for p =1:length(index)
                m = m+1;
                subplot(2,5,m)
                scatter(classes{idx,1}{index(p)}(:,1),classes{idx,1}{index(p)}(:,2),1,'b','filled')
                title({['mass=',num2str(classes{idx,2}(index(p),1))],['area=',num2str(classes{idx,2}(index(p),2))]},'interpreter','latex')
                axis off
                axis equal
                set(gca,'color','w')
            end
        end
    end
end