function varargout = progress(varargin)
% PROGRESS MATLAB code for progress.fig
%      PROGRESS, by itself, creates a new PROGRESS or raises the existing
%      singleton*.
%
%      H = PROGRESS returns the handle to a new PROGRESS or the handle to
%      the existing singleton*.
%
%      PROGRESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROGRESS.M with the given input arguments.
%
%      PROGRESS('Property','Value',...) creates a new PROGRESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before progress_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to progress_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help progress

% Last Modified by GUIDE v2.5 07-Jun-2023 10:44:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @progress_OpeningFcn, ...
                   'gui_OutputFcn',  @progress_OutputFcn, ...
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


% --- Executes just before progress is made visible.
function progress_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;
    handles.main_window_handler = varargin{1};
    guidata(hObject, handles);
    % UIWAIT makes ch1 wait for user response (see UIRESUME)
    uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = progress_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    varargout{1} = handles.spike_data;
    
function update_pbar(handles, lstr)
%     display(lstr);
    prg_txt = string(get(handles.edit1, 'String'));
    prg_txt = [prg_txt; lstr];
    set(handles.edit1, 'String', prg_txt);
    drawnow;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%1. 读取传入数据%%%%%%%%%
    Data = handles.main_window_handler.Data;
    NEV = handles.main_window_handler.NEV;
    spike_tensor_fn = handles.main_window_handler.spike_tensor_fn;
    set(handles.edit1, 'String', "");
    %%%%%%%2. 若已加载, 则读入加载的文件%%%%%%%%%
    if exist(spike_tensor_fn, 'file')
        update_pbar(handles, "发现已处理的spike tensor文件, 选择加载该文件");
        handles.spike_data = load(spike_tensor_fn);
        guidata(hObject, handles);
        update_pbar(handles, "----------------------------");
        update_pbar(handles, "spike tensor已加载, 请关闭本页面");
        uiresume(handles.figure1);  %与 uiwait() 配合使用。唤醒 uiwait() 函数
        return ;
    end
    %%%%%%%3. 否则, 开始处理数据%%%%%%%%%
    update_pbar(handles, "准备加载受试者实验信息 ... ...");
    trial_number=Data.TrialNo;
    trial_count = max(unique(Data.TrialNo));
    update_pbar(handles, "读取实验信息：实验次数为"+string(trial_count)+"次");
    target = zeros(size(Data.TaskStateMsg.target_idx));
    update_pbar(handles, "读取实验目标集合编号 ... ...");
    tgt = Data.TaskStateMsg.target(~isnan(Data.TaskStateMsg.target))';
    tgt = tgt(tgt~=0);
    tgt = unique(tgt,'stable');
    update_pbar(handles, "读取实验目标集合编号完毕");
    update_pbar(handles, "分析受试者各次实验的目标编号 ... ...");
    for i=1:length(target)
        if (Data.TaskStateMsg.target_idx(i) == 0)
            tgt_idx = 1;
        else
            tgt_idx = Data.TaskStateMsg.target_idx(i);
        end
        index = find(tgt(1,:)==Data.TaskStateMsg.target(tgt_idx,i));
        if (isempty(index)) 
            index = -1;
        end
        target(i) = index;
    end
    update_pbar(handles, "分析完毕，目标编号已存储至变量");
    target_table = char(tgt);
    update_pbar(handles, "获取得目标集合: "+string(target_table));
    len=length(trial_number);   % 44765
    trial_no=[];
    trial_target=[];
    update_pbar(handles, "准备获取历次实验的目标对象 ... ...");
    for i = 1:trial_count   % 遍历每一次实验, 从编号1开始
        for j=1:len
            if j~=1
                if trial_number(j)==i && trial_number(j-1)<i
                    trial_no=[trial_no,trial_number(j)];
                    trial_target=[trial_target,target(j)];
                end
            end
        end
    end
    trial_target=trial_target-1;
    update_pbar(handles, "获取历次实验的目标对象完毕，已存储至变量");
    update_pbar(handles, "受试者实验信息加载完毕！");
    %%%%%%%%%%%%%%%%
    update_pbar(handles, "----------------------------");
    update_pbar(handles, "----------------------------");
    update_pbar(handles, "准备进行spike数据的处理 ... ...");
    update_pbar(handles, "读取实验起始时间戳 ... ...");
    trial_num=NEV.Data.SerialDigitalIO.UnparsedData;    % (918 x 1) 理解为事件 event, 例如 16 表示一个块(block) 的开始
    trial_len=length(trial_num);        % 918
    check_flag = 0;
    state_index = 81;   % 81: start, 82: prepare, 83: reaction. 84: go, 85: inter
    trial_timestamp = NEV.Data.SerialDigitalIO.TimeStamp;
    for i=1:size(state_index,2)     % 外层 for 循环实际执行1次
        trial_start_stamp=[];
        final_state = state_index(i);
        for j=1:trial_len       % 遍历 event 编号数组, 寻找每一个 81 号事件, 并记录时间戳
            if trial_num(j)==state_index(i)
                check_flag = check_flag+1;
                trial_start_stamp=[trial_start_stamp, trial_timestamp(j)];
            end
        end
        if check_flag==trial_count
            break;
        end
        if i==size(state_index) && trial_count-check_flag>0
            error('Incomplete Data!!!');
        end
    end
    update_pbar(handles, "实验起始时间戳读取完毕，已存储至变量");
    handles.trial_start_stamp = trial_start_stamp;
    update_pbar(handles, "读取电极编号列表、神经元编号列表、神经元发放时间戳列表");
    channels = 224;
    unit_type = 5;
    spike_unit=NEV.Data.Spikes.Unit;            % (1 x 320806) 电极内 - 神经元编号(0~5)
    electrode=NEV.Data.Spikes.Electrode;        % (1 x 320806) 电极编号(1 ~ 157)
    timestamp=NEV.Data.Spikes.TimeStamp;        % (1 x 320806) 时间戳()
    spike_len=length(spike_unit);               % 320806
    spike_unit_stamp=zeros(channels*unit_type,spike_len);
    k=1;
    spikeunit_channel=[];       % [k, t]
    update_pbar(handles, "读取完毕，列表总长度："+string(spike_len));
    update_pbar(handles, "开始分析神经元发放时间 ...");
    for j=1:channels
      for m=1:unit_type
        % 在确定的 (m, j) pair 下
        % 遍历每一对 (spike_unit(i), electrode(i)), 如果恰好与 pair 相同, 则加入到 spike_unit_stamp
        for i=1:spike_len
          if spike_unit(i)==m &&electrode(i)==j
            spike_unit_stamp(k,i)=timestamp(i);
            spikeunit_channel = [spikeunit_channel; ceil(k/unit_type) m];
          end
        end
        k=k+1;
      end
    end
    update_pbar(handles, "分析结束，统计得到本次神经元数量为"+string(k));
    spikeunit_channel=unique(spikeunit_channel,'rows');
    update_pbar(handles, "准备压缩神经元发放时间戳矩阵数据 ...");
    spike_unit_stamp(all(spike_unit_stamp==0,2),:) = [];  %去掉所有非0元素所在行
    [unit_number,c]=size(spike_unit_stamp);
    count_spike=0;
    max_spike_nan=[];
    % 每个神经元所有时间里发放总次数
    for i=1:unit_number
            num_=sum(spike_unit_stamp(i,:)~=0);
            max_spike_nan=[max_spike_nan, num_];
    end
    max_spike_len=max(max_spike_nan);
    update_pbar(handles, "单神经元发放最大次数统计完毕，开始进行矩阵压缩 ...");
    final_spike_stamp=zeros(unit_number,max_spike_len);  % (110, 21525)
    spikeunit_index=zeros(unit_number,max_spike_len);    % Hash table, 记录着非0值的列标
    for i=1:unit_number
        num_=sum(spike_unit_stamp(i,:)~=0);
        if num_>0
            [r_spike,c_spike,v_spike]=find(spike_unit_stamp(i,:));
            spikeunit_index(i,c_spike)=c_spike;
            for j=1:num_
                final_spike_stamp(i,j)=v_spike(j);
                spikeunit_index(i,j)=c_spike(j);
            end
        end
    end
    spike_count_unit=zeros(unit_number,trial_count,max_spike_len);
    update_pbar(handles, "压缩完毕，开始生成 spike tensor");
    %%%%%%%%%%%%%%%%%%%%%
    waveform = double(NEV.Data.Spikes.Waveform);
    wvlen = size(waveform, 1);
    unit_count = size(spike_unit_stamp, 1);
    unit_trial_wave = zeros(unit_count, trial_count, wvlen);
    u_t_w_cnt = zeros(unit_count, trial_count, wvlen);  % 计数器
    count=0;
    update_pbar(handles, "计算各个神经元在历次实验中的发放时刻序列与波形序列");
    for m=1:trial_count         % 76, 实验的次数(or we say, 写了多少个字), trial_start_stamp 记录着实验开始的时刻
        count=count+1;          % 
        for i=1:unit_number     % 遍历 final_spike_stamp[i, j]
            temp_stamp=[];      % 
            for j=1:max_spike_len
                if m~=trial_count
                    if final_spike_stamp(i,j)>=trial_start_stamp(m)&&final_spike_stamp(i,j)<trial_start_stamp(m+1)
                        tmpwv = waveform(:, j);
                        unit_trial_wave(i, m, :) = unit_trial_wave(i, m, :) + reshape(tmpwv, [1, 1, wvlen]);
                        u_t_w_cnt(i, m, :) = u_t_w_cnt(i, m, :) + 1;
                        temp_stamp=[temp_stamp,final_spike_stamp(i,j)];
                    end
                else
                    if final_spike_stamp(i,j)>=trial_start_stamp(m)     % 针对最后一个实验
                        temp_stamp=[temp_stamp,final_spike_stamp(i,j)];
                    end
                end
            end
            len=length(temp_stamp);
            for k=1:len  % temp_stamp[] 记录着 神经元i 在 实验号m 中的 发放时刻序列
                spike_count_unit(i,m,k)=temp_stamp(k);
            end
        end
    end
    update_pbar(handles, "各神经元历次实验发放时刻序列与波形序列生成完毕");
    update_pbar(handles, "对波形序列进行均值处理");
    u_t_w_cnt(u_t_w_cnt==0)=1; % 避免除0错误
    unit_trial_wave = unit_trial_wave ./ u_t_w_cnt;
    update_pbar(handles, "均值处理完毕，保存波形数据到变量");
    % bin_spike_unit(i,j,k), i: 神经元编号, j: 实验编号, k: 实验时间步号
    spikeunit_stamp=zeros(unit_number,trial_count,max_spike_len);
    trial_last_time=[];
    for i=1:trial_count-1
        trial_time=(trial_start_stamp(i+1)-trial_start_stamp(i));
        trial_last_time=[trial_last_time,trial_time];
    end
    % trial_last_time, 每次实验的持续时长, 不包括最后一次
    % spikeunit_stamp(unit_number,trial_count,max_spike_len)
    % 它记录着i号神经元在j号实验中的发放时间序列(相对于j号实验的起始时刻, local)
    update_pbar(handles, "正在生成 spike tensor. 这可能需要数分钟的时间 ... ...");
    for i=1:unit_number
        for j=1:trial_count
            for k=1:max_spike_len
                if spike_count_unit(i,j,k)>0
                    spikeunit_stamp(i,j,k)=(spike_count_unit(i,j,k)-trial_start_stamp(j));
                end
            end
        end
    end
    spikeunit_max_time=max(trial_last_time);
    bin_spike_unit=zeros(unit_number,trial_count,round(spikeunit_max_time/30)); % 30KHz, 这里就取为1KHz, or we can say 每1ms作为一个时间步
    trial_time = spikeunit_max_time;
    update_pbar(handles, "正在生成 spike tensor. 这可能需要数分钟的时间 ... ...");
    for i=1:unit_number
        save_unitcount=i;
        for j=1:trial_count
            firing=zeros(1,1,trial_time);
            [r_unit,c_unit,v_unit]=find(spikeunit_stamp(i,j,:));
            firing(1,1,v_unit)=1;
            for k=1:round(trial_time/30)-1
                if k*30>trial_time
                    bin_spike_unit(i,j,k)=sum(firing(1,1,(k-1)*30+1:end));
                else
                   bin_spike_unit(i,j,k)=sum(firing(1,1,(k-1)*30+1:30*k));
                end
            end
            
        end
    end
    update_pbar(handles, "spike tensor 生成完毕! ");
    trial_bin_spike=permute(bin_spike_unit,[2,3,1]);
    %%%%%%%%%%%%%%%%
    update_pbar(handles, "----------------------------");
    update_pbar(handles, "----------------------------");
    update_pbar(handles, "存储 spike tensor 等数据 ...");
    spike_data.trial_bin_spike = trial_bin_spike;
    spike_data.trial_count = trial_count;
    spike_data.unit_trial_wave = unit_trial_wave;
    spike_data.target_table = target_table;
    spike_data.trial_target = trial_target;
    handles.spike_data = spike_data;
    guidata(hObject, handles);
    uiresume(handles.figure1);  %与 uiwait() 配合使用。唤醒 uiwait() 函数
    save(spike_tensor_fn, "spike_data");
    update_pbar(handles, "存储完毕，请关闭本页面");
    update_pbar(handles, "");
    update_pbar(handles, "");
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    delete(hObject);
