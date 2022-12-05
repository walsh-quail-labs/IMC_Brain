function idx = GMM_high_dimentions(X,k,subsample_rate,num_neighbors)
XSubSampled = X(1:subsample_rate:end,:);
GMModel = fitgmdist(XSubSampled,k);
idx_subsampled = cluster(GMModel,XSubSampled);
Mdl = fitcknn(XSubSampled,idx_subsampled,'NumNeighbors',num_neighbors);
idx = predict(Mdl,X);
end