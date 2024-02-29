function table_data_plot(data,row_names,column_names,title)
figure('name',title,'NumberTitle','off','units','normalized','position',[0 0.1 1 0.4],'ToolBar','none','MenuBar', 'none');
column_width = {200};
uitable('Data',data,'units','normalized','position',[0 0 1 1],'FontSize',12,'RowName',row_names,'ColumnName',column_names,'columnwidth',column_width);

uimenu('Text','Send Data to Excel Sheet','ForegroundColor','b','CallBack',@save_data);
    function save_data(~,~,~)
        [file,path] = uiputfile('*.xlsx');
        if path~=0
            save_to = fullfile(path,file);            
            data_table = array2table(data);
            data_table.Properties.VariableNames = column_names;
            data_table.Properties.RowNames = row_names;
            writetable(data_table,save_to,'WriteRowNames',true);                 
        end
    end
end