clear all
close all;
datasetNum = 'lung'; 
k = 6;
consideredFileName = ['Data'];
shift = 3;
memWidth = 10;


voronoiResultPath = fullfile('VoronoiFigures',consideredFileName);



motherFolder = fullfile('Data',strcat('dataset',datasetNum));
motherFolder2 = fullfile(motherFolder,strcat('k',num2str(k)));
CSVFile = fullfile(motherFolder,strcat('output_dataset',datasetNum,'_new.csv'));
matFile = fullfile(motherFolder2,strcat('dataset',datasetNum,'_k',num2str(k),'.mat'));
tableData = readtable(CSVFile);
labelData = importdata(matFile);

nOfClusters = length(unique(labelData));
nOfCells = length(labelData);
allFileNames = tableData.FileName;
allCellTypes = tableData.ClusterName;
UniqueFileNames = unique(allFileNames,'stable');
UniqueCellTypeNames = unique(allCellTypes,'stable');
nOfFiles = length(UniqueFileNames);
nOfCellTypes = length(UniqueCellTypeNames);

indexFile = 1;
notFound = 1;
while indexFile < nOfFiles && notFound == 1
    if strcmp(UniqueFileNames{indexFile},consideredFileName)
        notFound = 0;
    else    
        indexFile = indexFile+1;
    end
end
% indexFile = 1;

% consideredFileName = UniqueFileNames{indexFile};

T = ismember(allFileNames,consideredFileName);
cx = tableData.X_X(T);
cy = tableData.Y_Y(T);
% cx = max(cx)-cx+1;
% cy = max(cy)-cy+1;
ClusterLabels = labelData(T);

imsize = [ceil(max(cx))+4*memWidth,ceil(max(cy))+4*memWidth];
occupancy_image = zeros(imsize);
occupancy_image(sub2ind(imsize,max(round(cx),1),max(round(cy),1)))=1;

membraneReg = imdilate(occupancy_image,strel('disk',3*memWidth));
membraneReg = ~bwareaopen(~membraneReg,memWidth*memWidth);
[vx,vy]=voronoi(cx,cy);
image_size = size(membraneReg);
CM = membraneReg;
for i =1 : length(vx)
    xc = min(max(round(vx(:,i)),1),image_size(1));
    yc = min(max(round(vy(:,i)),1),image_size(2));
    
    p1 = [xc(1),yc(1)];
    p2 = [xc(2),yc(2)];
    [ind, label] = drawline(p1,p2,image_size);
    CM(ind) = 0;   
end
L = bwlabel(CM,4);
colorBarChart = [230, 25, 75;60, 180, 75;255, 225, 25;0, 130, 200;245, 130, 48;145, 30, 180;70, 240, 240;240, 50, 230;210, 245, 60;250, 190, 212;0, 128, 128;220, 190, 255;170, 110, 40;255, 250, 200;128, 0, 0;170, 255, 195;128, 128, 0;255, 215, 180;0, 0, 128;128, 128, 128;245, 245, 245];
R = colorBarChart(:,1);
G = colorBarChart(:,2);
B = colorBarChart(:,3);
RI = zeros(size(CM,1),size(CM,2));
GI = zeros(size(CM,1),size(CM,2));
BI = zeros(size(CM,1),size(CM,2));
for i = 1 : length(cx)
    curx = round(cx(i));
    cury = round(cy(i));
    
    allInds = find(L==L(curx,cury));
    RI(allInds) = R(mod(ClusterLabels(i)+shift,k)+1);
    GI(allInds) = G(mod(ClusterLabels(i)+shift,k)+1);
    BI(allInds) = B(mod(ClusterLabels(i)+shift,k)+1);
end

alpha = 0.5;
for i =1 : length(vx)
    xc = min(max(round(vx(:,i)),1),image_size(1));
    yc = min(max(round(vy(:,i)),1),image_size(2));
    
    p1 = [xc(1),yc(1)];
    p2 = [xc(2),yc(2)];
    [ind, label] = drawline(p1,p2,image_size);
    RI(ind) = 255-alpha*(255-RI(ind));
    GI(ind) = 255-alpha*(255-GI(ind));
    BI(ind) = 255-alpha*(255-BI(ind));
end

figure;
for i = 1 : k
    hold on;
rectangle('Position',[1,2-12*(i-1),40,10],'FaceColor',[R(mod(i+shift,k)+1),G(mod(i+shift,k)+1),B(mod(i+shift,k)+1)]/255)

text(45,7-12*(i-1),strcat('Cluster ',num2str(i-1)),'Color','black','FontSize',14)

end
axis equal
axis off
set(gcf,'color','w');



mkdir(voronoiResultPath);
exportgraphics(gcf,fullfile(voronoiResultPath,strcat('k_',num2str(k),'_colorbar.pdf')));

RI(membraneReg==0) = 0;
GI(membraneReg==0) = 0;
BI(membraneReg==0) = 0;

finalImage = cat(3, RI,GI,BI)/255.0;

imwrite(finalImage,fullfile(voronoiResultPath,strcat('k_',num2str(k),'_voronoi.png')));
figure;
imshow(finalImage);
