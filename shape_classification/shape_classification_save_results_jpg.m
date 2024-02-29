function shape_classification_save_results_jpg(data)
classes = data.classes;
path = uigetdir();
if path~=0
    mass = classes(:,3);
    mass = vertcat(mass{:});
    mass = mass(:,1);
    [~,I] = mink(mass,size(classes,1));
    classes = classes(I,:);
    for p=1:size(classes,1)
        mkdir(fullfile(path,num2str(p)))
        convert_to_image(classes{p,1},fullfile(path,num2str(p)))
    end
end
end

function convert_to_image(data,path)
pixel_size = 116;
resolution = 5;
for k = 1:length(data)
    disp(['saving_image_',num2str(k),'/',num2str(length(data))])    
    [~,points] = pca(data{k});
    points(:,1) = points(:,1)-min(points(:,1));
    points(:,2) = points(:,2)-min(points(:,2));    
    points = round(points*pixel_size/resolution);
    points(points==0)=1;
    image_data = zeros([max(points(:,1)) max(points(:,2))]);
    for i=1:size(points,1)
        image_data(points(i,1),points(i,2)) = image_data(points(i,1),points(i,2))+1;
    end
    imwrite(image_data,fullfile(path,[num2str(k),'.jpg']),'JPEG');
    clear points image_data
end
end

function convert_to_image_same_size(data,path)
for k = 1:length(data)
    disp(['saving_image_',num2str(k),'/',num2str(length(data))])
    [~,points] = pca(data{k});
    cla(figure(200))
    scatter(points(:,1),points(:,2),5,'k','filled')
    axis off
    axis equal
    axis tight
    print(gcf,fullfile(path,[num2str(k),'.png']),'-dpng','-r150');
    clear points
end
end