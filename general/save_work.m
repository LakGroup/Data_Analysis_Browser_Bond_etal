function save_work(data_to_save)
global data listbox
listbox_value = listbox.Value;
data(listbox_value) = data_to_save;
end