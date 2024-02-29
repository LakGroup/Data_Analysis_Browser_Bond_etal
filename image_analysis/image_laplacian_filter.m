function image_laplacian_filter(data)
figure()
set(gcf,'name','Laplacian Filter','NumberTitle','off','color','w','units','normalized','position',[0.25 0.15 0.4 0.6],'menubar','none','toolbar','figure')

if length(data)>1
    slider_step=[1/(length(data)-1),1];    
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.05,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_one_callback});
end

sigma_slider = uicontrol('style','slider','units','normalized','position',[0.96,0.05,0.04,0.95],'value',0.1,'min',0,'max',1,'sliderstep',[1/100,1],'Callback',{@sigma_sld_callback});
alpha_slider = uicontrol('style','slider','units','normalized','position',[0.92,0.05,0.04,0.95],'value',0.01,'min',0.01,'max',10,'sliderstep',[1/100,1],'Callback',{@alpha_sld_callback});
beta_slider = uicontrol('style','slider','units','normalized','position',[0.88,0.05,0.04,0.95],'value',0.1,'min',0,'max',5,'sliderstep',[1/100,1],'Callback',{@beta_sld_callback});

uicontrol('style','pushbutton','units','normalized','position',[0.1,0.9,0.15,0.05],'string','Apply to All','fontsize',12,'callback',@apply_to_all);

slider_one_value=1;
sigma_slider_value = 0.1;
alpha_slider_value = 0.01;
beta_slider_value = 0.1;



if length(data{slider_one_value}.image)>1
    slider_step_two=[1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.05,0,0.9,0.05],'value',1,'min',1,'max',length(data{slider_one_value}.image),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.image)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.image)-1),1/(length(data{slider_one_value}.image)-1)];
            slider_two.Max = length(data{slider_one_value}.image);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;
        apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)
    end

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);        
        apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)
    end

    function sigma_sld_callback(~,~,~)
        sigma_slider_value = sigma_slider.Value;
        alpha_slider_value = alpha_slider.Value;
        beta_slider_value = beta_slider.Value;
        apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)
    end

    function alpha_sld_callback(~,~,~)
        sigma_slider_value = sigma_slider.Value;
        alpha_slider_value = alpha_slider.Value;
        beta_slider_value = beta_slider.Value;
        apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)
    end

    function beta_sld_callback(~,~,~)
        sigma_slider_value = sigma_slider.Value;
        alpha_slider_value = alpha_slider.Value;
        beta_slider_value = beta_slider.Value;
        apply_filter(data{slider_one_value}.image{slider_two_value},sigma_slider_value,alpha_slider_value,beta_slider_value)
    end

    function apply_filter(data,sigma,alpha,beta)        
        data = locallapfilt(uint8(data),sigma,alpha,beta);     
        image_inside(data)
    end

    function image_inside(image)
        ax = gca; cla(ax);
        imagesc(image)
        axis off
        set(gca,'units','normalized','position',[0.15 0.18 0.7 0.7])
        colormap(gray)
        title(['sigma = ',num2str(sigma_slider_value),' beta = ',num2str(beta_slider_value),' alpha =', num2str(alpha_slider_value)])
    end

    function apply_to_all(~,~)       
        for i = 1:length(data)
            f = waitbar(0,'calculating');            
            for j = 1:length(data{i}.image)  
                waitbar(j/length(data{i}.image),f,'calculating')
                data{i}.image{j} = locallapfilt(uint8(data{i}.image{j}),sigma_slider_value,alpha_slider_value,beta_slider_value);
            end
            close(f)
        end
        image_plot(data)
    end
end