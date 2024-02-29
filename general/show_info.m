function show_info(data)
if isequal(data.info,'NaN')
    msgbox('there is no information')
else
    msgbox(data.info)
end