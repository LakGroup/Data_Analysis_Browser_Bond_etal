function loc_list_change_colormap_limits()
ax = gca;
c_lim = ax.CLim;
input_values = inputdlg({'c-min:','c-max:'},'',1,{num2str(c_lim(1)),num2str(c_lim(2))});
if isempty(input_values)==1
    return
else
    clim(1)=str2double(input_values{1});
    clim(2)=str2double(input_values{2});
    caxis(clim);
end
end