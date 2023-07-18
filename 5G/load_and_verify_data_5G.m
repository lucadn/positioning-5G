function [dataSet] = load_and_verify_data_5G(activeCampaigns)

% Constants related to the 5G campaigns in Rome
frequencyOperator1coverage=3725760000;
frequencyOperator2coverage=3649440000;
frequencyOperator3coverage=3442080000;
frequencyOperator4coverage=3542880000;
frequencyOperator5coverage=3604800000;
frequencyOperator6coverage=3630720000;

% Constants related to the 5G campaigns in Rome
frequencyOperator1CIR=3725.76;
frequencyOperator2CIR=3649.44;
frequencyOperator3CIR=3442.08;
frequencyOperator4CIR=3542.88;
frequencyOperator5CIR=3604.80;
frequencyOperator6CIR=3630.72;
frequencyOperator7CIR=791.19;
frequencyOperator8CIR=801.4;
frequencyOperator9CIR=811.3;

Operator1MNC=1;
Operator2MNC=2;
Operator3MNC=3;
Operator4MNC=4;
Operator5MNC=5;
Operator6MNC=6;
Operator7MNC=3;
Operator8MNC=4;
Operator9MNC=5;

MM=[];
MM_CIR=[];

for j=1:length(activeCampaigns)
    campaignID=activeCampaigns(j);
    fName1=sprintf('5G_coverage_C%d.xlsx',activeCampaigns(j));
    fName2=sprintf('5G_RefSig_cir_C%d.xlsx',activeCampaigns(j));
    coverageData = readmatrix(fName1);
    CIRFileData = readmatrix(fName2);
    
    
    % Data not needed in the creation of the data set are simply ignored.
    % RF data
    %-------------------------
    %date = coverageData(:,1);
    %time = coverageData(:,2);
    %UTC = coverageData(:,3);
    latitude = coverageData(:,4);
    longitude = coverageData(:,5);
    %altitude = coverageData(:,6);
    %speed = coverageData(:,7);
    %heading = coverageData(:,8);
    %sat = coverageData(:,9);
    %EARFCN = coverageData(:,10);
    %frequency = coverageData(:,11);
    PCI = coverageData(:,12);
        %MCC = coverageData(:,13);
    MNC_cov = coverageData(:,14);
    SSBIdx = coverageData(:,15);
    %SSBIdxMod8 = coverageData(:,16);
    SSB_RSSI = coverageData(:,17);
    SSS_SINR = coverageData(:,18);
    SSS_RSRP = coverageData(:,19);
    SSS_RSRQ = coverageData(:,20);
    %SSS_RePower = coverageData(:,21);
    
    PPS = coverageData(:,22);
    ToA = coverageData(:,23);
    %MIB_Sfn = coverageData(:,24);
    %MIB_ScsCommon = coverageData(:,25);
    %MIB_SsbSubcarrierOffset = coverageData(:,26);
    %MIB_DmrsTypeAPositionPos3 = coverageData(:,27);
    %MIB_PdcchConfigSib1 = coverageData(:,28);
    %MIB_CellNotBarred= coverageData(:,29);
    %MIB_IntraFreqReselectionNotAllowed=coverageData(:,30);
    eNodeB_ID_cov=zeros(size(coverageData,1),1); %dummy column to keep compatibility with NB-IoT data structure
    
    % CIR data %CHECK ALL INDEXES for 5G
    latitude_CIR = CIRFileData(:,2);
    longitude_CIR = CIRFileData(:,1);
    frequency_CIR = CIRFileData(:,8);
    PCI_CIR = CIRFileData(:,4);
    %MNC_CIR=CIRFileData(:,14);
    SSBIdx_CIR = CIRFileData(:,5);
    %SSBIdxMod8 = CIRFileData(:,16);
    eNodeB_ID_CIR=zeros(size(CIRFileData,1),1); %dummy column to keep compatibility with NB-IoT data structure
    ToA_CIR=CIRFileData(:,9)-CIRFileData(:,10);
    
    %%%% operator ID in RF data%%%%
    operatorID1Indexes=(MNC_cov==Operator1MNC);
    operatorID2Indexes=(MNC_cov==Operator2MNC);
    operatorID3Indexes=(MNC_cov==Operator3MNC);
    operatorID4Indexes=(MNC_cov==Operator4MNC);
    operatorID5Indexes=(MNC_cov==Operator5MNC);
    operatorID6Indexes=(MNC_cov==Operator6MNC);
    operatorIDcoverage=zeros(size(MNC_cov,1),1);
    operatorIDcoverage(operatorID1Indexes)=1;
    operatorIDcoverage(operatorID2Indexes)=2;
    operatorIDcoverage(operatorID3Indexes)=3;
    operatorIDcoverage(operatorID4Indexes)=4;
    operatorIDcoverage(operatorID5Indexes)=5;
    operatorIDcoverage(operatorID6Indexes)=6;
    
        %%%% operator ID in ToA data%%%%
    operatorID1CIRIndexes=(frequency_CIR==frequencyOperator1CIR);
    operatorID2CIRIndexes=(frequency_CIR==frequencyOperator2CIR);
    operatorID3CIRIndexes=(frequency_CIR==frequencyOperator3CIR);
    operatorID4CIRIndexes=(frequency_CIR==frequencyOperator4CIR);
    operatorID5CIRIndexes=(frequency_CIR==frequencyOperator5CIR);
    operatorID6CIRIndexes=(frequency_CIR==frequencyOperator6CIR);
    operatorID7CIRIndexes=(frequency_CIR==frequencyOperator7CIR);
    operatorID8CIRIndexes=(frequency_CIR==frequencyOperator8CIR);
    operatorID9CIRIndexes=(frequency_CIR==frequencyOperator9CIR);
    operatorID_CIR=zeros(size(frequency_CIR,1),1);
    operatorID_CIR(operatorID1CIRIndexes)=Operator1MNC;
    operatorID_CIR(operatorID2CIRIndexes)=Operator2MNC;
    operatorID_CIR(operatorID3CIRIndexes)=Operator3MNC;
    operatorID_CIR(operatorID4CIRIndexes)=Operator4MNC;
    operatorID_CIR(operatorID5CIRIndexes)=Operator5MNC;
    operatorID_CIR(operatorID6CIRIndexes)=Operator6MNC;
    operatorID_CIR(operatorID7CIRIndexes)=Operator7MNC;
    operatorID_CIR(operatorID8CIRIndexes)=Operator8MNC;
    operatorID_CIR(operatorID9CIRIndexes)=Operator9MNC;


    % create a temporary structure for coverage data including:
    % 1 latitude
    % 2 longitude
    % 3 PCI
    % 4 eNodeB ID
    % 5 average RSSI (over Tx0 and Tx1)
    % 6 average NSINR (over Tx0 and Tx1)
    % 7 average NRSRP (over Tx0 and Tx1)
    % 8 average NRSRQ (over Tx0 and Tx1)
    % 9 operator ID
    % 10 campaign ID
    campaignIDVector = campaignID*ones(size(latitude,1),1);
    MM=[MM;[latitude longitude PCI SSBIdx SSB_RSSI SSS_SINR SSS_RSRP SSS_RSRQ PPS ToA operatorIDcoverage campaignIDVector]];
    
    % create a temporary structure for CIR data including:
    % 1 latitude
    % 2 longitude
    % 3 NPCI
    % 4 eNodeB ID
    % 5 ToA
    % 6 operator ID
    % 7 campaign ID
    campaignIDVector_CIR = campaignID*ones(size(latitude_CIR,1),1);
    MM_CIR=[MM_CIR;[latitude_CIR longitude_CIR PCI_CIR SSBIdx_CIR ToA_CIR operatorID_CIR campaignIDVector_CIR]];

end

% We extracted all the data we need from all the campaigns we are interested
% in. Let's combine RF and ToA data and clean things up

% Find the unique locations for RF data
[uniqueLocations,~,ic11] = unique(MM(:,[1 2]), 'rows','stable');

% Find the unique locations for ToA data
[uniqueLocations_CIR,~,ic11_CIR] = unique(MM_CIR(:,[1 2]), 'rows','stable');

additionalLocations=uniqueLocations_CIR(~ismember(uniqueLocations_CIR,uniqueLocations,'rows'),:);

% Check that the two sets of unique locations match, otherwise we give up
checkDataConsistence=(uniqueLocations==uniqueLocations_CIR);

if ~all(checkDataConsistence,'all')
    fprintf('Error, coverage and CIR data locations do not match\n')
    return
end

% Combine all data related to the same unique location in a single entry of
% a new temporary data structure for the RF data
covData = accumarray(ic11, (1:size(MM,1)).', [], @(x){MM(x,3:12)});

% Same thing for the ToA data
CIRData=accumarray(ic11_CIR, (1:size(MM_CIR,1)).', [], @(x){MM_CIR(x,3:7)});

% Delete the temporary structure used to extract the data for the active
% campaigns, we won't need it anymore
%clear MM MM_CIR

% We now have a data structure that,
% for each unique location, lists PCI, measurements, operator ID and
% campaign ID. But these entries could be repeated, either within a
% campaign, if the same PCI was detected multiple times at the same
% location (very likely), or across campaigns, if two or more campaigns took measurements
% in the same location (extremely unlikely).

% Last step: we associate to each unique location a cell row with the following data:
% 1 - latitude
% 2 - longitude
% 3 - a matrix that contains for each row the following info:
%     PCI; SSB_Index; SSB_RSSI; SSS_SINR; SSS_RSRP; SSS_RSRQ; PPS; ToA; operatorID; campaignID
% 4 - a scalar that reports the number of PCIs with RF data for operator 1
% 5 - a logical column vector that has 1s at positions of the matrix containing a PCI with RF data for operator 1
% 6 - a scalar that reports the number of PCIs with RF data for operator 2
% 7 - a logical column vector that has 1s at positions of the matrix containing a PCI with RF data for operator 2
% 8 - a scalar that reports the number of PCIs with ToA data for operator 1
% 9 - a logical column vector that has 1s at positions of the matrix containing a PCI with ToA data for operator 1
% 10 - a scalar that reports the number of PCIs with ToA data for operator 2
% 11 - a logical column vector that has 1s at positions of the matrix containing a PCI with ToA data for operator 2
% 12 - a column vector that contans the list of campaign IDs that contributed to the data in the location
%covDataClean=cell( size(covData,1), size(covData,2));
%CIRDataClean=cell( size(CIRData,1), size(CIRData,2));
dataSet=cell(size(covData,1), 11);
totalPCIcov=[];
totalPCICIR=[];

for i=1:size(uniqueLocations,1)
    dataSet{i,1}=uniqueLocations(i,1);
    dataSet{i,2}=uniqueLocations(i,2);
    % We remove repetitions for RF data introduced within each campaign, paying
    % attention not to mix data for different operators and campaigns.
    % For RF measurements collected in the same PCI, the average value is stored.
    [uniquePCIcov,~,idList]=unique(covData{i,1}(:,[1 2 9 10]), 'rows');
    RSSI=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,3))});
    SINR=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,4))});
    RSRP=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,5))});
    RSRQ=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,6))});
    PPS=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,7))});
    CIR=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,8))});
    covDataClean=[uniquePCIcov(:,1),uniquePCIcov(:,2),cell2mat(RSSI),cell2mat(SINR),cell2mat(RSRP),cell2mat(RSRQ),cell2mat(PPS),cell2mat(CIR),uniquePCIcov(:,3),uniquePCIcov(:,4)];
    totalPCIcov=[totalPCIcov;uniquePCIcov];

    % We remove repetitions for ToA data introduced within each campaign, paying
    % attention not to mix data for different operators and campaigns.
    % For ToA measurements collected in the same NPCI, the minimum value is stored.
    [uniquePCICIR,~,idList]=unique(CIRData{i,1}(:,[1 2 4 5 ]), 'rows');
    ToA_CIR=accumarray(idList, (1:size(CIRData{i,1},1)).', [], @(x){min(CIRData{i,1}(x,3))});
    CIRDataClean=[uniquePCICIR(:,1:2),cell2mat(ToA_CIR),uniquePCICIR(:,3:4)];
    totalPCICIR=[totalPCICIR;uniquePCICIR];
    if size(uniquePCIcov,1)==size(uniquePCICIR,1) && all(uniquePCIcov==uniquePCICIR,'all')
        % We are lucky, the same exact set of PCIs was detected for RF and ToA;
        % we just merge them in a single matrix.
        dataSet{i,3}=[covDataClean(:,1:8),CIRDataClean(:,3:5)];
    else
        % Not all PCIs detected in RF data were also detected in ToA data
        % (or viceversa): we add NaN entries in each submatrix, and then we
        % merge them. Each unique PCIs will still correspond to a single row, in which there will be NaN
        % values in positions corresponding to the missing data (either RF or ToA) or no NaNs if both RF and ToA
        % data are available.
        extendedDatacov=[covDataClean(:,1:8) NaN(size(covDataClean,1),1) covDataClean(:,9:10)];
        extendedDataCIR=[CIRDataClean(:,1:2) NaN(size(CIRDataClean,1),6) CIRDataClean(:,3:5)];
        extendedData=[extendedDatacov;extendedDataCIR];
        [uniquejointPCI,~,idListJoint]=unique(extendedData(:,[1 2 10 11 ]), 'rows');
        extendedRSSI=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,3))});
        extendedSINR=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,4))});
        extendedRSRP=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,5))});
        extendedRSRQ=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,6))});
        extendedPPS=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,7))});
        extendedCIR=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,8))});
        extendedToA_CIR=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,9))});
        dataSet{i,3}=[uniquejointPCI(:,1:2), cell2mat(extendedRSSI),cell2mat(extendedSINR),cell2mat(extendedRSRP),cell2mat(extendedRSRQ),cell2mat(extendedPPS),cell2mat(extendedCIR),cell2mat(extendedToA_CIR),uniquejointPCI(:,3:4)];   
    end
    
    % We fill in the other cells in the cell row for this unique location
    PCI_ToA_Operator_1=~isnan(dataSet{i,3}(:,9)) & (dataSet{i,3}(:,10)==Operator1MNC);
    N_PCI_ToA_Operator_1=nnz(PCI_ToA_Operator_1);
    PCI_RF_Operator_1=~isnan(dataSet{i,3}(:,3))  & (dataSet{i,3}(:,10)==Operator1MNC);%We check RSSI, assuming that if RSSI is not NaN this is true for all RF parameters
    N_PCI_RF_Operator_1=nnz(PCI_RF_Operator_1);
    PCI_ToA_Operator_2=~isnan(dataSet{i,3}(:,9)) & (dataSet{i,3}(:,10)==Operator2MNC);
    N_PCI_ToA_Operator_2=nnz(PCI_ToA_Operator_2);
    PCI_RF_Operator_2=~isnan(dataSet{i,3}(:,3))  & (dataSet{i,3}(:,10)==Operator2MNC);%We check CIR, since PPS is not always there
    N_PCI_RF_Operator_2=nnz(PCI_RF_Operator_2);
    dataSet{i,4}=N_PCI_RF_Operator_1;
    dataSet{i,5}=PCI_RF_Operator_1;
    dataSet{i,6}=N_PCI_ToA_Operator_1;
    dataSet{i,7}=PCI_ToA_Operator_1;
    dataSet{i,8}=N_PCI_RF_Operator_2;
    dataSet{i,9}=PCI_RF_Operator_2;
    dataSet{i,10}=N_PCI_ToA_Operator_2;
    dataSet{i,11}=PCI_ToA_Operator_2;
    [dataSet{i,12},~,~]=unique(dataSet{i,3}(:,11), 'rows');

end

end
