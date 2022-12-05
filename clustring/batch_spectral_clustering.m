subsample_rate = 10;
k = 30;
X = Y;
num_neighbors = 5;
outputPath = 'Clustering_Methods';
mkdir(outputPath);
markerSize = 5;

clustering_algorithms = {'kmeans','dbscan','gmm','spectral','agglomerative'};


for ca = 1: length(clustering_algorithms)


    if strcmp(clustering_algorithms{ca},'kmeans')
        idx = kmeans(X,k);
    elseif strcmp(clustering_algorithms{ca},'dbscan')
        idx = dbscan(X,1,k);
    elseif strcmp(clustering_algorithms{ca},'agglomerative')
        idx = agglomerative_high_dimentions(X,k,subsample_rate,num_neighbors)
    elseif strcmp(clustering_algorithms{ca},'gmm')
        GMModel = fitgmdist(X,30);
        idx = cluster(GMModel,X);
    elseif strcmp(clustering_algorithms{ca},'spectral')
        idx = spectral_high_dimentions(X,k,subsample_rate,num_neighbors);
    end
    h = gscatter(X(:,2),X(:,1),idx);
    for i = 1 : length(h)
        h(i).MarkerSize = markerSize;
    end
    set(gcf,'color','white');
    
    saveas(gcf,fullfile(outputPath,strcat(clustering_algorithms{ca},'.png')));

end

