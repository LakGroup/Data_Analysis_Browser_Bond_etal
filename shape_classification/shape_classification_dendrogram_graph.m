function shape_classification_dendrogram_graph(data)
classes = data.classes;

for k = 1:size(classes,1)
    colors{k} = unique(cell2mat(classes{k,4}));
end
colors = unique(vertcat(colors{:}));
c_map = colormap(jet);
c_map = interp1(1:size(c_map,1),c_map,linspace(1,size(c_map,1),max(colors)));

if size(classes,1)<1000
    parameters = shape_classification_normalized_parameters(classes);    
    
    [link,distance,~] = shape_classification_finding_linkage(parameters);    
    
    inconsistent_value = inconsistent(link);
    inconsistent_value = inconsistent_value(:,4);   
    link(:,3) = link(:,3)*100;
    link(:,3) = log(link(:,3));      
    
    figure()
    set(gcf,'name','dendrogram','NumberTitle','off','color','w','units','normalized','position',[0 0.2 1 0.6],'WindowButtonMotionFcn',@mouseMove,'WindowButtonDownFcn',@mouse_down,'WindowButtonUpFcn',@mouse_up)
    uicontrol('style','pushbutton','units','normalized','position',[0,0,0.1,0.05],'string','Set Inconsistetn Value','Callback',{@set_inconsistent});
    uicontrol('style','pushbutton','units','normalized','position',[0.1,0,0.1,0.05],'string','Group Classes','Callback',{@group_classes});      
    uicontrol('style','pushbutton','units','normalized','position',[0.2,0,0.1,0.05],'string','Send Data','Callback',{@send_data_callback});
   
    leaf_order = optimalleaforder(link,distance);    
    if size(classes,1)<1000
        h = dendrogram(link,size(parameters,1),'reorder',leaf_order);
        for p=1:length(inconsistent_value)
            x_d(p,:) = get(h(p),'XData');
            y_d(p,:) = get(h(p),'YData');
        end
        title({[],'Dendrogram Graph',['Number of Classes = ',num2str(size(classes,1))]},'interpreter','latex','fontsize',18)
        set(gca,'box','on','ticklabelinterpreter','latex','fontsize',12)
        xtickangle(45)
    end
else
    msgbox('Number of Classes is More Than 1000')
end

    function set_inconsistent(~,~,~)        
        input_values = inputdlg({'inconsistent threshold'},'',1,{'1'});
        if isempty(input_values)==1
            return
        else
            cla(figure(200))
            color_threshold = str2double(input_values{1,1});
            for q=1:length(inconsistent_value)
                if inconsistent_value(q)>color_threshold
                    line(x_d(q,:),y_d(q,:),'color','r')
                else
                    line(x_d(q,:),y_d(q,:),'color','k')
                end
            end
        end
    end

    function group_classes(~,~,~)
        rec_coordinates = getrect;
        if isempty(rec_coordinates)
            return
        else
            x1 = rec_coordinates(1);
            x2 = x1+rec_coordinates(3);
        end
        X1 = min(x1,x2);
        X2 = max(x1,x2);
        X1 = ceil(X1);
        X2 = floor(X2);
        if X1<1
            X1 =1;
        end
        if X2>size(classes,1)
            X2 = size(classes,1);
        end        
        id = leaf_order(X1:X2);
        id = sort(id);
        idx = zeros(size(classes,1),1);        
        m = 0;
        for i=1:length(idx)
            if isempty(id)~=1
                if i==id(1)
                    idx(i) = 0;
                    id(1) = [];
                else
                    idx(i) = m+1;
                    m = m+1;
                end
            else
                idx(i) = m+1;
                m = m+1;                
            end
        end
        idx(idx==0) = max(idx)+1;        
        classes = cluster_classes(idx,classes);
        data.classes = classes;
        close(figure,'name','dendrogram')
        shape_classification_dendrogram_graph(data);
    end

    function mouseMove (~,~)
        global current_point
        current_point=get(gca,'CurrentPoint');
    end

    function mouse_down(~,~)
        global current_point
        if isequal(get(gcf,'SelectionType'),'normal')
            x = round(current_point(1,1));
            if x<1
                x = 1;
            end
            if x>size(classes,1)
                x = size(classes,1);
            end                    
            figure()
            set(gcf,'name','clusters in node','NumberTitle','off','color','w','units','normalized','position',[0.1 0.1 0.7 0.4])
            try
                index = randperm(length(classes{leaf_order(x),1}),10);
            catch
                index = 1:length(classes{leaf_order(x),1});
            end
            m = 0;
            for i=1:length(index)
                m = m+1;
                subplot(2,5,m)                
                data_to_plot = classes{leaf_order(x),1}{index(i)};                
                [~,data_to_plot] = pca(data_to_plot);
                scatter(data_to_plot(:,1),data_to_plot(:,2),5,c_map(classes{leaf_order(x),4}{index(i)},:),'filled')
                xlim([-1 75])
                ylim([-1 75])
                title(['Mass = ',num2str(classes{leaf_order(x),2}(index(i),1))],'interpreter','latex','fontsize',12)
                axis equal
                axis off
                set(gca,'color','w')
            end
            if length(classes{leaf_order(x),1})>10
                subplot(2,5,3)
                title(['Number of Clusters: ',num2str(length(classes{leaf_order(x),1}))],'interpreter','latex','fontsize',12)
            end
            elseif isequal(get(gcf,'SelectionType'),'alt')
        end
    end

    function mouse_up(~,~)
        close(figure,'name','clusters in node')
    end

    function send_data_callback(~,~,~)
        send_data_to_workspace(data)               
    end
end