function image_sharpen(data)
figure()
set(gcf,'name','Sharpen Image','NumberTitle','off','color','w','units','normalized','position',[0.25 0.15 0.4 0.6],'menubar','none')
set(1,'defaultfiguretoolbar','figure');

if length(data)>1
    slider_step=[1/(length(data)-1),1];    
    slider = uicontrol('style','slider','units','normalized','position',[0,0.95,1,0.05],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end

uicontrol('style','text','units','normalized','position',[0,0,0.2,0.05],'string','radius','Backgroundcolor','w','fontsize',12);
radius_slider = uicontrol('style','slider','units','normalized','position',[0.2,0,0.8,0.05],'value',1,'min',1,'max',10,'sliderstep',[1/100,1],'Callback',{@radius_sld_callback});

uicontrol('style','text','units','normalized','position',[0,0.05,0.2,0.05],'string','amount','Backgroundcolor','w','fontsize',12);
amount_slider = uicontrol('style','slider','units','normalized','position',[0.2,0.05,0.8,0.05],'value',1,'min',0,'max',2,'sliderstep',[1/100,1],'Callback',{@amount_sld_callback});

uicontrol('style','text','units','normalized','position',[0,0.1,0.2,0.05],'string','threshold','Backgroundcolor','w','fontsize',12);
threshold_slider = uicontrol('style','slider','units','normalized','position',[0.2,0.1,0.8,0.05],'value',0,'min',0,'max',1,'sliderstep',[1/100,1],'Callback',{@threshold_sld_callback});

uicontrol('style','pushbutton','units','normalized','position',[0,0.9,0.15,0.05],'string','Apply to All','fontsize',12,'callback',@apply_to_all);

slider_value=1;
radius_slider_value = 1;
amount_slider_value = 1;
threshold_slider_value = 0;
apply_sharpen_filter(data{slider_value})

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        apply_sharpen_filter(data{slider_value})
    end

    function image_inside(data)
        ax = gca; cla(ax);
        imagesc(data.image)
        axis off
        set(gca,'units','normalized','position',[0.15 0.18 0.7 0.7])
        colormap(gray)
        title(['radius = ',num2str(radius_slider_value),' amount = ',num2str(amount_slider_value),' threshold = ',num2str(threshold_slider_value)])
    end

    function radius_sld_callback(~,~,~)
        radius_slider_value = radius_slider.Value;
        apply_sharpen_filter(data{slider_value})
    end

    function amount_sld_callback(~,~,~)
        amount_slider_value = amount_slider.Value;
        apply_sharpen_filter(data{slider_value})
    end

    function threshold_sld_callback(~,~,~)
        threshold_slider_value = threshold_slider.Value;
        apply_sharpen_filter(data{slider_value})
    end

    function apply_sharpen_filter(data)
        data.image = imsharpen(data.image,'Radius',radius_slider_value,'Amount',amount_slider_value,'Threshold',threshold_slider_value);
        image_inside(data)
    end

    function apply_to_all(~,~)
        for i = 1:length(data)
            data{i}.image = imsharpen(data{i}.image,'Radius',radius_slider_value,'Amount',amount_slider_value,'Threshold',threshold_slider_value);
        end
        image_plot(data)
    end
end