function idx_final = agglomerative_high_dimentions(X,k,subsample_rate,num_neighbors,epsilon,minpts)

if nargin <= 4
    epsilon = 3;
    minpts = 30;
end

idx = dbscan(X,epsilon,minpts);

M = mode(idx);
T = find(idx==M);
X_cl = X(T,:);
maxIDX = max(idx);


XSubSampled = X_cl(1:subsample_rate:end,:);

Z = linkage(XSubSampled,'centroid');
idx_subsampled = cluster(Z,'Maxclust',k-length(unique(idx))+1);

Mdl = fitcknn(XSubSampled,idx_subsampled,'NumNeighbors',num_neighbors);
idx_cl = predict(Mdl,X_cl);

idx_final = idx;


for i = 1 : length(T)
    idx_final(T(i)) = maxIDX+idx_cl(i);
end

end