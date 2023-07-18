function dataSet_interp=interpolation_NBIoT(dataSet)

% select all unique PCIs
uniqueNPCIsList = cell2mat(dataSet(:,3));
uniqueNPCIsList = unique(uniqueNPCIsList(:,[1 2 8]),'rows');


% uniqueNPCIsList is a matrix where each row corresponds to a unique PCI

dataSet_interp = dataSet;
interpolationVariable=3:6;

for j=1:size(uniqueNPCIsList,1)
    targetPCI=uniqueNPCIsList(j,:);
    for l=1:length(interpolationVariable)
        RFparam=interpolationVariable(l);
        tmp = [];
        for i = 1:size(dataSet,1)
            thisMatrix = dataSet{i,3};
            for k = 1:size(thisMatrix,1)
                if thisMatrix(k,[1 2 8]) == targetPCI
                    tmp = [tmp; [i, k, thisMatrix(k,RFparam)]];
                end
            end
        end
        % tmp is a temporary matrix where:
        % - the first column contains the index of the point where the
        % target PCI is found
        % - the second column contains the index of the row containing the data for the PCI
        % - the third column contains the parameter value taken from the
        % original dataset

        % interpolation
        tmp(:,4) = fillmissing(tmp(:,3),'linear');


        % now let's replace the missing values with the interpolated ones
        for i = 1:size(tmp,1)
            dataSet_interp{tmp(i,1),3}(tmp(i,2),RFparam) = tmp(i,4);
        end
    end

end

