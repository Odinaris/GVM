function G_opt = get_gvm_relationship( vlc, possible_solutions, payload, U, S)
% 输入JPEG比特流解析过生成的VLC序列及相关信息
% vlc - 当前图像的VLC信息
% S - 可选峰值点数量（选择的已使用VLC的数量）
% U - 每个选择的已使用VLC可分配到的最大未使用VLC数量
num_unused = sum(vlc(:,3)==0);
num_used = length(vlc(:,3)) - num_unused;
%% Compute the capacity when filesize preservation
s_vlc= sortrows(vlc,-3);
s_vlc(:,4) = vlc(:,4);
lst_peaks = find(s_vlc(:,3) >= payload);
redundancy = sum((vlc(:,3) - s_vlc(:,3)) .* vlc(:,4));
if isempty(lst_peaks)
    lst_peaks = 1;
else
    lst_peaks = lst_peaks(end);
end
peaks = lst_peaks : num_used;
G_opt = cell(numel(peaks),1);
for i = 1 : numel(peaks)
    p = peaks(i);
    fst_capacity = s_vlc(p,3);  %第一个峰值点的载荷，只分配一个未使用VLC时
    u = 0;
    flag = false;
    while ~flag
        u = u + 1;
        if fst_capacity * u >= payload
            flag = true;
        end
        if u > U
            u = U;
            flag = true;
        end
    end
    s = min(num_used - peaks(i) + 1, S);
    possible_solutions = get_feasible_solutions(num_unused, possible_solutions, u, s);
    [num_solutions,~] = size(possible_solutions);
    output = ones(num_solutions,2) * Inf;	% 第二列是文件大小膨胀量fi - file size increment.
    shifted_vlc = cell(num_solutions,1);
    for j = 1:num_solutions
        capacity = sum(s_vlc(p:p+s-1,3) .* log2(possible_solutions(j,:)+1)');
        if capacity < payload
            continue;
        end
        ptr = p;
        cur_vlc = s_vlc;
        num_cur_peaks = sum(possible_solutions(j,:)~=0);
        remain_payload = payload;
        for k = 1:num_cur_peaks
            num_shift = possible_solutions(j,k);
            tmp = cur_vlc(end-num_shift + 1 : end, 1:2);
            cur_vlc(ptr + num_shift + 1 : end, 1:3) = cur_vlc(ptr + 1 : end - num_shift, 1:3);
            cur_vlc(ptr + 1 : ptr + num_shift, 1:2) = tmp;
            remain_payload = remain_payload - cur_vlc(ptr, 3) * log2(num_shift + 1);
            if k == num_cur_peaks || remain_payload < 0
                output(j,1) = payload;
                if remain_payload < 0
                    remain_payload = remain_payload + cur_vlc(ptr, 3) * log2(num_shift + 1);
                end
                num_simulated_shift = remain_payload / log2(num_shift + 1);
                cur_vlc(ptr, 3) = cur_vlc(ptr, 3) - num_simulated_shift * num_shift / (num_shift + 1);
                cur_vlc(ptr + 1 : ptr + num_shift, 3) = num_simulated_shift / (num_shift + 1);
            else
                cur_vlc(ptr : ptr + num_shift, 3) = cur_vlc(ptr, 3) / (num_shift + 1);
                ptr = ptr + num_shift + 1;
            end
        end
        output(j,2) = round(sum((cur_vlc(:,3) - s_vlc(:,3)).*s_vlc(:,4)));
        shifted_vlc{j} = cur_vlc;
    end
    [min_fi, ind] = min(output(:,2));
    if min_fi == Inf
        G_opt{i} = [];
    else
        G_opt{i}.min_fi = min_fi;
        G_opt{i}.shifted_vlc = shifted_vlc{ind};
        G_opt{i}.capacity = output(ind,1);
        G_opt{i}.opt_mapping_set = possible_solutions(ind,:);
        G_opt{i}.freq_peak_points = s_vlc(p : p+s-1, 3);
        G_opt{i}.start_peak_point = p;
        G_opt{i}.redundancy = redundancy;
    end
end
for i = 1 : numel(peaks)
    if isempty(G_opt{i})
        break;
    end
end
G_opt(i:end) = [];
[num,~] = size(G_opt);
min_fi = zeros(num,1);
for i = 1:num
    min_fi(i) = G_opt{i,1}.min_fi; 
end
[~,ind] = min(min_fi);
G_opt = G_opt{ind};
