function image_save_video(data)
[file,path] = uiputfile('*.avi');
if path~=0
    save_to = fullfile(path,file);
    video = VideoWriter(save_to);
    video.FrameRate = 10;
    open(video);
    for i = 1:length(data)
        images = data{i}.image{1};
        writeVideo(video,images); 
        clear I
    end
    close(video);
end
end