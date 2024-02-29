function loc_list_clusters_remove_outliers_updated(data)
%-------------------------------------------------------------------------
f = waitbar(0,'Exracting Clusters from Image(s)...');
for k = 1:length(data)
    clusters{k} = loc_list_extract_clusters_from_data(data{k}); 
    names{k} = data{k}.name;
    waitbar(k/length(data),f,'Exracting Clusters from Image(s)...');
end
I = cellfun(@(x) length(x)>1,clusters);
clusters = clusters(I);
names = names(I);
close(f)

if isempty(clusters)~=1
    for k = 1:length(clusters)
        for n = 1:length(clusters{k})
            areas{k}(n) = clusters{k}{n}(1,3);
            no_of_locs{k}(n) = size(clusters{k}{n},1);
        end        
    end    
end
%-------------------------------------------------------------------------
if isempty(clusters)~=1    
    figure()
    set(gcf,'name','Clusters Remove Outlier','NumberTitle','off','color','w','units','normalized','position',[0.1 0.2 0.8 0.6],'menubar','none','toolbar','figure');
    uicontrol('style','text','units','normalized','position',[0,-0.01,0.3,0.05],'string','No. of Bins:','BackgroundColor','w','FontSize',14);
    no_of_bins_edit = uicontrol('style','edit','units','normalized','position',[0.3,0,0.2,0.04],'string','100','Callback',@number_of_bins_callback,'FontSize',14);
    no_of_bins =  str2double(no_of_bins_edit.String);
    
    uimenu('Text','Gaussian Fit','ForegroundColor','b','CallBack',@gaussian_fit);
    uimenu('Text','Log-Normal Fit','ForegroundColor','b','CallBack',@log_normal_fit);
    
    if length(clusters)>1
        slider_step=[1/(length(clusters)-1),1/(length(clusters)-1)];
        slider = uicontrol('style','slider','units','normalized','position',[0,0,0.03,1],'value',1,'min',1,'max',length(clusters),'sliderstep',slider_step,'Callback',{@sld_callback});
    end
    slider_value=1;
    [centers,counts,ratio] = extract_histogram_data(no_of_locs,areas,no_of_bins);
    plot_inside(centers,counts,no_of_locs,areas,names,slider_value);      
end

    function number_of_bins_callback(~,~,~)
        no_of_bins =  str2double(no_of_bins_edit.String);        
        [centers,counts,ratio] = extract_histogram_data(no_of_locs,areas,no_of_bins);
        plot_inside(centers,counts,no_of_locs,areas,names,slider_value);         
    end

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);        
        plot_inside(centers,counts,no_of_locs,areas,names,slider_value);          
    end

    function [centers,counts,ratio] = extract_histogram_data(no_of_locs,areas,no_of_bins)
        for i = 1:length(no_of_locs)
            ratio{i} = log10(no_of_locs{i}./areas{i});
            ratio{i} = ratio{i} + abs(min(ratio{i}))+0.1;
            [counts{i},centers{i}] = hist(ratio{i}',no_of_bins);
        end
    end

    function plot_inside(centers,counts,no_of_locs,areas,names,slider_value)
        subplot(1,2,1)
        ax = gca; cla(ax);
        plot(centers{slider_value},counts{slider_value},'color','k')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
        title({'',regexprep(names{slider_value},'_',' '),['File Number = ',num2str(slider_value),'/',num2str(length(centers))]},'interpreter','latex','fontsize',16)
        
        subplot(1,2,2)
        ax = gca; cla(ax);
        scatter(no_of_locs{slider_value},areas{slider_value},5,'b','filled')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        xlabel('Clusters No. of Locs','interpreter','latex','fontsize',16)
        ylabel('Clusters Area','interpreter','latex','fontsize',16)
        box on
    end

    function gaussian_fit(~,~,~)
        answer = inputdlg({'Sigma:'},'Input',[1 50],{'2'});
        if isempty(answer)~=1
            sigma = str2double(answer{1});            
            f = waitbar(0,'Please Wait...');
            for i = 1:length(clusters)
                fit_results{i} = fit_inside(centers{i},ratio{i},sigma,'normal');
                waitbar(i/length(clusters),f,'Please Wait...');
            end
            close(f);
            plot_fit_results(clusters,centers,counts,no_of_locs,areas,names,fit_results,sigma)            
        end
    end

    function log_normal_fit(~,~,~)
        answer = inputdlg({'Sigma:'},'Input',[1 50],{'2'});
        if isempty(answer)~=1
            sigma = str2double(answer{1});
            f = waitbar(0,'Please Wait...');
            for i = 1:length(clusters)                             
                fit_results{i} = fit_inside(centers{i},ratio{i},sigma,'lognormal');
                waitbar(i/length(clusters),f,'Please Wait...');
            end
            close(f)
            plot_fit_results(clusters,centers,counts,no_of_locs,areas,names,fit_results,sigma) 
        end
    end
end

function fit_results = fit_inside(centers,ratio,sigma_to,method)
if isempty(centers)~=1
    if isequal(method,'normal')
        fit_to_hist = fitdist(ratio','Normal');
        mu = fit_to_hist.mu;
        sigma = fit_to_hist.sigma;
        range(1) = min(centers)-0.1;
        range(2) = mu+sigma_to*sigma;    
    elseif isequal(method,'lognormal')
        fit_to_hist = fitdist(ratio','Lognormal');
        mu_fit = fit_to_hist.mu;
        mu = exp(mu_fit);
        sigma = fit_to_hist.sigma;        
        range(1) = min(centers)-0.1;
        range(2) = exp(mu_fit+sigma_to*sigma);        
    end    
    
    centers_interp = linspace(min(centers),max(centers),5000);
    fit_to_hist = pdf(fit_to_hist,centers_interp);        
    
    idx = ratio>=range(1) & ratio<=range(2);    
    
    fit_results.idx = idx;
    fit_results.mu = mu;
    fit_results.range = range;
    fit_results.centers_interp = centers_interp;
    fit_results.fit_to_hist = fit_to_hist;
else
    fit_results = [];
end
end

function plot_fit_results(clusters,centers,counts,no_of_locs,areas,names,fit_results,sigma) 
figure()
set(gcf,'name','Outlier Removal','NumberTitle','off','color','w','units','normalized','position',[0.05 0.2 0.9 0.5],'menubar','none','toolbar','figure');

if length(clusters)>1
    slider_step=[1/(length(clusters)-1),1];
    slider = uicontrol('style','slider','units','normalized','position',[0,0,0.02,1],'value',1,'min',1,'max',length(clusters),'sliderstep',slider_step,'Callback',{@sld_callback});
end
slider_value=1;
plot_inside(centers,counts,no_of_locs,areas,names,fit_results,sigma,slider_value)  

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        plot_inside(centers,counts,no_of_locs,areas,names,fit_results,sigma,slider_value)
    end

    function plot_inside(centers,counts,no_of_locs,areas,names,fit_results,sigma_to,slider_value)       
        to_keep_data(:,1) = no_of_locs{slider_value}(fit_results{slider_value}.idx);
        to_keep_data(:,2) = areas{slider_value}(fit_results{slider_value}.idx);
        
        removed_data(:,1) = no_of_locs{slider_value}(~fit_results{slider_value}.idx);
        removed_data(:,2) = areas{slider_value}(~fit_results{slider_value}.idx);  
        
        subplot(1,2,1)
        ax = gca; cla(ax);
        plot(centers{slider_value},counts{slider_value}/max(counts{slider_value}),'color','k','linewidth',1.5)
        hold on
        plot(fit_results{slider_value}.centers_interp,fit_results{slider_value}.fit_to_hist/max(fit_results{slider_value}.fit_to_hist),'color','m','linewidth',1.5)
        
        pgon = polyshape([0 fit_results{slider_value}.range(2) fit_results{slider_value}.range(2) 0],[0 0 1 1]);
        plot(pgon,'facecolor','b','facealpha',0.3,'edgecolor','none');
        line([fit_results{slider_value}.mu fit_results{slider_value}.mu],[0 1],'color','k','linewidth',1.5)     
        text(fit_results{slider_value}.mu,0.9,['$\mu = $',num2str(fit_results{slider_value}.mu)],'interpreter','latex','fontsize',16)
        
        pgon = polyshape([fit_results{slider_value}.range(2) max(centers{slider_value}) max(centers{slider_value}) fit_results{slider_value}.range(2)],[0 0 1 1]);
        plot(pgon,'facecolor','r','facealpha',0.3,'edgecolor','none');
        line([fit_results{slider_value}.range(2) fit_results{slider_value}.range(2)],[0 1],'color','r','linewidth',1.5)        
        text(fit_results{slider_value}.range(2),0.9,['$\mu + $',num2str(sigma_to),'$\sigma$'],'interpreter','latex','fontsize',16)       
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        xlim([min(centers{slider_value}) max(centers{slider_value})])
        ylim([0 1])
        box on
        title({'',regexprep(names{slider_value},'_',' '),['File Number = ',num2str(slider_value),'/',num2str(length(centers))]},'interpreter','latex','fontsize',16)
        
        subplot(1,2,2)
        ax = gca; cla(ax);
        scatter(to_keep_data(:,1),to_keep_data(:,2),10,'b','filled')
        hold on
        scatter(removed_data(:,1),removed_data(:,2),10,'r','filled')
        title(regexprep(names{slider_value},'_',' '),'interpreter','latex','fontsize',18)
        xlabel('Clusters No. of Locs','interpreter','latex','fontsize',18)
        ylabel('Clusters Area','interpreter','latex','fontsize',18)
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex')
        box on
    end

uicontrol('style','pushbutton','units','normalized','position',[0.02,0,0.08,0.06],'string','Filtered Data','Callback',@extract_filtered_data,'FontSize',14);
uicontrol('style','pushbutton','units','normalized','position',[0.1,0,0.08,0.06],'string','Noise Data','Callback',@extract_noise_data,'FontSize',14);

    function extract_filtered_data(~,~,~)
        for i = 1:length(clusters)
            clusters_filtered = clusters{i}(fit_results{i}.idx);
            clusters_filtered = vertcat(clusters_filtered{:});
            try
                data_filtered{i}.x_data = clusters_filtered(:,1);
                data_filtered{i}.y_data = clusters_filtered(:,2);
                data_filtered{i}.area = clusters_filtered(:,3);
                data_filtered{i}.type = 'loc_list';
                data_filtered{i}.name = [names{i},'_filtered'];
            catch
                data_filtered{i} = [];
            end
            clear clusters_filtered
        end
        loc_list_plot(data_filtered)
    end

    function extract_noise_data(~,~,~)
        for i = 1:length(clusters)
            clusters_noise = clusters{i}(~fit_results{i}.idx);
            clusters_noise = vertcat(clusters_noise{:});
            try
                data_noise{i}.x_data = clusters_noise(:,1);
                data_noise{i}.y_data = clusters_noise(:,2);
                data_noise{i}.area = clusters_noise(:,3);
                data_noise{i}.type = 'loc_list';
                data_noise{i}.name = [names{i},'_removed_locs'];
            catch
                data_noise{i} = [];
            end
            clear clusters_filtered
        end
        loc_list_plot(data_noise)
    end
end