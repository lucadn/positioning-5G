clear
close all;

interpolationOn=true;
smoothingOn=true;
smoothingTotal=false;

%Data loading

activeCampaigns=1:6;
dataFileName=sprintf('Campaign_data_NBIoT');
for i=1:length(activeCampaigns)
    dataFileNameAdd=sprintf('_%d', activeCampaigns(i));
    dataFileName=[dataFileName dataFileNameAdd];
end
dataFileNameRoot=dataFileName;
if(interpolationOn)
    dataFileName=[dataFileName '_interpolated'];
end
if(smoothingOn)
    dataFileName=[dataFileName '_smoothed'];
end
dataFileName=[dataFileName '.mat'];
fExists=exist(dataFileName, 'file');
if(fExists~=2)
    fprintf('Creating data file\n');
    createDataFiles_NBIoT(dataFileNameRoot,dataFileName,activeCampaigns,interpolationOn,smoothingOn);
    fprintf('Data file created\n');
end
load(dataFileName);
fprintf('Data file loaded\n');

%Data loading completed
if(interpolationOn)
    dataSet=dataSet_interp;
end
if(smoothingOn)
    if(smoothingTotal)
        dataSet=dataSet_smooth; %We use the smoothed dataset also for test points
    end
else
    dataSet_smooth=dataSet;
end

operatorChoice=[1 10]; %Vector indicating which operators should be used.
kMax=40; %maximum number of neighbours used in WkNN
nRuns = 40; % number of runs to be used
RF_param_vector= [4]; % [3 = RSSI, 4 = SINR, 5 = RSRP, 6 = RSRQ]

for pCount=1:length(RF_param_vector)
    RF_param=RF_param_vector(pCount);
    percLocated=zeros(1,nRuns);

    % The following code requires the ParforProgress2 code, available at:
    % https://uk.mathworks.com/matlabcentral/fileexchange/35609-matlab-parforprogress2

    try % Initialization
        ppm = ParforProgressStarter2('NB-IoT Positioning', nRuns, 0.1, 0, 1, 1);
    catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
        if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
            error('ParforProgressStarter2 not in path.');
        else
            % this should NEVER EVER happen.
            msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
            msg{2} = me.message;
            print_error_red(msg);
            % backup solution so that we can still continue.
            ppm.increment = nan(1, nRuns);
        end
    end

    parfor k = 1:nRuns
        %for k = 1:nRuns
        [average_error_tmp{1,k},percLocated(1,k),TPs_located, TP_est_location{1,k}]=Wei_Cov_strategy(dataSet, dataSet_smooth, operatorChoice, RF_param, kMax);
        ppm.increment(k);
    end

    try % use try / catch here, since delete(struct) will raise an error.
        delete(ppm);
    catch me
    end

    average_error = NaN(1,kMax);
    nnz(~isnan(cell2mat(average_error_tmp(1,:)')))
    average_error(1,:) = mean(cell2mat(average_error_tmp(1,:)'), 1);


    % saving

    switch RF_param
        case 3
            paramStr='RSSI';
        case 4
            paramStr='SINR';
        case 5
            paramStr='RSRP';
        case 6
            paramStr='RSRQ';
    end
    percLocatedMean=mean(percLocated,2);

    addStr=[];
    if(interpolationOn)
        addStr=[addStr '_Interpolation'];
    end
    if(smoothingOn)
        addStr=[addStr '_Smoothing'];
        if(smoothingTotal)
            addStr=[addStr '_Total'];
        end
    end

    save(['Weighted_Coverage_RF_param_' paramStr '_op_' num2str(operatorChoice) '_'  num2str(nRuns) '_runs' addStr '.mat']);

end
