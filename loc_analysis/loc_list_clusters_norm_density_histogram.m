function loc_list_clusters_norm_density_histogram(data)
input_values = inputdlg({'Percentile:'},'',1,{'0 95'});
if isempty(input_values)==1
    return
else
    percentile =str2num(input_values{1});
    counter = 0;
    for i = 1:length(data)
        data_to = unique(data{i}.area);
        if length(data_to)>1
            counter = counter+1;
            data_to_send{counter} = data{i};
        end        
    end
    if exist('data_to_send','var')
        for i = 1:length(data_to_send)
            [no_of_locs, cluster_area] = hist(data_to_send{i}.area,unique(data_to_send{i}.area));
            temp = no_of_locs'./cluster_area;
            [x_pdf{i},y_pdf{i},x_cdf{i},y_cdf{i}] = calculate_pdf_cdf_norm(temp,percentile);          
            names{i} = data{i}.name;  
            clear no_of_locs cluster_area temp
        end        
        plot_histogram(x_pdf,y_pdf,x_cdf,y_cdf,names,'Norm Density',percentile)
    else
        msgbox('there is only one cluster')
    end
end
end