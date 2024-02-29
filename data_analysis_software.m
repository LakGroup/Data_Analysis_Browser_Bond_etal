function data_analysis_software()
clear global;clear;clc;
warning off
addpath(strcat(pwd,'\load_files'))
addpath(strcat(pwd,'\load_files\tiff'))
addpath(strcat(pwd,'\load_files\storm'))
addpath(strcat(pwd,'\load_files\tracks'))
addpath(strcat(pwd,'\load_files\image'))
addpath(strcat(pwd,'\loc_analysis'))
addpath(strcat(pwd,'\loc_analysis\voronoi_segmentation'))
addpath(strcat(pwd,'\loc_analysis\voronoi_segmentation\extra'))
addpath(strcat(pwd,'\single_particle_tracking'))
addpath(strcat(pwd,'\single_particle_tracking\SpotOn'))
addpath(strcat(pwd,'\shape_classification'))
addpath(strcat(pwd,'\shape_classification\iterative_clustering'))
addpath(strcat(pwd,'\simulations'))
addpath(strcat(pwd,'\general'))
addpath(strcat(pwd,'\image_analysis'))

figure('CloseRequestFcn',@my_closereq)
set(gcf,'name','Data Analysis SOFTWARE','NumberTitle','off','color','w','units','normalized','position',[0.35 0.25 0.3 0.6],'menubar','none')

    function my_closereq(~,~)
        selection = questdlg('Close the Software?','Exit Callback','Yes','No','Yes');
        switch selection
            case 'Yes'
                delete(gcf)
            case 'No'
                return
        end
    end

global listbox data map color_map
map = colormap(parula); 
color_map = colormap(gray);
listbox = uicontrol('style','listbox','units','normalized','position',[0,0.05,1,0.90],'string','NaN','ForegroundColor','b','backgroundcolor','w','Callback',{@listbox_callback},'Max',100,'FontSize',12,'ButtonDownFcn',@right_click_listbox);
uicontrol('style','text','units','normalized','position',[0,0,0.15,0.05],'string','File Type:','BackgroundColor','w','Fontsize',12);
file_type = uicontrol('style','text','units','normalized','position',[0.15,0,0.3,0.05],'string','NaN','BackgroundColor','w','Fontsize',12);
uicontrol('style','text','units','normalized','position',[0.45,0,0.2,0.05],'string','File Size (MB):','BackgroundColor','w','Fontsize',12);
file_size = uicontrol('style','text','units','normalized','position',[0.65,0,0.3,0.05],'string','NaN','BackgroundColor','w','Fontsize',12);

uicontrol('style','pushbutton','units','normalized','position',[0.7,0.95,0.1,0.05],'string','Plot','BackgroundColor','w','Fontsize',12,'callback',@plot_callback);
uicontrol('style','pushbutton','units','normalized','position',[0.8,0.95,0.1,0.05],'string','Down','BackgroundColor','w','Fontsize',12,'callback',@move_down);
uicontrol('style','pushbutton','units','normalized','position',[0.9,0.95,0.1,0.05],'string','Up','BackgroundColor','w','Fontsize',12,'callback',@move_up);

set_calss_number = uicontrol('style','pushbutton','units','normalized','position',[-0.5,0.95,0.3,0.05],'string','Set Class Color','BackgroundColor','w','Fontsize',12,'callback',@set_class_color_callback);
merge_shapes = uicontrol('style','pushbutton','units','normalized','position',[-0.5,0.95,0.2,0.05],'string','Merge Shapes','BackgroundColor','w','Fontsize',12,'callback',@merge_shapes_callback);

    function listbox_callback(~,~,~)
        listbox = set_listbox_names(listbox);
        file_type = set_file_type(listbox,file_type);
        file_size = set_file_size(listbox,file_size);
        if isempty(data)~=1
            [same_type_file,type_file] = same_type(listbox);
            if same_type_file==1
                if isequal(type_file,'shape_class')
                    set_calss_number.Position = [0,0.95,0.3,0.05];
                    merge_shapes.Position = [0.3,0.95,0.2,0.05];
                else
                    set_calss_number.Position = [-0.5,0.95,0.3,0.05];
                    merge_shapes.Position = [-0.5,0.95,0.2,0.05];
                end
            end
        end        
    end

    function right_click_listbox(src, ~)
        figHandle = ancestor(src, 'figure');
        clickType = get(figHandle, 'SelectionType');
        if strcmp(clickType, 'alt')            
        end
    end

    function set_class_color_callback(~,~,~)
        listbox_value = listbox.Value;
        data(listbox_value) = shape_classification_set_class_color(data(listbox_value));        
    end

    function merge_shapes_callback(~,~,~)
        listbox_value = listbox.Value;
        shape_classification_merge_shape_classes(data(listbox_value));     
    end

%---------------------file_menu---------------------
file_menu = uimenu('Text','File');

load_data_menu = uimenu(file_menu,'Text','Load Data');

uimenu(load_data_menu,'Text','STORM tiff Image','Callback',{@load_stack_tiff_STORM_callback});

uimenu(load_data_menu,'Text','Image','Callback',{@load_image_callback});

uimenu(load_data_menu,'Text','STORM Microscopy','Callback',{@load_microscopy_callback});

stp_menu = uimenu(load_data_menu,'Text','Single Particle Tracks Data');
uimenu(stp_menu,'Text','XML File(s)','Callback',@load_XML_callback);
uimenu(stp_menu,'Text','SpotOn .mat File(s)','Callback',@load_SpotOn_callback);

uimenu(file_menu,'Text','Load Session','Callback',{@load_session});
uimenu(file_menu,'Text','Save Session','Callback',{@save_session});

    function load_stack_tiff_STORM_callback(~,~,~)                
        data_load = load_stack_tiff_file_STORM();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);        
    end

    function load_image_callback(~,~,~)                
        data_load = load_image();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);        
    end

    function load_microscopy_callback(~,~,~)                
        data_load = load_microscopy_file;
        data = set_global_data(data,data_load);      
        listbox = set_listbox_names(listbox);        
    end

    function load_XML_callback(~,~,~)                
        data_load = load_XML();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);        
    end

    function load_SpotOn_callback(~,~,~)                
        data_load = load_SpotOn();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);        
    end

    function save_session(~,~,~)
        if isempty(data)
            msgbox('List is empty')
            return
        else
            [file,path] = uiputfile('.mat','Save Session');
            if isequal(file,0)
                return
            else                
                f = waitbar(0,'Saving, Please Wait...');                
                save(fullfile(path,file),'data','-v7.3')
                waitbar(1,f,'Saving, Please Wait...')
                close(f)
            end
        end
    end

    function load_session(~,~,~)
        [file_name,path] = uigetfile('*.mat','Select Session','MultiSelect','on');
        if isequal(file_name,0)
            return            
        else
            file_name = cellstr(file_name);
            f = waitbar(0,'Loading...');
            for i = 1:length(file_name)
                waitbar(i/length(file_name),f,['Loading...',num2str(i),'/',num2str(length(file_name))])  
                try
                    data_load{i} = load(fullfile(path,file_name{i})); 
                    data_load{i} = data_load{i}.data;
                catch
                    data_load{i} = [];
                end
            end
            close(f)
            data_load = data_load(~cellfun('isempty',data_load));
            data_load = horzcat(data_load{:});
            if ~isrow(data_load)
                data_load = data_load';
            end
            if ~isrow(data)
                data = data';
            end
            data = set_global_data(data,data_load);
        end
        listbox = set_listbox_names(listbox);
        listbox.Value = 1;
    end
%---------------------file_menu---------------------
%---------------------edit menu---------------------
edit_menu = uimenu('Text','Edit');
uimenu(edit_menu,'Text','Delete File(s)','Callback',{@delete_callback});
uimenu(edit_menu,'Text','Rename File(s)','Callback',{@rename_callback});
uimenu(edit_menu,'Text','Rename File(s) Counter','Callback',{@rename_counter_callback});
uimenu(edit_menu,'Text','Prefix File(s)','Callback',{@prefix_counter_callback});

    function delete_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            choice = questdlg('Are you sure you want to delete the selected files','Close','Yes','No','Yes');
            switch choice
                case 'Yes'
                    data(listbox_value) = [];
                    data = data(~cellfun('isempty',data));
                case 'No'
                    return
            end
        end
        listbox = set_listbox_names(listbox);        
        listbox.Value = 1;        
    end

    function rename_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            input_values = inputdlg('chnage name(s) to:','',1,{data{listbox_value(1)}.name});
            if isempty(input_values)==1
                return
            else
                new_name = input_values{1};
                for i=1:length(listbox_value)
                    data{listbox_value(i)}.name = new_name;
                end
            end
        end
        listbox = set_listbox_names(listbox);        
    end

    function rename_counter_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            input_values = inputdlg('change name(s) to:','',1,{data{listbox_value(1)}.name});
            if isempty(input_values)==1
                return
            else
                new_name = input_values{1};
                for i=1:length(listbox_value)
                    data{listbox_value(i)}.name = [new_name,'_',num2str(i)];
                end
            end
        end
        listbox = set_listbox_names(listbox);
    end

    function prefix_counter_callback(~,~,~)
        listbox_value = listbox.Value;
        if isempty(data)
            msgbox('List is empty')
            return
        else
            input_values = inputdlg('Add prefix:','',1,{'None_'});
            if isempty(input_values)==1
                return
            else
                new_name = input_values{1};
                for i=1:length(listbox_value)
                    data{listbox_value(i)}.name = [new_name,data{listbox_value(i)}.name];
                end
            end
        end
        listbox = set_listbox_names(listbox);
    end
%---------------------edit menu---------------------
%---------------------modules menu------------------
modules_menu = uimenu('Text','Modules');
uimenu(modules_menu,'Text','Colocalization Module','Callback',{@coloc_module});
uimenu(modules_menu,'Text','Colocalization Module NEW','Callback',{@coloc_module_New});
uimenu(modules_menu,'Text','Colocalization Statistics Module','Callback',{@coloc_stat_module});
uimenu(modules_menu,'Text','Lysosome Mask Module','Callback',@LysosomeMask_module);
uimenu(modules_menu,'Text','Lysosome Mask Module - Batch','Callback',@LysosomeMask_module_batch);
uimenu(modules_menu,'Text','Lysosome Mask LAMTOR Module','Callback',@LysosomeMask_LAMTOR_module);
uimenu(modules_menu,'Text','Lysosome Mask LAMTOR Module - Batch','Callback',@LysosomeMask_module_LAMTOR_batch);
uimenu(modules_menu,'Text','Pattern Analysis Module','Callback',@Pattern_analysis_Module);
uimenu(modules_menu,'Text','Dual Colour Module','Callback',{@coloc_dualColour_Module});
uimenu(modules_menu,'Text','Dual Colour Module NEW','Callback',{@coloc_dualColour_Module2});
uimenu(modules_menu,'Text','Single Particle Tracks Tiff Image Overlay (Colocalization)','Callback',{@spt_layover_colocalization});
uimenu(modules_menu,'Text','Single Particle Tracks Tiff Image Overlay (Max Distance)','Callback',{@spt_layover_max_dist});

    function coloc_module(~,~,~)
        colocalization_module()        
    end

    function coloc_module_New(~,~,~)
        colocalization_module_New()        
    end

    function LysosomeMask_module(~,~,~)
        Locs_Extraction_Module()        
    end

    function LysosomeMask_module_batch(~,~,~)
        Locs_Extraction_Module_batch()
    end

    function LysosomeMask_LAMTOR_module(~,~,~)
        Locs_Extraction_Module_LAMTOR()        
    end

    function LysosomeMask_module_LAMTOR_batch(~,~,~)
        Locs_Extraction_Module_LAMTOR_batch()
    end

    function Pattern_analysis_Module(~,~,~)
        Locs_PatternAnalysis_Module()
    end

    function coloc_stat_module(~,~,~)
        colocalization_statistics_module()        
    end

    function coloc_dualColour_Module(~,~,~)
        dualColour_Module()
    end

    function coloc_dualColour_Module2(~,~,~)
        dualColour_Module2()
    end

    function spt_layover_colocalization(~,~,~)
        spt_layover_module_colocalization()        
    end

    function spt_layover_max_dist(~,~,~)
        spt_layover_module_max_distance()        
    end


%---------------------modules menu------------------
%---------------------plot -------------------
    function plot_callback(~,~,~)
        if isempty(data)~=1
            [same_type_file,type_file] = same_type(listbox);
            listbox_value = listbox.Value;
            if same_type_file==1
                if isequal(type_file,'loc_list')                    
                    loc_list_plot(data(listbox_value));                
                elseif isequal(type_file,'spt')
                    data(listbox_value) = spt_plot(data(listbox_value));
                elseif isequal(type_file,'image')
                    image_plot(data(listbox_value))
                elseif isequal(type_file,'voronoi_data')
                    voronoi_data_plot(data(listbox_value))
                elseif isequal(type_file,'shape_class')
                    shape_classification_plot(data{listbox_value(1)})
                end
            else
                msgbox('data selected should be the same data type')
            end
        end
    end
%---------------------plot -------------------
%---------------------simulation menu--------------
simulation_menu = uimenu('Text','Simulations');
uimenu(simulation_menu,'Text','Loc List (Random Point Patterns)','callback',@random_point_pattern_simulation);
uimenu(simulation_menu,'Text','Gaussian Point Pattern (Random Gaussian Clusters)','callback',@gaussian_point_pattern_simulation);
uimenu(simulation_menu,'Text','Storm Image Simulation','callback',@storm_image_simulation);

spt_simulation_menu = uimenu(simulation_menu,'Text','Brownian Motion Simulation');
uimenu(spt_simulation_menu,'Text','Brownian Motion Simulation','callback',@brownian_simulation_callback);
uimenu(spt_simulation_menu,'Text','Random Brownian Motion Simulation','callback',@random_brownian_simulation_callback);
uimenu(spt_simulation_menu,'Text','Directed Brownian Motion Simulation','callback',@directed_brownian_simulation_callback);
uimenu(spt_simulation_menu,'Text','Confined Brownian Motion Simulation','callback',@confined_brownian_simulation_callback);

    function random_point_pattern_simulation(~,~,~)                
        data_load = loc_list_random_point_pattern_simulation();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);  
    end

    function gaussian_point_pattern_simulation(~,~,~)                
        data_load = loc_list_gaussian_point_pattern_simulation();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);  
    end

    function storm_image_simulation(~,~,~)                
        data_load = loc_list_storm_image_simulation();
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox); 
    end

    function brownian_simulation_callback(~,~,~)                
        spt_simulate_brownian_motion()      
    end

    function random_brownian_simulation_callback(~,~,~)                
        data_load = spt_simulate_random_brownian_motion() ;
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);  
    end

    function confined_brownian_simulation_callback(~,~,~)                
        data_load = spt_simulate_confined_brownian_motion(); 
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);  
    end

    function directed_brownian_simulation_callback(~,~,~)                
        data_load = spt_simulate_directed_brownian_motion();  
        data = set_global_data(data,data_load);
        listbox = set_listbox_names(listbox);  
    end 
%---------------------simulation menu--------------
%---------------------help menu---------------------
help_menu = uimenu('Text','Help');
uimenu(help_menu,'Text','About','Callback',{@about_callback});

    function about_callback(~,~,~)
        dos('explorer https://www.arianarab.com');       
    end
%---------------------help menu---------------------

    function move_up(~,~,~)
        listbox_value = listbox.Value;
        temp_one = data(1:listbox_value(1)-1);
        temp_two = data(listbox_value);
        temp_three = data(listbox_value(end)+1:end);
        try
            data_move = [temp_one(1:end-1) temp_two temp_one(end) temp_three];
            data = [];
            data = data_move;
            listbox.Value = listbox_value-1;
        end
        listbox = set_listbox_names(listbox);         
    end

    function move_down(~,~,~)
        listbox_value = listbox.Value;
        temp_one = data(1:listbox_value(1)-1);
        temp_two = data(listbox_value);
        temp_three = data(listbox_value(end)+1:end);
        try
            data_move = [temp_one temp_three(1) temp_two temp_three(2:end)];
            data = [];
            data = data_move;
            listbox.Value = listbox_value+1;
        end
        listbox = set_listbox_names(listbox);
    end
end

function listbox = set_listbox_names(listbox)
global data 
if isempty(data)==1
    listbox.String = 'NaN';
else
    for i=1:length(data)
        names{i} = data{i}.name;        
    end
    listbox.String = names;
end
end

function [file_type]= set_file_size(listbox,file_type)
global data
listbox_value = listbox.Value;
if isempty(data)
    file_type.String = 'NaN';    
else
    for i=1:length(listbox_value)        
        total_size(i) = get_size(data{listbox_value(i)});
    end    
    total_size = sum(total_size);
    file_type.String = num2str(total_size);
end
end

function [file_size]= set_file_type(listbox,file_size)
global data
listbox_value = listbox.Value;
if isempty(data)
    file_size.String = 'NaN';    
else
    file_size.String = data{listbox_value(1)}.type;
end
end

function [same_type_file,type_file] = same_type(listbox)
global data
listbox_value = listbox.Value;
if isempty(data)~=1
    for i=1:length(listbox_value)
        data_type{i} = data{listbox_value(i)}.type;
    end
    same_type_file = length(unique(data_type));
    type_file = data_type{1};
end
end

function data = set_global_data(data,data_load)
if isempty(data)==1
    data=data_load;
else
    data= horzcat(data,data_load);
end
end