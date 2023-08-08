function varargout = rasterplot(varargin)
% RASTERPLOT MATLAB code for rasterplot.fig
%      RASTERPLOT, by itself, creates a new RASTERPLOT or raises the existing
%      singleton*.
%
%      H = RASTERPLOT returns the handle to a new RASTERPLOT or the handle to
%      the existing singleton*.
%
%      RASTERPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RASTERPLOT.M with the given input arguments.
%
%      RASTERPLOT('Property','Value',...) creates a new RASTERPLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rasterplot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rasterplot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rasterplot

% Last Modified by GUIDE v2.5 09-Jun-2023 16:01:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rasterplot_OpeningFcn, ...
                   'gui_OutputFcn',  @rasterplot_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before rasterplot is made visible.
function rasterplot_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.main_window_handler = varargin{1};
    handles.target_table = str2table(handles.main_window_handler.target_table);
    % 1. 设置 target_table
    set(handles.listbox1, 'String', handles.target_table);
    % 2. 生成 table 的数据结构
    unit_count = size(handles.main_window_handler.trial_bin_spike, 3);
    handles.table_data = zeros(unit_count, 2);
    handles.table_data(:, 1) = 1:unit_count;
    handles.table_data(:, 2) = handles.main_window_handler.unit_firing_rate;
    % 3. 填充 table 初始数据
    set(handles.uitable1, 'data', handles.table_data);
    % 4. 默认初始 LAD distance 算法 euclidean
    handles.ldaalg = "euclidean";
    guidata(hObject, handles);

function target_table = str2table(org_str)
    n = length(org_str);
    target_table = [];
    for i = 1:n
        target_table = [target_table, string(org_str(i))];
    end
 

% --- Outputs from this function are returned to the command line.
function varargout = rasterplot_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % save figures
    try
        mul_target_spike = handles.mul_target_spike;
        mul_target_trcnt = handles.mul_target_trcnt;
        neuron_id_plt = handles.neuron_id_plt;
        isi_targets = handles.isi_targets;
    catch
        errordlg("请先更新Lda-score", "Operation missed", "modal");
        return;
    end
    fs_raster_plt(mul_target_spike, mul_target_trcnt, isi_targets, neuron_id_plt);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    % plot figures
    try
        mul_target_spike = handles.mul_target_spike;
        mul_target_trcnt = handles.mul_target_trcnt;
        neuron_id_plt = handles.neuron_id_plt;
        isi_targets = handles.isi_targets;
    catch
        errordlg("请先更新Lda-score", "Operation missed", "modal");
        return;
    end
    f_raster_plt(mul_target_spike, mul_target_trcnt, isi_targets, neuron_id_plt);
    
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
    lst_idxs = get(handles.listbox1, 'Value');
    isi_targets = handles.target_table(lst_idxs);
    handles.isi_targets = isi_targets;  % 获取选择的target
    guidata(hObject, handles);
    tgtxt = "";
    for i=1:length(lst_idxs)
        tgtxt = tgtxt + isi_targets(i);
    end
    set(handles.text7, 'String', tgtxt);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    % Neuron ID sort
    tbdt = get(handles.uitable1, 'data');
    tbdt = sortrows(tbdt, 1);
    set(handles.uitable1, 'data', tbdt);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    try
        isi_targets = handles.isi_targets;
        neuron_id_plt = handles.neuron_id_plt;
    catch
        errordlg("请先选择target和nueron", "Operation missed", "modal");
        return;
    end
    % 依据 isi_targets 和 neuron_id_plt 筛选实验数据
    target_table = handles.main_window_handler.spike_data.spike_data.target_table;
    trial_target = handles.main_window_handler.spike_data.spike_data.trial_target;
    trial_bin_spike = handles.main_window_handler.spike_data.spike_data.trial_bin_spike;
    target_trial_tlen = size(trial_bin_spike, 2);
    % 筛选目标对应的 spike
    mul_target_spike = [];  % 二维, 记录着多个目标的实验
    mul_target_trcnt = [];  % 一维, 记录着每个目标的实验次数
    for i=1: length(isi_targets)
        target_txt_plt = isi_targets(i);
        target_idx_plt = strfind(target_table, target_txt_plt);     
        target_trialno = find(trial_target==target_idx_plt);        
        target_trial_spike = trial_bin_spike(target_trialno, 1:target_trial_tlen, neuron_id_plt);
        mul_target_spike = [mul_target_spike; target_trial_spike];
        mul_target_trcnt = [mul_target_trcnt, length(target_trialno)];
    end
    handles.mul_target_spike = mul_target_spike;
    handles.mul_target_trcnt = mul_target_trcnt;
    guidata(hObject, handles);
    % 计算 LDA-score
    mul_target_trial_num = size(mul_target_spike, 1);
    mul_target_labels = zeros(1, mul_target_trial_num);
    cumsum_tn=0;
    for i=1: length(isi_targets)
        ttn = mul_target_trcnt(i);
        for j=1:ttn
            mul_target_labels(cumsum_tn+j) = i;
        end
        cumsum_tn = cumsum_tn + ttn;
    end
    lda_score = calc_lda_score(mul_target_spike, mul_target_labels);
    % 将 lda_score 更新到 显示控件
    set(handles.text3, 'String', lda_score);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    % Firing rate sort
    tbdt = get(handles.uitable1, 'data');
    tbdt = sortrows(tbdt, -2);
    set(handles.uitable1, 'data', tbdt);
    
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
    idx = get(hObject, 'Value');
    itlist = get(hObject, 'String');
    ldaalg = string(itlist(idx));
    handles.ldaalg = ldaalg;
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
    selected_row_idx = eventdata.Indices(1);
    tbdt = get(hObject, 'data');
    neuron_id = tbdt(selected_row_idx, 1);
    handles.neuron_id_plt = neuron_id;
    set(handles.text10, 'String', neuron_id);
    guidata(hObject, handles);
