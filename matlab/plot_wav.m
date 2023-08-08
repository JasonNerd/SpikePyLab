function varargout = plot_wav(varargin)
% PLOT_WAV MATLAB code for plot_wav.fig
%      PLOT_WAV, by itself, creates a new PLOT_WAV or raises the existing
%      singleton*.
%
%      H = PLOT_WAV returns the handle to a new PLOT_WAV or the handle to
%      the existing singleton*.
%
%      PLOT_WAV('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOT_WAV.M with the given input arguments.
%
%      PLOT_WAV('Property','Value',...) creates a new PLOT_WAV or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plot_wav_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plot_wav_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plot_wav

% Last Modified by GUIDE v2.5 11-Jun-2023 21:34:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plot_wav_OpeningFcn, ...
                   'gui_OutputFcn',  @plot_wav_OutputFcn, ...
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


% --- Executes just before plot_wav is made visible.
function plot_wav_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.main_window_handler = varargin{1};
    % 1. 生成 table 的数据
    unit_count = size(handles.main_window_handler.trial_bin_spike, 3);
    handles.table_data = zeros(unit_count, 2);
    handles.table_data(:, 1) = 1:unit_count;
    handles.table_data(:, 2) = handles.main_window_handler.unit_firing_rate;
    set(handles.uitable2, 'data', handles.table_data);
    % 2. waveform 数据
    handles.unit_trial_wave = handles.main_window_handler.spike_data.spike_data.unit_trial_wave;
    % 3. 为 smooth_deg, wv_precent 置初值
    handles.smooth_deg = 3;
    handles.wv_precent = 0;
    % 4. precentage
    guidata(hObject, handles);
 
% ------------------------------------------------------------------------
function varargout = plot_wav_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % 曲线平滑度 (2 ~6)
    handles.smooth_deg = get(hObject, 'Value');
    guidata(hObject, handles);

function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    tbdt = get(handles.uitable2, 'data');
    tbdt = sortrows(tbdt, 1);
    set(handles.uitable2, 'data', tbdt); 

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
    % Neuron ID sort
    tbdt = get(handles.uitable2, 'data');
    tbdt = sortrows(tbdt, -2);
    set(handles.uitable2, 'data', tbdt);

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
    handles.wav_data = get_wav(handles);
    handles.wav_aver = mean(handles.wav_data);
    guidata(hObject, handles);
    % 2. 绘图
    axes(handles.axes1);
    plot_waveform(handles);

function plot_waveform(handles)
    wv_precent = handles.wv_precent;
    plot(handles.wav_aver, 'LineWidth', 3);
    hold on;
    if wv_precent ~= 0
        wv_num = round(size(handles.wav_data, 1)*wv_precent);
        plot(handles.wav_data(1:wv_num, :)');
        hold off;
    end
    title("Waveform curves of neuron "+handles.neuron_id_plt);
    ylabel("Spike potential(\muV)");

function wav_data = get_wav(handles)
    try
        neuron_id_plt = handles.neuron_id_plt;
        smooth_deg = handles.smooth_deg;
    catch
        errordlg("请先选择一个神经元", "Neuron ID missed", "modal");
        return;
    end
    % 1. 取对应神经元编号的所有waveform
    wav_data = handles.unit_trial_wave(neuron_id_plt, :, :);
    trial_num = size(wav_data, 2);
    wave_len = size(wav_data, 3);
    wav_data = reshape(wav_data, [trial_num, wave_len]);
    % 2. 去掉峰值过小的行
    idx = max(wav_data, [], 2) > 50;
    wav_data = wav_data(idx, :);
    % 3. smooth 处理
    wv_num = size(wav_data, 1);
    for i=1:wv_num
        wav_data(i, :) = smooth(wav_data(i, :), smooth_deg);
    end

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
    % Save waveform figure
    figure;
    handles.wav_data = get_wav(handles);
    handles.wav_aver = mean(handles.wav_data);
    guidata(hObject, handles);
    % 1. 取一定的百分比
    plot_waveform(handles);

% --- Plot Inter-spike interval.
function pushbutton10_Callback(hObject, eventdata, handles)
    % Plot Inter-spike interval
    neuron_interval = get_interval(handles);
    axes(handles.axes2);
    histogram(neuron_interval);

% --- Save Inter-spike interval figure
function pushbutton11_Callback(hObject, eventdata, handles)
    % Save Inter-spike interval figure
    neuron_interval = get_interval(handles);
    figure;
    histogram(neuron_interval);

function neuron_interval=get_interval(handles)
    try
        neuron_id_plt = handles.neuron_id_plt;
    catch
        errordlg("请先选择一个神经元", "Neuron ID missed", "modal");
        return;
    end
    trial_bin_spike = handles.main_window_handler.trial_bin_spike;
    trial_cn = size(trial_bin_spike, 1);
    time_len = size(trial_bin_spike, 2);
    neuron_spike = trial_bin_spike(:, :, neuron_id_plt);
    neuron_spike = reshape(neuron_spike, [trial_cn, time_len]);
    neuron_interval = [];
    for i=1:trial_cn
        firing_tick = find(neuron_spike(i, :));
        if ~isempty(firing_tick)
            neuron_interval = [neuron_interval, firing_tick(1)];
            for j = 2:length(firing_tick)
                neuron_interval = [neuron_interval, (firing_tick(j)-firing_tick(j-1))];
            end
        end
    end
    
% --- Executes when selected cell(s) is changed in uitable2.
function uitable2_CellSelectionCallback(hObject, eventdata, handles)
    selected_row_idx = eventdata.Indices(1);
    tbdt = get(hObject, 'data');
    neuron_id = tbdt(selected_row_idx, 1);
    handles.neuron_id_plt = neuron_id;
    set(handles.text12, 'String', neuron_id);
    guidata(hObject, handles);


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
    % 调整曲线数量(1-20)
    sl_v = get(hObject, 'Value');
    handles.wv_precent = sl_v/20;
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
