function spt_jump_length_histogram(data)
input_values = inputdlg({'minimum number of jumps:','maximum displacement (um):','number of bins:'},'',1,{'4','3','100'});
if isempty(input_values)==1
    return
else    
    min_no_of_jumbs = str2double(input_values{1});    
    maximum_displacement = str2double(input_values{2});
    number_of_bins = str2double(input_values{3});
    for i=1:length(data)
        for j = 1:length(data{i}.tracks)
            displacement{j} = calculate_jump_length(data{i}.tracks{j},min_no_of_jumbs,maximum_displacement);
        end
        displacement = displacement(~cellfun('isempty',displacement));
        displacement = vertcat(displacement{:});
        displacement = sortrows(displacement);        
        displacement_unique = unique(displacement(:,1));         
        for j = 1:length(displacement_unique)
            wanted{j,1} = displacement(displacement(:,1) == displacement_unique(j),2); 
            wanted{j,2} = displacement_unique(j);
        end        
        clear displacement displacement_unique         
        data_to_send{i}.displacement = wanted;
        data_to_send{i}.name = data{i}.name;
        data_to_send{i}.type = 'spt_displacement';
        clear wantd
    end
    spt_displacement_histogrm_inside(data_to_send,number_of_bins)
end
end

function displacement = calculate_jump_length(data,min_no_of_jumps,max_displacement)
t = data(:,1);
x = data(:,2);
y = data(:,3);
[T1,T2] = meshgrid(t,t);
[x1,x2] = meshgrid(x,x);
[y1,y2] = meshgrid(y,y);

delays = round(abs(T1-T2),12);
delays = triu(delays,1);
delays = reshape(delays,[1 length(t)*length(t)]);

dr = sqrt((x1-x2).^2+(y1-y2).^2);
dr = triu(dr,1);
dr = reshape(dr,[1 length(t)*length(t)]);

delays_uique = unique(delays);
for i=1:length(delays_uique)    
    displacement{i}(:,2) = dr(delays == delays_uique(i))';
    displacement{i}(:,1) = delays_uique(i);
end
I = cellfun(@(x) size(x,1),displacement);
I = I>=min_no_of_jumps;
displacement = displacement(I);
displacement = vertcat(displacement{:});

if isempty(displacement)~=1
    I = displacement(:,1);
    I = I == 0;
    displacement(I,:) = [];
end

if isempty(displacement)~=1
    I = displacement(:,2);
    I = I>max_displacement;
    displacement(I,:) = [];
end

% for i = 1:size(data,1)-1
%     d(i,1) = pdist2(data(i,2:3),data(i+1,2:3));
% end
end

function spt_displacement_histogrm_inside(data,number_of_bins)
figure()
set(gcf,'name','Single Particle Displacements Histogram','NumberTitle','off','color','w','units','normalized','position',[0.3 0.1 0.4 0.7],'menubar','none','toolbar','figure');

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;

if length(data{slider_one_value}.displacement)>1
    slider_step_two=[1/(length(data{slider_one_value}.displacement)-1),1];
    slider_two = uicontrol('style','slider','units','normalized','position',[0.02,0,0.02,1],'value',1,'min',1,'max',length(data{slider_one_value}.displacement),'sliderstep',slider_step_two,'Callback',{@sld_two_callback});
end
slider_two_value=1;

spt_displacement_histogram_inside(data,slider_one_value,slider_two_value,number_of_bins)
uimenu('Text','k-on k-off','ForegroundColor','k','CallBack',@k_on_k_off_callback);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        if length(data{slider_one_value}.displacement)>1
            slider_two.SliderStep = [1/(length(data{slider_one_value}.displacement)-1),1];
            slider_two.Max = length(data{slider_one_value}.displacement);
            slider_two.Min = 1;
            slider_two.Value = 1;
        end
        slider_two_value = 1;        
        spt_displacement_histogram_inside(data,slider_one_value,slider_two_value,number_of_bins)
    end   

    function sld_two_callback(~,~,~)
        slider_two_value = round(slider_two.Value);
        spt_displacement_histogram_inside(data,slider_one_value,slider_two_value,number_of_bins)
    end

    function spt_displacement_histogram_inside(data,slider_one_value,slider_two_value,number_of_bins)
        input_data = data{slider_one_value}.displacement;
        if isempty(input_data)~=1
            name = data{slider_one_value}.name;
            
            subplot(2,1,1)
            ax = gca; cla(ax);
            data_to_plot = data{slider_one_value}.displacement{slider_two_value,1};
            [counts,centers] = hist(data_to_plot,number_of_bins);
            counts = counts./trapz(centers,counts);
            bar(centers,counts);            
            %histogram(data_to_plot,number_of_bins,'facecolor','b')
            title({'',['file name: ',regexprep(name,'_',' ')],['Delay = ',num2str(data{slider_one_value}.displacement{slider_two_value,2})],['Total Number of Jumps = ',num2str(length(data{slider_one_value}.displacement{slider_two_value,1}))]},'interpreter','latex','fontsize',14)
            set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
            xlabel('Displacement','interpreter','latex','FontSize',14)
            ylabel('PDF (Counts)','interpreter','latex','FontSize',14)
            
            subplot(2,1,2)
            ecdf(data_to_plot)
            set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
            xlabel('Displacement','interpreter','latex','FontSize',14)
            ylabel('CDF','interpreter','latex','FontSize',14)
        end
    end

    function k_on_k_off_callback(~,~,~)
        pdf = data{slider_one_value}.displacement{slider_two_value,1};
        cdf = ecdf(pdf);
        k_on_k_off(pdf,cdf);        
    end
end