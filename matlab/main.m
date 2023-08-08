function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 08-Jun-2023 22:05:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to main (see VARARGIN)
    handles.output = hObject;       % Choose default command line output for main
    guidata(hObject, handles);      % Update handles structure


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function Fileoption_Callback(hObject, eventdata, handles)
% hObject    handle to Fileoption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SUAoption_Callback(hObject, eventdata, handles)
% hObject    handle to SUAoption (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function waveform_Callback(hObject, eventdata, handles)
    wav_ok = string(get(handles.text19, "String"));
    if wav_ok ~= "True"
        msgbox("waveform data not loaded ...", "modal");
        return ;
    end
    try
        handles.unit_firing_rate; % 如果存在该变量就不进行计算
    catch
        unit_cnt = size(handles.trial_bin_spike, 3);
        unit_firing_rate = zeros(1, unit_cnt);
        trial_time_sec = size(handles.trial_bin_spike, 2)/1000;
        for i=1:unit_cnt
            unit_firing_rate(i) = sum(sum(handles.trial_bin_spike(:,:,i)))/trial_time_sec;
        end
        handles.unit_firing_rate = unit_firing_rate;
        handles.spike_data.unit_firing_rate = unit_firing_rate;
        guidata(hObject, handles);
    end
    plot_wav(handles);

% --------------------------------------------------------------------
function crossraster_Callback(hObject, eventdata, handles)
    % 计算 firing rate, trial-independent
    try
        handles.unit_firing_rate; % 如果存在该变量就不进行计算
    catch
        unit_cnt = size(handles.trial_bin_spike, 3);
        unit_firing_rate = zeros(1, unit_cnt);
        trial_time_sec = size(handles.trial_bin_spike, 2)/1000;
        for i=1:unit_cnt
            unit_firing_rate(i) = sum(sum(handles.trial_bin_spike(:,:,i)))/trial_time_sec;
        end
        handles.unit_firing_rate = unit_firing_rate;
        handles.spike_data.unit_firing_rate = unit_firing_rate;
        guidata(hObject, handles);
    end
    rasterplot(handles);

% --------------------------------------------------------------------
function tuningcurve_Callback(hObject, eventdata, handles)
    


% --------------------------------------------------------------------
function LoadNEV_Callback(hObject, eventdata, handles)
    % 加载 NEV 文件
    [FileName, PathName, FilterIndex] = uigetfile('*.nev');
    if FilterIndex == 1
	    NEV = openNEV(fullfile(PathName, FileName));
    end
    % 设置 Spike Data Load 状态
    set(handles.text10, 'String', string(FileName));
    handles.NEV = NEV;
    handles.data_root = string(PathName);
    guidata(hObject, handles);
    
% --------------------------------------------------------------------
function PatientTarget_Callback(hObject, eventdata, handles)
    [FileName, PathName, FilterIndex] = uigetfile('*.mat');
    if FilterIndex == 1
	    Data = load(fullfile(PathName, FileName));
    end
    % 设置 Spike Data Load 状态
    set(handles.text12, 'String', string(FileName));
    handles.Data = Data.Data;
    handles.patient_fnm = string(FileName);
    guidata(hObject, handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    % 用户按下了获取spike的按钮
    % 1. 先检查是否已经有 spike_data 预处理文件
    % 2. 若没有，再检查两个文件是否已经加载完毕，否则直接读入文件数据
    % 2. 设置spike_prc = false
    % 3. 唤起progress.m进行处理并显示处理过程
    sdl = string(get(handles.text10, "String"));
    ttl = string(get(handles.text12, "String"));
    if sdl == "False" || ttl == "False"
        errordlg("请先加载spike数据文件和trial信息文件!", "Data not Loaded!");
        return;
    end
    handles.spike_tensor_fn = handles.data_root+handles.patient_fnm+"_spike_data.mat";
    guidata(hObject, handles);
    try
        if handles.spike_prc    % 可能还没有这个变量
            msgbox("spike tensor generated already!", "Data have Loaded!");
        end
    catch   % 捕获异常, 则分配变量, 并置初始值为 false
        handles.spike_prc = false;
        % 将主窗口的句柄handles.figure1
        handles.spike_data = progress(handles);
        handles.spike_prc = true;
    end
%     display(handles.spike_data);
    %%%%%%%%%%%%%%%%%
    % 4. 对于处理好的信息, 我们展示这些字段
    spike_data = handles.spike_data.spike_data;
    display(handles.spike_data);
    handles.target_table = spike_data.target_table;         % text11
    handles.trial_bin_spike = spike_data.trial_bin_spike;    % text16, text14, text15
    handles.trial_count = spike_data.trial_count;            % text13
    handles.unit_trial_wave = spike_data.unit_trial_wave;    % text19
    handles.trial_target = spike_data.trial_target;          
    set(handles.text11, 'String', [handles.target_table(1: 5), ' ...']);
    set(handles.text13, 'String', string(size(handles.trial_bin_spike, 1)));
    set(handles.text16, 'String', string(size(handles.trial_bin_spike, 2)));
    set(handles.text14, 'String', string(size(handles.trial_bin_spike, 3)));
    set(handles.text15, 'String', '1ms');
    set(handles.text19, 'String', 'True');
    guidata(hObject, handles);
