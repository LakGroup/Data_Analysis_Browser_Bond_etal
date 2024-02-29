function get_capture_from_figure()
[file,path] = uiputfile('*.png');
if path~=0
    set(gcf, 'InvertHardcopy', 'off')
    print(fullfile(path,file),gcf,'-dpng','-r200'); 
end
end