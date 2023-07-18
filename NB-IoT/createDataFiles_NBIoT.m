function createDataFiles_NBIoT(dataFileNameRoot, dataFileName,activeCampaigns,interpolationOn,smoothingOn)
    dataFileNameOriginal=[dataFileNameRoot '.mat'];
    fExists=exist(dataFileNameOriginal, 'file');
    if(fExists~=2)
        fprintf('Extracting raw data, please wait...\n');
        [dataSet] =load_and_verify_data_NBIoT(activeCampaigns);
        save(dataFileNameOriginal,"dataSet");
    else
        load(dataFileNameOriginal);
    end
    if(interpolationOn)
        dataFileNameInterp=[dataFileNameRoot '_interpolated.mat'];
        fExists=exist(dataFileNameInterp, 'file');
        if(fExists~=2)
            fprintf('Applying interpolation...\n');
            dataSet_interp=interpolation_NBIoT(dataSet);
            save(dataFileNameInterp,"dataSet","dataSet_interp");
        else
            load(dataFileNameInterp);
        end
    else
        dataSet_interp=[];
    end
    if(smoothingOn)
        fprintf('Applying smoothing...\n');
        dataSet_smooth=smoothing_NBIoT(dataSet, dataSet_interp, interpolationOn);
        save(dataFileName,"dataSet");
        if(interpolationOn)
            save(dataFileName,"dataSet_interp",'-append');
        end
        save(dataFileName,"dataSet_smooth",'-append');
    end
end