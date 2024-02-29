function shape_classification_save_results_bin(data)
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
        save_bin(classes{p,1},fullfile(path,num2str(p)))
    end
end
end

function save_bin(classes,path)
i3 = Insight3();
for k = 1:length(classes)
    disp(['saving_image_',num2str(k),'/',num2str(length(classes))])
    [~,data_to_save] = pca(classes{k});    
    x = data_to_save(:,1);
    y = data_to_save(:,2);
    z = zeros(size(data_to_save,1),1);
    data(:,1) = x;
    data(:,2) = y;
    data(:,3) = x;
    data(:,4) = y;
    data(:,5) = 100;
    data(:,6) = 10000;
    data(:,7) = 300;
    data(:,8) = 0;
    data(:,9) = 1;
    data(:,10) = 0;
    data(:,11) = 10000;
    data(:,12) = 1;
    data(:,13) = 1;
    data(:,14) = 1;
    data(:,15) = 1;
    data(:,16) = -1;
    data(:,17) = z;
    data(:,18) = z;
    i3 = Insight3();
    i3.setData(data);
    i3.write(fullfile(path,[num2str(k),'.bin']));
    clear data x y z data_to_save
end
end