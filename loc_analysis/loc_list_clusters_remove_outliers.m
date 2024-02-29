function loc_list_clusters_remove_outliers(data)
figure()
set(gcf,'name','Clusters Remove Outlier','NumberTitle','off','color','w','units','normalized','position',[0.15 0.2 0.7 0.6],'menubar','none','toolbar','figure');
uicontrol('style','text','units','normalized','position',[0,-0.01,0.3,0.05],'string','No. of Bins:','BackgroundColor','w','FontSize',14);
no_of_bins_edit = uicontrol('style','edit','units','normalized','position',[0.3,0,0.2,0.04],'string','100','Callback',@number_of_bins_callback,'FontSize',14);
no_of_bins =  str2double(no_of_bins_edit.String);

uimenu('Text','Gaussian Fit','ForegroundColor','b','CallBack',@gaussian_fit);
uimenu('Text','Log-Normal Fit','ForegroundColor','b','CallBack',@log_normal_fit);

if length(data)>1
    slider_step=[1/(length(data)-1),1/(length(data)-1)];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
if isempty(data{slider_value})~=1
    plot_inside(data{slider_value},slider_value,length(data),no_of_bins);
end

    function number_of_bins_callback(~,~,~)
        no_of_bins =  str2double(no_of_bins_edit.String);
        if isempty(data{slider_value})~=1
            plot_inside(data{slider_value},slider_value,length(data),no_of_bins);
        end
    end

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        if isempty(data{slider_value})~=1
            plot_inside(data{slider_value},slider_value,length(data),no_of_bins);
        end
    end

    function gaussian_fit(~,~,~)
        answer = inputdlg({'Sigma:'},'Input',[1 50],{'2'});
        if isempty(answer)~=1
            sigma = str2double(answer{1});
            for i = 1:length(data)
                [clusters,ratio,centers,count,data_to_process,name] = plot_inside(data{i},i,length(data),no_of_bins);
                [data_filtered{i},data_removed{i},results{i}] = gaussian_fit_inside(clusters,ratio,centers,count,data_to_process,name,sigma);
                clear clusters ratio centers count                
            end           
            data_filtered = data_filtered(~cellfun('isempty',data_filtered));
            data_removed = data_removed(~cellfun('isempty',data_removed));
            results = results(~cellfun('isempty',results));
            loc_list_plot(data_filtered);
            loc_list_plot(data_removed);
            plot_results_gaussian(results);            
        end
    end

    function log_normal_fit(~,~,~)
        answer = inputdlg({'Sigma:'},'Input',[1 50],{'5 2'});
        if isempty(answer)~=1
            sigma = str2num(answer{1});
            for i = 1:length(data)
                [clusters,ratio,centers,count,data_to_process,name] = extract_data_to_fit_information(data{i},no_of_bins);
                %[clusters,ratio,centers,count,data_to_process,name] = plot_inside(data{i},i,length(data),no_of_bins);
                [data_filtered{i},data_removed{i},results{i}] = log_normal_fit_inside(clusters,ratio,centers,count,data_to_process,name,sigma);
                clear clusters ratio centers count
            end
            data_filtered = data_filtered(~cellfun('isempty',data_filtered));
            data_removed = data_removed(~cellfun('isempty',data_removed));
            results = results(~cellfun('isempty',results));
            loc_list_plot(data_filtered);
            loc_list_plot(data_removed);
            plot_results_log_normal(results);
        end
    end
end

function [clusters,ratio,centers,count,data_to_process,name] = extract_data_to_fit_information(data,no_of_bins)
clusters = loc_list_extract_clusters_from_data(data);
if length(clusters)>1
    for i = 1:length(clusters)
        areas(i) = clusters{i}(1,3);
        no_of_locs(i) = size(clusters{i},1);
    end
    data_to_process(:,1) = no_of_locs;
    data_to_process(:,2) = areas;
    ratio = log10(data_to_process(:,1)./data_to_process(:,2));    
    
    ratio = ratio + abs(min(ratio))+0.1;
    
    [count,centers] = hist(ratio',no_of_bins);    
    
    name = data.name;
end
end

function [clusters,ratio,centers,count,data_to_process,name] = plot_inside(data,n,N,no_of_bins)
clusters = loc_list_extract_clusters_from_data(data);
if length(clusters)>1
    for i = 1:length(clusters)
        areas(i) = clusters{i}(1,3);
        no_of_locs(i) = size(clusters{i},1);
    end
    data_to_process(:,1) = no_of_locs;
    data_to_process(:,2) = areas;
    ratio = log10(data_to_process(:,1)./data_to_process(:,2));    
    
    ratio = ratio + abs(min(ratio))+0.1;
    
    [count,centers] = hist(ratio',no_of_bins);    
    
    name = data.name;
    
    subplot(1,2,1)
    ax = gca; cla(ax);
    plot(centers,count,'color','k')
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    box on
    title({'',regexprep(name,'_',' '),['File Number = ',num2str(n),'/',num2str(N)]},'interpreter','latex','fontsize',16)
    
    subplot(1,2,2)
    ax = gca; cla(ax);
    scatter(no_of_locs,areas,5,'b','filled')
    set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
    xlabel('Clusters No. of Locs','interpreter','latex','fontsize',16)
    ylabel('Clusters Area','interpreter','latex','fontsize',16)
    box on    
else
    clusters = []; ratio = []; centers = []; count = []; data_to_process = []; name = data.name;
    subplot(1,2,1)    
    ax = gca; cla(ax);    
    title({'',regexprep(data.name,'_',' '),['File Number = ',num2str(n),'/',num2str(N)],'','','','','','There is Only One Cluster!'},'interpreter','latex','fontsize',16)
    axis off
    subplot(1,2,2)
    ax = gca; cla(ax);
    delete(ax);       
end
end

function plot_results_gaussian(data)
figure()
set(gcf,'name','Outlier Removal','NumberTitle','off','color','w','units','normalized','position',[0.05 0.2 0.9 0.5],'menubar','none','toolbar','figure');

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
plot_inside(data{slider_value})

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        if isempty(data{slider_value})~=1
            plot_inside(data{slider_value})
        end
    end

    function plot_inside(data)
        to_keep_data = data.to_keep_data;
        removed_data = data.removed_data;
        count = data.count;
        centers = data.centers;
        mu = data.mu;
        sigma = data.sigma;
        centers_interp = data.centers_interp;
        fit_to_hist = data.fit_to_hist;
        sigma_to = data.sigma_to;
        name = data.name;
        
        subplot(1,2,1)
        ax = gca; cla(ax);
        plot(centers,count/max(count),'color','k','linewidth',1.5)
        hold on
        plot(centers_interp,fit_to_hist/max(fit_to_hist),'color','b','linewidth',1.5)
        line([mu+sigma_to*sigma mu+sigma_to*sigma],[0 1],'color','r','linewidth',1.5)
        line([mu-sigma_to*sigma mu-sigma_to*sigma],[0 1],'color','r','linewidth',1.5)
        line([mu mu],[0 1],'color','k','linewidth',1.5)
        text(mu,0.9,['$\mu = $',num2str(mu)],'interpreter','latex','fontsize',16)
        text(mu+sigma_to*sigma,0.9,['$\mu + $',num2str(sigma_to),'$\sigma$'],'interpreter','latex','fontsize',16)
        text(mu-sigma_to*sigma,0.9,['$\mu - $',num2str(sigma_to),'$\sigma$'],'interpreter','latex','fontsize',16)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        
        subplot(1,2,2)
        ax = gca; cla(ax);
        scatter(to_keep_data(:,1),to_keep_data(:,2),10,'b','filled')
        hold on
        scatter(removed_data(:,1),removed_data(:,2),10,'r','filled')
        title(regexprep(name,'_',' '),'interpreter','latex','fontsize',18)
        xlabel('Clusters No. of Locs','interpreter','latex','fontsize',18)
        ylabel('Clusters Area','interpreter','latex','fontsize',18)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
    end
end

function plot_results_log_normal(data)
figure()
set(gcf,'name','Outlier Removal','NumberTitle','off','color','w','units','normalized','position',[0.05 0.2 0.9 0.5],'menubar','none','toolbar','figure');

if length(data)>1
    slider_step=[1/(length(data)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
plot_inside(data{slider_value})

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        if isempty(data{slider_value})~=1
            plot_inside(data{slider_value})
        end
    end

    function plot_inside(data)
        to_keep_data = data.to_keep_data;
        removed_data = data.removed_data;
        count = data.count;
        centers = data.centers;
        mu = data.mu; 
        centers_interp = data.centers_interp;
        fit_to_hist = data.fit_to_hist;       
        name = data.name;
        range = data.range;
        sigma = data.sigma;
        
        subplot(1,2,1)
        ax = gca; cla(ax);
        plot(centers,count/max(count),'color','k','linewidth',1.5)
        hold on
        plot(centers_interp,fit_to_hist/max(fit_to_hist),'color','b','linewidth',1.5)
        line([range(2) range(2)],[0 1],'color','r','linewidth',1.5)
        line([range(1) range(1)],[0 1],'color','r','linewidth',1.5)
        line([mu mu],[0 1],'color','k','linewidth',1.5)
        text(mu,0.9,'$\mu $','interpreter','latex','fontsize',16)
        text(range(2),0.9,['$\mu + $',num2str(sigma(2)),'$\sigma$'],'interpreter','latex','fontsize',16)  
        text(range(1),0.9,['$\mu - $',num2str(sigma(1)),'$\sigma$'],'interpreter','latex','fontsize',16)        
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        
        subplot(1,2,2)
        ax = gca; cla(ax);
        scatter(to_keep_data(:,1),to_keep_data(:,2),10,'b','filled')
        hold on
        scatter(removed_data(:,1),removed_data(:,2),10,'r','filled')
        title(regexprep(name,'_',' '),'interpreter','latex','fontsize',18)
        xlabel('Clusters No. of Locs','interpreter','latex','fontsize',18)
        ylabel('Clusters Area','interpreter','latex','fontsize',18)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
    end
end

function [data_filtered,data_removed,results] = gaussian_fit_inside(clusters,ratio,centers,count,data_to_process,name,sigma_to)
if length(clusters)>1
    fit_to_hist = fitdist(ratio,'Normal');
    centers_interp = linspace(min(centers),max(centers),5000);
    fit_to_hist = pdf(fit_to_hist,centers_interp);
    
    [~,mu_I] = max(fit_to_hist);
    mu = centers_interp(mu_I);
    [~,sigma_I] = min(abs(fit_to_hist-(exp(1)^(-0.5))*max(fit_to_hist)));
    sigma = abs(mu-centers_interp(sigma_I));
    to_keep_data_idx = ratio<mu+sigma_to*sigma & ratio>mu-sigma_to*sigma;
    
      
    clusters_filtered = clusters(to_keep_data_idx);
    clusters_filtered = vertcat(clusters_filtered{:});
    try
        data_filtered.x_data = clusters_filtered(:,1);
        data_filtered.y_data = clusters_filtered(:,2);
        data_filtered.area = clusters_filtered(:,3);
        data_filtered.type = 'loc_list';
        data_filtered.name = [name,'_filtered'];
    catch
        data_filtered = [];
    end
    
    clusters_removed = clusters(~to_keep_data_idx);
    clusters_removed = vertcat(clusters_removed{:});
    try
        data_removed.x_data = clusters_removed(:,1);
        data_removed.y_data = clusters_removed(:,2);
        data_removed.area = clusters_removed(:,3);
        data_removed.type = 'loc_list';
        data_removed.name = [name,'_removed_locs'];
    catch
        data_removed = [];
    end
    
    results.to_keep_data = data_to_process(to_keep_data_idx,:);
    results.removed_data = data_to_process(~to_keep_data_idx,:);
    results.count = count;
    results.centers = centers;
    results.mu = mu;
    results.sigma = sigma;
    results.name = name;
    results.centers_interp = centers_interp;
    results.fit_to_hist = fit_to_hist;
    results.sigma_to = sigma_to;
else
    data_removed = [];
    data_filtered = [];
    results = [];
end
end

function [data_filtered,data_removed,results] = log_normal_fit_inside(clusters,ratio,x,y,data_to_process,name,sigma)
if length(clusters)>1
    y_fit = fitdist(ratio,'Lognormal'); 
    
    mu_fit = y_fit.mu;
    sigma_fit = y_fit.sigma;  

    x_interp = linspace(min(x),max(x),5000);
    y_fit = pdf(y_fit,x_interp);

    mu = exp(mu_fit);
    
    to_keep_data_idx = ratio>exp(mu_fit-sigma(1)*sigma_fit) & ratio<exp(mu_fit+sigma(2)*sigma_fit);   
    range(1) = exp(mu_fit-sigma(1)*sigma_fit);
    range(2) = exp(mu_fit+sigma(2)*sigma_fit);
    
    clusters_filtered = clusters(to_keep_data_idx);
    clusters_filtered = vertcat(clusters_filtered{:});
    try
        data_filtered.x_data = clusters_filtered(:,1);
        data_filtered.y_data = clusters_filtered(:,2);
        data_filtered.area = clusters_filtered(:,3);
        data_filtered.type = 'loc_list';
        data_filtered.name = [name,'_filtered'];
    catch
        data_filtered = [];
    end
    
    clusters_removed = clusters(~to_keep_data_idx);
    clusters_removed = vertcat(clusters_removed{:});
    try
        data_removed.x_data = clusters_removed(:,1);
        data_removed.y_data = clusters_removed(:,2);
        data_removed.area = clusters_removed(:,3);
        data_removed.type = 'loc_list';
        data_removed.name = [name,'_removed_locs'];
    catch
        data_removed  = [];
    end
    
    results.to_keep_data = data_to_process(to_keep_data_idx,:);
    results.removed_data = data_to_process(~to_keep_data_idx,:);
    results.count = y;
    results.centers = x;
    results.mu = mu;
    results.range =  range;
    results.name = name;
    results.centers_interp = x_interp;
    results.fit_to_hist = y_fit;
    results.sigma = sigma;
else
    data_removed = [];
    data_filtered = [];
    results = [];
end
end