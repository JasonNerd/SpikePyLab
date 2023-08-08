function [lda_score,inter_dst,within_dst] = calc_lda_score(data,label)

[label_sort,idx] = sort(label);
data_sort = data(idx,:);


%D = pdist(data_sort,'cosine');
D = pdist(data_sort,'euclidean');
Z = squareform(D);


within_dst = [];
inter_dst = [];
for i = 1:length(label_sort)
    for j = 1:length(label_sort)
        if(i~=j)
            if(label_sort(i)==label_sort(j))
                within_dst = [within_dst, Z(i,j)];
            else
                inter_dst = [inter_dst,Z(i,j)];
            end
        end
    end
end

lda_score = mean(inter_dst,'omitnan')/mean(within_dst,'omitnan');


% % step1 compute the mean vec for all classes
% num_label = max(label);
% for i = 1:num_label
%     pos = find(label==i);
%     data_tmp = data(pos,:);
%     data_mean(i,:) = mean(data_tmp,2);
% end
% 
% % step2 within class dist
% within_dist = [];
% for i = 1:num_label
%     pos = find(label==i);
%     data_tmp = data(pos,:);
%     for j = 1:length(pos)
%         
%     end
%     
%     data_mean(i,:) = mean(data_tmp,2);
% end
% 
% % step3 inter class dist

end