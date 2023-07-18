function dataSet_smooth=smoothing_5G(dataSet, dataSet_interp, interpolationOn)
if(interpolationOn)
    dataSet_smooth = dataSet_interp;
    dataSet_start=dataSet_interp;
else
    dataSet_smooth = dataSet;
    dataSet_start=dataSet;
end

n = size(dataSet_start,1);
c = 3e8;
fc_Hz= 3.5e9; % Hz
desiredParamVector=3:6;
for q=1:length(desiredParamVector)
    desiredParam=desiredParamVector(q);

    %Distance Matrix 
    D = pdist2_haversine(cell2mat(dataSet_start(:,1:2))', cell2mat(dataSet_start(:,1:2))');

    for i = 1:n
        thisPoint = cell2mat(dataSet_start(i,1:2));   % Coordinates of point under consideration
        thisMatrix = dataSet_start{i,3};              % Data matrix for point under consideration
        thisNPCI = thisMatrix(:,[1 2 10]);            % unique NPCIs for point under consideration
        uniquePCIsInPoint=unique(thisNPCI,'rows');

        %Let's find points within 20 lambda from the point
        idx = find(D(i,:) <= 20*(c/fc_Hz)*1e-3);
        paramData = [];
        for j = idx

            for k = 1:size(uniquePCIsInPoint,1)
                thisparamDataFull = dataSet_start{j,3};
                thisparamData = thisparamDataFull(ismember(thisparamDataFull(:,[1 2 10]),uniquePCIsInPoint(k,:),'rows'),desiredParam);
                if isempty(thisparamData)
                    continue
                end
                paramData = [paramData; repmat(j,length(thisparamData),1),repmat(uniquePCIsInPoint(k,:),length(thisparamData),1),thisparamData];
            end
        end
        
        %Mean of parameter values in the set of points within 20 lambda
        paramData_mean = [];
        for k = 1:size(uniquePCIsInPoint,1)
            paramData_mean = [paramData_mean; uniquePCIsInPoint(k,:), mean(paramData(ismember(paramData(:,2:4),uniquePCIsInPoint(k,:),'rows'),5))];
        end

        %Replace the value in the point with the mean value calculated
        %above
        for j = 1:size(paramData,1)
            thisMatrix = dataSet_smooth{paramData(j,1),3};
            thisMatrix(isequal(thisMatrix(:,[1 2 10]),paramData(j,2:4)),desiredParam) = paramData_mean(isequal(paramData_mean(:,1:3),paramData(j,2:4)),4);
            dataSet_smooth{paramData(j,1),3} = thisMatrix;
        end
    end
end