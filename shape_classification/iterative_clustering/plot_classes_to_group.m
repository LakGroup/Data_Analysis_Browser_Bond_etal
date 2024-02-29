function plot_classes_to_group(f,classes)
clf(f);
if length(classes{1,1})<=10
    for i = 1:length(classes{1,1})        
        subplot(1,10,i)
        scatter(classes{1,1}{i}(:,1),classes{1,1}{i}(:,2),1,'b','filled')
        if i ==1
            title(['Number of clusters in the class :',num2str(length(classes{1,1}))],'interpreter','latex','fontsize',18)
        end
        axis equal
        axis off        
    end
else
    index = randperm(length(classes{1,1}),10);
    k = 0;
    for i = index        
        k = k+1;        
        subplot(1,10,k)
        scatter(classes{1,1}{i}(:,1),classes{1,1}{i}(:,2),1,'b','filled')
        if k == 1
            title(['Number of clusters in the class :',num2str(length(classes{1,1}))],'interpreter','latex','fontsize',18)
        end
        axis equal
        axis off
    end   
end
end