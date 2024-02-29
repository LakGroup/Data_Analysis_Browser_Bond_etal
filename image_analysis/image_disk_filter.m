function image_disk_filter(data)
figure()
set(gcf,'name','Disk Filter','NumberTitle','off','color','w','units','normalized','position',[0.25 0.15 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];    
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_one_callback});
end

size_slider = uicontrol('style','slider','units','normalized','position',[0.95,0,0.05,1],'value',1,'min',1,'max',20,'sliderstep',[1/1000,1/1000],'Callback',{@size_sld_callback});

uicontrol('style','pushbutton','units','normalized','position',[0.1,0.9,0.15,0.05],'string','Apply to All','fontsize',12,'callback',@apply_to_all);

slider_one_value=1;
size_slider_value = 1;

if length(data{slider_one_value}.image)>1
    slider_step_two=[1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0,0.9,0.05],'value',1,'min',1,'max',length(data{slider_one_value}.image),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

apply_filter(data{slider_one_value}.image{slider_two_value},size_slider_value)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.image)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
            slider_two.Max = length(data{slider_one_value}.image);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        apply_filter(data{slider_one_value}.image{slider_two_value},size_slider_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        apply_filter(data{slider_one_value}.image{slider_two_value},size_slider_value)
    end

    function size_sld_callback(~,~,~)
        size_slider_value = size_slider.Value;
        apply_filter(data{slider_one_value}.image{slider_two_value},size_slider_value)
    end

    function apply_filter(data,value)
        h = fspecial('disk',value);
        data = imfilter(data,h);        
        image_inside(data)
    end

    function image_inside(image)
        global color_map
        ax = gca; cla(ax);
        imshow(image)
        axis equal
        axis off
        set(gca,'colormap',color_map,'units','normalized','position',[0.15 0.18 0.7 0.7])       
        title(['size = ',num2str(size_slider_value)],'interpreter','latex','fontsize',12)
    end

    function apply_to_all(~,~)
        h = fspecial('disk',size_slider_value);
        for i = 1:length(data)
            f = waitbar(0,'calculating');  
            for j = 1:length(data{i}.image)
                waitbar(j/length(data{i}.image),f,'calculating')
                data{i}.image{j} = imfilter(data{i}.image{j},h);
            end
            close(f)
        end
        image_plot(data)
    end
end