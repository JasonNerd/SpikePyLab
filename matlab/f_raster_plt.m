function f_raster_plt(mul_target_spike, mul_target_trcnt, isi_targets, neuron_id_plt)
    % 可能出现空集 [4 4 0 4], 也即部分 target 没有对应的实验
    nan_idx = (mul_target_trcnt==0);
    nan_target = isi_targets(nan_idx);
    isi_targets = isi_targets(~nan_idx);
    mul_target_trcnt = mul_target_trcnt(~nan_idx);
    if ~isempty(nan_target)
        ntg = "";
        for i = 1:length(nan_target)
            ntg = ntg + nan_target(i);
        end
        disp("Warning: there's no trial on sepcified target "+ntg+" of unit "+string(neuron_id_plt));
    end
    % 2. 进行绘制
    target_cnt = length(isi_targets);
    target_trial_tlen = size(mul_target_spike, 2);
    tid = 0;    % target分段
    for i = 1: target_cnt
        scatter_x = [];
        scatter_y = [];
        if i>1
            tid = tid+mul_target_trcnt(1, i-1);
        end
        for k = tid+1: tid+mul_target_trcnt(1, i)
            for j = 1: target_trial_tlen
                if mul_target_spike(k, j) > 0
                    scatter_x = [scatter_x, j];
                    scatter_y = [scatter_y, k];
                end
            end
        end
        % 完成了一个target的数据查找
        scatter(scatter_x, scatter_y, 25, 'filled');
        yline(k);
        if i < target_cnt
            hold on;
        end
    end
    hold off;
    % title yticks xticks
    title("Raster plots across targets on neuron "+string(neuron_id_plt));
    cs_mtt = cumsum(mul_target_trcnt); % [4 8 16 20 24 28]
    ytick_arr = zeros(1, length(mul_target_trcnt));    % [0 0 0 0 0 0]
    ytick_arr(1) = cs_mtt(1)/2; % [2 0 0 0 0 0]
    for i =2: length(ytick_arr)
        ytick_arr(i) = (cs_mtt(i)+cs_mtt(i-1))/2;
    end
    yticks(ytick_arr);
    yticklabels(isi_targets);
    ylabel("Character");
    xlabel("time(msec)");