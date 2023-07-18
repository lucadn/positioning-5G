function [dataSet, eNodeB_best_pos_estimates, eNodeB_mean_pos_estimates, max_Vector_Op_1,sum_abs_Vector_Op_1,sum_sq_Vector_Op_1, max_Vector_Op_2, sum_abs_Vector_Op_2,sum_sq_Vector_Op_2,max_Vector_Op_3, sum_abs_Vector_Op_3,sum_sq_Vector_Op_3] = load_and_verify_data_NBIoT(activeCampaigns)

% Constants related to the campaign in Rome
frequencyOperator1coverage=801402500;
frequencyOperator2coverage=811297500;
frequencyOperator3coverage=791192500;
Operator1MNC=1;
Operator2MNC=10;
Operator3MNC=88;
frequencyOperator1CIR=801.4;
frequencyOperator2CIR=811.3;
frequencyOperator3CIR=791.19;

MM=[];
MM_CIR=[];


% Let's read the list of eNodeBs provided with the data. We will use this
% information to check the campaign data and fill in gaps
eNodeBData = readmatrix('eNodeB_list_NBIoT.xlsx');
MNC_eNodeB_list=eNodeBData(:,14);
NPCI_eNodeB_list=eNodeBData(:,18);
eNodeID_eNodeB_list=eNodeBData(:,2);
latitude_list=eNodeBData(:,3);
longitude_list=eNodeBData(:,4);
l1_error=eNodeBData(:,6);
l2_error=eNodeBData(:,7);

%Let's create a list of towers with estimated position.
eNodeB_best_pos_estimates=[];
eNodeB_mean_pos_estimates=[];
known_NPCI_list=[NPCI_eNodeB_list MNC_eNodeB_list eNodeID_eNodeB_list];
known_towers_list=[NPCI_eNodeB_list MNC_eNodeB_list eNodeID_eNodeB_list latitude_list longitude_list l1_error l2_error mean([l1_error, l2_error],2)];
[unique_eNodeB_list,ia,ic]=unique(known_towers_list(:,3),'rows');
for i=1:length(unique_eNodeB_list)
    if(unique_eNodeB_list(i)>0)
        relevantEntries=(known_towers_list(:,3)==unique_eNodeB_list(i) & known_towers_list(:,4)>0 & known_towers_list(:,4)>0);
        if any(relevantEntries)
            estimates=known_towers_list(relevantEntries,:);
            [~,bestEstimateIndex]=min(estimates(:,8));
            bestEstimate=estimates(bestEstimateIndex,3:5);
            meanEstimate=[estimates(1,3) mean(estimates(:,4)) mean(estimates(:,5))];
            eNodeB_best_pos_estimates=[eNodeB_best_pos_estimates;bestEstimate];
            eNodeB_mean_pos_estimates=[eNodeB_mean_pos_estimates;meanEstimate];
        end
    end
end

%First, remove duplicates, just in case the list is not clean
[unique_NPCI_eNodeB]=unique(known_NPCI_list,'rows');

%Retrieve list of NPCIs appearing only once in the list, and corresponding MNC
idp = diff(unique_NPCI_eNodeB(:,1))>0;
unique_NPCI_indexes_eNodeB=[true;idp]&[idp;true];
unique_NPCI_IDs_eNodeB=unique_NPCI_eNodeB(unique_NPCI_indexes_eNodeB,1);
MNC_for_unique_NPCI_eNodeB=unique_NPCI_eNodeB(unique_NPCI_indexes_eNodeB,2);
eNodeBID_for_unique_NPCI_eNodeB=unique_NPCI_eNodeB(unique_NPCI_indexes_eNodeB,3);
%Retrieve list of NPCIs appearing twice or more: different operators, or different
%cells for the same operator due to NPCI reuse
shared_NPCI_indexes_eNodeB=setdiff(1:size(unique_NPCI_eNodeB,1),unique_NPCI_indexes_eNodeB);
shared_NPCI_IDs_eNodeB=unique(unique_NPCI_eNodeB(shared_NPCI_indexes_eNodeB,1));

unique_NPCI_eNodeB_Op1=unique_NPCI_eNodeB(find(unique_NPCI_eNodeB(:,2)==Operator1MNC),:);
unique_NPCI_eNodeB_Op2=unique_NPCI_eNodeB(find(unique_NPCI_eNodeB(:,2)==Operator2MNC),:);
unique_NPCI_eNodeB_Op3=unique_NPCI_eNodeB(find(unique_NPCI_eNodeB(:,2)==Operator3MNC),:);

for j=1:length(activeCampaigns)
    campaignID=activeCampaigns(j);
    fName1=sprintf('NB-IoT_coverage_C%d.xlsx',activeCampaigns(j));
    fName2=sprintf('NB-IoT_RefSig_cir_C%d.xlsx',activeCampaigns(j));
    %fName3=sprintf('eNodeB_list.csv',activeCampaigns(j));
    coverageData = readmatrix(fName1);
    CIRData = readmatrix(fName2);
    %eNodeBData = readmatrix(fName3);
    
    
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
    frequency = coverageData(:,11);
    NPCI = coverageData(:,12);
    %MCC = coverageData(:,13);
    MNC_cov = coverageData(:,14);
    %TAC = coverageData(:,15);
    %CI = coverageData(:,16);
    eNodeB_ID_cov = coverageData(:,17);
    %cellID = coverageData(:,18);
    RSSI_Tx0 = coverageData(:,19);
    RSSI_Tx1 = coverageData(:,20);
    NSINR_Tx0 = coverageData(:,21);
    NSINR_Tx1 = coverageData(:,22);
    NRSRP_Tx0 = coverageData(:,23);
    NRSRP_Tx1 = coverageData(:,24);
    NRSRQ_Tx0 = coverageData(:,25);
    NRSRQ_Tx1 = coverageData(:,26);
    %NSSS_power = coverageData(:,27);
    %NSSS_RSSI = coverageData(:,28);
    %NSSS_CINR = coverageData(:,29);
    
    % ToA data
    latitude_CIR = CIRData(:,3);
    longitude_CIR = CIRData(:,4);
    frequency_CIR = CIRData(:,10);
    NPCI_CIR = CIRData(:,15);
    MNC_CIR=CIRData(:,14);
    eNodeB_ID_CIR=CIRData(:,8);
    ToA=CIRData(:,12)-CIRData(:,18);
    % Before returning the data, we need to do a few sanity checks and fill
    % in gaps on MNC and eNodeB_ID data values
    
    %[unique_NPCI_cov,ia,ic]=unique(NPCI);
    %Step 1: we use the list of NPCIs provided with the data
    for i=1:length(unique_NPCI_IDs_eNodeB)
        relevantEntriesCov=(NPCI==unique_NPCI_IDs_eNodeB(i))&isnan(MNC_cov);
        MNC_cov(relevantEntriesCov)=MNC_for_unique_NPCI_eNodeB(i);
        eNodeB_ID_cov(relevantEntriesCov)=eNodeBID_for_unique_NPCI_eNodeB(i);
        relevantEntriesCIR=(NPCI_CIR==unique_NPCI_IDs_eNodeB(i))&isnan(MNC_CIR);
        MNC_CIR(relevantEntriesCIR)=MNC_for_unique_NPCI_eNodeB(i);
        eNodeB_ID_CIR(relevantEntriesCIR)=eNodeBID_for_unique_NPCI_eNodeB(i);
    end
    %Step 2: we use the frequency information to infer the operator and
    %fill in the gaps
    for i=1:length(shared_NPCI_IDs_eNodeB)
        %MNC
        relevantEntriesOp1Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_cov)&frequency==frequencyOperator1coverage;
        relevantEntriesOp2Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_cov)&frequency==frequencyOperator2coverage;
        relevantEntriesOp3Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_cov)&frequency==frequencyOperator3coverage;
        MNC_cov(relevantEntriesOp1Cov)=Operator1MNC;
        MNC_cov(relevantEntriesOp2Cov)=Operator2MNC;
        MNC_cov(relevantEntriesOp3Cov)=Operator3MNC;
        
        relevantEntriesOp1CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_CIR)&frequency_CIR==frequencyOperator1CIR;
        relevantEntriesOp2CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_CIR)&frequency_CIR==frequencyOperator2CIR;
        relevantEntriesOp3CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(MNC_CIR)&frequency_CIR==frequencyOperator3CIR;
        MNC_CIR(relevantEntriesOp1CIR)=Operator1MNC;
        MNC_CIR(relevantEntriesOp2CIR)=Operator2MNC;
        MNC_CIR(relevantEntriesOp3CIR)=Operator3MNC;
        
        %eNodeBID
%         if shared_NPCI_IDs_eNodeB(i)==6
%             fprintf('Stop\n')
%         end
        relevantEntriesOp1Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_cov)&frequency==frequencyOperator1coverage;
        knownEntriesOp1Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_cov)&frequency==frequencyOperator1coverage;
        uniqueKnownEntriesOp1Cov=unique(eNodeB_ID_cov(knownEntriesOp1Cov));
        if length(uniqueKnownEntriesOp1Cov)==1
            eNodeB_ID_cov(relevantEntriesOp1Cov)=uniqueKnownEntriesOp1Cov(1);
        else
            if isempty(uniqueKnownEntriesOp1Cov)
                entriesForOp1=unique_NPCI_eNodeB_Op1(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp1)==1
                    eNodeB_ID_cov(relevantEntriesOp1Cov)=unique_NPCI_eNodeB_Op1(find(entriesForOp1),3);
                end
            end
        end
        relevantEntriesOp2Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_cov)&frequency==frequencyOperator2coverage;
        knownEntriesOp2Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_cov)&frequency==frequencyOperator2coverage;
        uniqueKnownEntriesOp2Cov=unique(eNodeB_ID_cov(knownEntriesOp2Cov));
        if length(uniqueKnownEntriesOp2Cov)==1
            eNodeB_ID_cov(relevantEntriesOp2Cov)=uniqueKnownEntriesOp2Cov(1);
        else
            if isempty(uniqueKnownEntriesOp2Cov)
                entriesForOp2=unique_NPCI_eNodeB_Op2(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp2)==1
                    eNodeB_ID_cov(relevantEntriesOp2Cov)=unique_NPCI_eNodeB_Op2(find(entriesForOp2),3);
                end
            end
        end
        
        relevantEntriesOp3Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_cov)&frequency==frequencyOperator3coverage;
        knownEntriesOp3Cov=(NPCI==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_cov)&frequency==frequencyOperator3coverage;
        uniqueKnownEntriesOp3Cov=unique(eNodeB_ID_cov(knownEntriesOp3Cov));
        if length(uniqueKnownEntriesOp3Cov)==1
            eNodeB_ID_cov(relevantEntriesOp3Cov)=uniqueKnownEntriesOp3Cov(1);
        else
            if isempty(uniqueKnownEntriesOp3Cov)
                entriesForOp3=unique_NPCI_eNodeB_Op3(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp3)==1
                    eNodeB_ID_cov(relevantEntriesOp3Cov)=unique_NPCI_eNodeB_Op3(find(entriesForOp3),3);
                end
            end
        end

        relevantEntriesOp1CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator1CIR;
        knownEntriesOp1CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator1CIR;
        uniqueKnownEntriesOp1CIR=unique(eNodeB_ID_CIR(knownEntriesOp1CIR));
        if length(uniqueKnownEntriesOp1CIR)==1
            eNodeB_ID_CIR(relevantEntriesOp1CIR)=uniqueKnownEntriesOp1CIR(1);
        else
            if isempty(uniqueKnownEntriesOp1CIR)
                entriesForOp1=unique_NPCI_eNodeB_Op1(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp1)==1
                    eNodeB_ID_CIR(relevantEntriesOp1CIR)=unique_NPCI_eNodeB_Op1(find(entriesForOp1),3);
                end
            end
        end
        relevantEntriesOp2CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator2CIR;
        knownEntriesOp2CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator2CIR;
        uniqueKnownEntriesOp2CIR=unique(eNodeB_ID_CIR(knownEntriesOp2CIR));
        if length(uniqueKnownEntriesOp2CIR)==1
            eNodeB_ID_CIR(relevantEntriesOp2CIR)=uniqueKnownEntriesOp2CIR(1);
        else
            if isempty(uniqueKnownEntriesOp2CIR)
                entriesForOp2=unique_NPCI_eNodeB_Op2(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp2)==1
                    eNodeB_ID_CIR(relevantEntriesOp2CIR)=unique_NPCI_eNodeB_Op2(find(entriesForOp2),3);
                end
            end
        end
        relevantEntriesOp3CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator3CIR;
        knownEntriesOp3CIR=(NPCI_CIR==shared_NPCI_IDs_eNodeB(i))&~isnan(eNodeB_ID_CIR)&frequency_CIR==frequencyOperator3CIR;
        uniqueKnownEntriesOp3CIR=unique(eNodeB_ID_CIR(knownEntriesOp3CIR));
        if length(uniqueKnownEntriesOp3CIR)==1
            eNodeB_ID_CIR(relevantEntriesOp3CIR)=uniqueKnownEntriesOp3CIR(1);
        else
            if isempty(uniqueKnownEntriesOp3CIR)
                entriesForOp3=unique_NPCI_eNodeB_Op3(:,1)==shared_NPCI_IDs_eNodeB(i);
                if nnz(entriesForOp3)==1
                    eNodeB_ID_CIR(relevantEntriesOp3CIR)=unique_NPCI_eNodeB_Op3(find(entriesForOp3),3);
                end
            end
        end
    end
   
    
    % Fill empty cells for RF data collected by Tx0 & Tx1 replicating the
    % data in one cell into the empty one
    
    for i = 1:length(RSSI_Tx0)
        if isnan(RSSI_Tx0(i,1))
            RSSI_Tx0(i,1)=RSSI_Tx1(i,1);
        end
        if isnan(RSSI_Tx1(i,1))
            RSSI_Tx1(i,1)=RSSI_Tx0(i,1);
        end
    end
    
    for i = 1:length(NRSRP_Tx0)
        if isnan(NRSRP_Tx0(i,1))
            NRSRP_Tx0(i,1)=NRSRP_Tx1(i,1);
        end
        if isnan(NRSRP_Tx1(i,1))
            NRSRP_Tx1(i,1)=NRSRP_Tx0(i,1);
        end
    end
    
    for i = 1:length(NRSRQ_Tx0)
        if isnan(NRSRQ_Tx0(i,1))
            NRSRQ_Tx0(i,1)=NRSRQ_Tx1(i,1);
        end
        if isnan(NRSRQ_Tx1(i,1))
            NRSRQ_Tx1(i,1)=NRSRQ_Tx0(i,1);
        end
    end
    
    for i = 1:length(NSINR_Tx0)
        if isnan(NSINR_Tx0(i,1))
            NSINR_Tx0(i,1)=NSINR_Tx1(i,1);
        end
        if isnan(NSINR_Tx1(i,1))
            NSINR_Tx1(i,1)=NSINR_Tx0(i,1);
        end
    end
    
    % Average RF data over the two receivers
    RSSI_avg = mean([RSSI_Tx0, RSSI_Tx1],2);
    NSINR_avg = mean([NSINR_Tx0, NSINR_Tx1],2);
    NRSRP_avg = mean([NRSRP_Tx0, NRSRP_Tx1],2);
    NRSRQ_avg = mean([NRSRQ_Tx0, NRSRQ_Tx1],2);
    
    
    %%%% operator ID in RF data%%%%
    operatorID1Indexes=(MNC_cov==Operator1MNC);
    operatorID2Indexes=(MNC_cov==Operator2MNC);
    operatorID3Indexes=(MNC_cov==Operator3MNC);
    operatorIDcoverage=zeros(size(MNC_cov,1),1);
    operatorIDcoverage(operatorID1Indexes)=1;
    operatorIDcoverage(operatorID2Indexes)=10;
    operatorIDcoverage(operatorID3Indexes)=88;
    
    %%%% operator ID in ToA data%%%%
    operatorID1CIRIndexes=(MNC_CIR==Operator1MNC);
    operatorID2CIRIndexes=(MNC_CIR==Operator2MNC);
    operatorID3CIRIndexes=(MNC_CIR==Operator3MNC);
    operatorID_CIR=zeros(size(MNC_CIR,1),1);
    operatorID_CIR(operatorID1CIRIndexes)=1;
    operatorID_CIR(operatorID2CIRIndexes)=10;
    operatorID_CIR(operatorID3CIRIndexes)=88;
    
    % create a temporary structure for coverage data including:
    % 1 latitude
    % 2 longitude
    % 3 NPCI
    % 4 eNodeB ID
    % 5 average RSSI (over Tx0 and Tx1)
    % 6 average NSINR (over Tx0 and Tx1)
    % 7 average NRSRP (over Tx0 and Tx1)
    % 8 average NRSRQ (over Tx0 and Tx1)
    % 9 operator ID
    % 10 campaign ID
    campaignIDVector = campaignID*ones(size(latitude,1),1);
    MM=[MM;[latitude longitude NPCI eNodeB_ID_cov RSSI_avg NSINR_avg NRSRP_avg NRSRQ_avg operatorIDcoverage campaignIDVector]];
    
    % create a temporary structure for ToA data including:
    % 1 latitude
    % 2 longitude
    % 3 NPCI
    % 4 eNodeB ID
    % 5 ToA
    % 6 operator ID
    % 7 campaign ID
    campaignIDVector_CIR = campaignID*ones(size(latitude_CIR,1),1);
    MM_CIR=[MM_CIR;[latitude_CIR longitude_CIR NPCI_CIR eNodeB_ID_CIR ToA operatorID_CIR campaignIDVector_CIR]];
end

% We extracted all the data we need from all the campaigns we are interested
% in. Let's combine RF and ToA data and clean things up

% Find the unique locations for RF data
[uniqueLocations,~,ic11] = unique(MM(:,[1 2]), 'rows','stable');

% Find the unique locations for ToA data
[uniqueLocations_CIR,~,ic11_CIR] = unique(MM_CIR(:,[1 2]), 'rows','stable');

% Check that the two sets of unique locations match, otherwise we give up
checkDataConsistence=(uniqueLocations==uniqueLocations_CIR);

if ~all(checkDataConsistence,'all')
    fprintf('Error, coverage and CIR data locations do not match\n')
    return
end

% Combine all data related to the same unique location in a single entry of
% a new temporary data structure for the RF data
covData = accumarray(ic11, (1:size(MM,1)).', [], @(x){MM(x,3:10)});

% Same thing for the ToA data
CIRData=accumarray(ic11_CIR, (1:size(MM_CIR,1)).', [], @(x){MM_CIR(x,3:7)});

% Delete the temporary structures used to extract the data for the active
% campaigns, we won't need them anymore
clear MM MM_CIR

% We now have two data structures (one for RF and one for ToA) that,
% for each unique location, list NPCI, measurements, operator ID and
% campaign ID. But these entries could be repeated, either within a
% campaign, if the same NPCI was detected multiple times at the same
% location (very likely), or across campaigns, if two or more campaigns took measurements
% in the same location (extremely unlikely).

% Last step: we associate to each unique location a cell row with the following data:
% 1 - latitude
% 2 - longitude
% 3 - a matrix that contains for each row the following info: NPCI; eNodeB ID; RSSI; NSINR; NRSRP; NRSRQ; ToA; operatorID; campaignID
% 4 - a scalar that reports the number of NPCIs with RF data for operator 1
% 5 - a logical column vector that has 1s at positions of the matrix containing a NPCI with RF data for operator 1
% 6 - a scalar that reports the number of NPCIs with ToA data for operator 1
% 7 - a logical column vector that has 1s at positions of the matrix containing a NPCI with ToA data for operator 1
% 8 - a scalar that reports the number of NPCIs with RF data for operator 2
% 9 - a logical column vector that has 1s at positions of the matrix containing a NPCI with RF data for operator 2
% 10 - a scalar that reports the number of NPCIs with ToA data for operator 2
% 11 - a logical column vector that has 1s at positions of the matrix containing a NPCI with ToA data for operator 2
% 12 - a scalar that reports the number of NPCIs with RF data for operator 3
% 13 - a logical column vector that has 1s at positions of the matrix containing a NPCI with RF data for operator 3
% 14 - a scalar that reports the number of NPCIs with ToA data for operator 3
% 15 - a logical column vector that has 1s at positions of the matrix containing a NPCI with ToA data for operator 3
% 16 - a column vector that contans the list of campaign IDs that contributed to the data in the location
%covDataClean=cell( size(covData,1), size(covData,2));
%CIRDataClean=cell( size(CIRData,1), size(CIRData,2));
dataSet=cell( size(CIRData,1), 9);
totalNPCIcov=[];
totalNPCICIR=[];
max_RSSI_Op_1=-160;
max_SINR_Op_1=-40;
max_RSRP_Op_1=-160;
max_RSRQ_Op_1=-40;
max_ToA_Op_1=0;
max_RSSI_Op_2=-160;
max_SINR_Op_2=-40;
max_RSRP_Op_2=-160;
max_RSRQ_Op_2=-40;
max_ToA_Op_2=0;
max_RSSI_Op_3=-160;
max_SINR_Op_3=-40;
max_RSRP_Op_3=-160;
max_RSRQ_Op_3=-40;
max_ToA_Op_3=0;
sum_abs_RSSI_Op_1=0;
sum_abs_SINR_Op_1=0;
sum_abs_RSRP_Op_1=0;
sum_abs_RSRQ_Op_1=0;
sum_sq_RSSI_Op_1=0;
sum_sq_SINR_Op_1=0;
sum_sq_RSRP_Op_1=0;
sum_sq_RSRQ_Op_1=0;
sum_abs_ToA_Op_1=0;
sum_sq_ToA_Op_1=0;

sum_abs_RSSI_Op_2=0;
sum_abs_SINR_Op_2=0;
sum_abs_RSRP_Op_2=0;
sum_abs_RSRQ_Op_2=0;
sum_sq_RSSI_Op_2=0;
sum_sq_SINR_Op_2=0;
sum_sq_RSRP_Op_2=0;
sum_sq_RSRQ_Op_2=0;
sum_abs_ToA_Op_2=0;
sum_sq_ToA_Op_2=0;

sum_abs_RSSI_Op_3=0;
sum_abs_SINR_Op_3=0;
sum_abs_RSRP_Op_3=0;
sum_abs_RSRQ_Op_3=0;
sum_sq_RSSI_Op_3=0;
sum_sq_SINR_Op_3=0;
sum_sq_RSRP_Op_3=0;
sum_sq_RSRQ_Op_3=0;
sum_abs_ToA_Op_3=0;
sum_sq_ToA_Op_3=0;


for i=1:size(uniqueLocations,1)
    dataSet{i,1}=uniqueLocations(i,1);
    dataSet{i,2}=uniqueLocations(i,2);
    % We remove repetitions for RF data introduced within each campaign, paying
    % attention not to mix data for different operators and campaigns.
    % For RF measurements collected in the same NPCI, the average value is stored.
    [uniqueNPCIcov,~,idList]=unique(covData{i,1}(:,[1 2 7 8 ]), 'rows');
    RSSI=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,3))});
    NSINR=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,4))});
    NRSRP=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,5))});
    NRSRQ=accumarray(idList, (1:size(covData{i,1},1)).', [], @(x){mean(covData{i,1}(x,6))});
    covDataClean=[uniqueNPCIcov(:,1),uniqueNPCIcov(:,2),cell2mat(RSSI),cell2mat(NSINR),cell2mat(NRSRP),cell2mat(NRSRQ),uniqueNPCIcov(:,3),uniqueNPCIcov(:,4)];
    totalNPCIcov=[totalNPCIcov;uniqueNPCIcov];
    % We remove repetitions for ToA data introduced within each campaign, paying
    % attention not to mix data for different operators and campaigns.
    % For ToA measurements collected in the same NPCI, the minimum value is stored.
    [uniqueNPCICIR,~,idList]=unique(CIRData{i,1}(:,[1 2 4 5 ]), 'rows');
    ToA=accumarray(idList, (1:size(CIRData{i,1},1)).', [], @(x){min(CIRData{i,1}(x,3))});
    CIRDataClean=[uniqueNPCICIR(:,1:2),cell2mat(ToA),uniqueNPCICIR(:,3:4)];
    totalNPCICIR=[totalNPCICIR;uniqueNPCICIR];
    if size(uniqueNPCIcov,1)==size(uniqueNPCICIR,1) && all(uniqueNPCIcov==uniqueNPCICIR,'all')
        % We are lucky, the same exact set of NPCIs was detected for RF and ToA;
        % we just merge them in a single matrix.
        dataSet{i,3}=[covDataClean(:,1:6),CIRDataClean(:,3:5)];
    else
        % Not all NPCIs detected in RF data were also detected in ToA data
        % (or viceversa): we add NaN entries in each submatrix, and then we
        % merge them. Each unique NPCIs will still correspond to a single row, in which there will be NaN
        % values in positions corresponding to the missing data (either RF or ToA) or no NaNs if both RF and ToA
        % data are available.
        extendedDatacov=[covDataClean(:,1:6) NaN(size(covDataClean,1),1) covDataClean(:,7:8)];
        extendedDataCIR=[CIRDataClean(:,1:2) NaN(size(CIRDataClean,1),4) CIRDataClean(:,3:5)];
        extendedData=[extendedDatacov;extendedDataCIR];
        [uniquejointNPCI,~,idListJoint]=unique(extendedData(:,[1 2 8 9 ]), 'rows');
        extendedRSSI=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,3))});
        extendedNSINR=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,4))});
        extendedRSRP=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,5))});
        extendedRSRQ=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,6))});
        extendedToA=accumarray(idListJoint, (1:size(extendedData,1)).', [], @(x){nanmean(extendedData(x,7))});
        dataSet{i,3}=[uniquejointNPCI(:,1:2), cell2mat(extendedRSSI),cell2mat(extendedNSINR),cell2mat(extendedRSRP),cell2mat(extendedRSRQ),cell2mat(extendedToA),uniquejointNPCI(:,3),uniquejointNPCI(:,4)];
    
    end
    % We fill in the other cells in the cell row for this unique location
    NPCI_ToA_Operator_1=~isnan(dataSet{i,3}(:,7)) & (dataSet{i,3}(:,8)==Operator1MNC);
    N_NPCI_ToA_Operator_1=nnz(NPCI_ToA_Operator_1);
    NPCI_RF_Operator_1=~isnan(dataSet{i,3}(:,3))  & (dataSet{i,3}(:,8)==Operator1MNC);
    N_NPCI_RF_Operator_1=nnz(NPCI_RF_Operator_1);
    NPCI_ToA_Operator_2=~isnan(dataSet{i,3}(:,7)) & (dataSet{i,3}(:,8)==Operator2MNC);
    N_NPCI_ToA_Operator_2=nnz(NPCI_ToA_Operator_2);
    NPCI_RF_Operator_2=~isnan(dataSet{i,3}(:,3))  & (dataSet{i,3}(:,8)==Operator2MNC);
    N_NPCI_RF_Operator_2=nnz(NPCI_RF_Operator_2);
    NPCI_ToA_Operator_3=~isnan(dataSet{i,3}(:,7)) & (dataSet{i,3}(:,8)==Operator3MNC);
    N_NPCI_ToA_Operator_3=nnz(NPCI_ToA_Operator_3);
    NPCI_RF_Operator_3=~isnan(dataSet{i,3}(:,3))  & (dataSet{i,3}(:,8)==Operator3MNC);
    N_NPCI_RF_Operator_3=nnz(NPCI_RF_Operator_3);
    dataSet{i,4}=N_NPCI_RF_Operator_1;
    dataSet{i,5}=NPCI_RF_Operator_1;
    dataSet{i,6}=N_NPCI_ToA_Operator_1;
    dataSet{i,7}=NPCI_ToA_Operator_1;

    dataSet{i,8}=N_NPCI_RF_Operator_2;
    dataSet{i,9}=NPCI_RF_Operator_2;
    dataSet{i,10}=N_NPCI_ToA_Operator_2;
    dataSet{i,11}=NPCI_ToA_Operator_2;

     dataSet{i,12}=N_NPCI_RF_Operator_3;
    dataSet{i,13}=NPCI_RF_Operator_3;
    dataSet{i,14}=N_NPCI_ToA_Operator_3;
    dataSet{i,15}=NPCI_ToA_Operator_3;

    [dataSet{i,16},~,~]=unique(dataSet{i,3}(:,9), 'rows');
    if any(NPCI_RF_Operator_1)
        max_RSSI_temp_Op_1=max(dataSet{i,3}(NPCI_RF_Operator_1,3));
        max_RSSI_Op_1=max(max_RSSI_temp_Op_1,max_RSSI_Op_1);
        max_SINR_temp_Op_1=max(dataSet{i,3}(NPCI_RF_Operator_1,4));
        max_SINR_Op_1=max(max_SINR_temp_Op_1,max_SINR_Op_1);
        max_RSRP_temp_Op_1=max(dataSet{i,3}(NPCI_RF_Operator_1,5));
        max_RSRP_Op_1=max(max_RSRP_temp_Op_1,max_RSRP_Op_1);
        max_RSRQ_temp_Op_1=max(dataSet{i,3}(NPCI_RF_Operator_1,6));
        max_RSRQ_Op_1=max(max_RSRQ_temp_Op_1,max_RSRQ_Op_1);
        sum_abs_RSSI_Op_1=sum_abs_RSSI_Op_1+sum(abs(dataSet{i,3}(NPCI_RF_Operator_1,3)));
        sum_abs_SINR_Op_1=sum_abs_SINR_Op_1+sum(abs(dataSet{i,3}(NPCI_RF_Operator_1,4)));
        sum_abs_RSRP_Op_1=sum_abs_RSRP_Op_1+sum(abs(dataSet{i,3}(NPCI_RF_Operator_1,5)));
        sum_abs_RSRQ_Op_1=sum_abs_RSRQ_Op_1+sum(abs(dataSet{i,3}(NPCI_RF_Operator_1,6)));
        sum_sq_RSSI_Op_1=sum_sq_RSSI_Op_1+sum((dataSet{i,3}(NPCI_RF_Operator_1,3)).^2);
        sum_sq_SINR_Op_1=sum_sq_SINR_Op_1+sum((dataSet{i,3}(NPCI_RF_Operator_1,4)).^2);
        sum_sq_RSRP_Op_1=sum_sq_RSRP_Op_1+sum((dataSet{i,3}(NPCI_RF_Operator_1,5)).^2);
        sum_sq_RSRQ_Op_1=sum_sq_RSRQ_Op_1+sum((dataSet{i,3}(NPCI_RF_Operator_1,6)).^2);
    end
    if any(NPCI_ToA_Operator_1)
        max_ToA_temp_Op_1=max(dataSet{i,3}(NPCI_ToA_Operator_1,7));
        max_ToA_Op_1=max(max_ToA_temp_Op_1,max_ToA_Op_1);
        sum_abs_ToA_Op_1=sum_abs_ToA_Op_1+sum(abs(dataSet{i,3}(NPCI_ToA_Operator_1,7)));
        sum_sq_ToA_Op_1=sum_sq_ToA_Op_1+sum((dataSet{i,3}(NPCI_ToA_Operator_1,7)).^2);
    end
    if any(NPCI_RF_Operator_2)
        max_RSSI_temp_Op_2=max(dataSet{i,3}(NPCI_RF_Operator_2,3));
        max_RSSI_Op_2=max(max_RSSI_temp_Op_2,max_RSSI_Op_2);
        max_SINR_temp_Op_2=max(dataSet{i,3}(NPCI_RF_Operator_2,4));
        max_SINR_Op_2=max(max_SINR_temp_Op_2,max_SINR_Op_2);
        max_RSRP_temp_Op_2=max(dataSet{i,3}(NPCI_RF_Operator_2,5));
        max_RSRP_Op_2=max(max_RSRP_temp_Op_2,max_RSRP_Op_2);
        max_RSRQ_temp_Op_2=max(dataSet{i,3}(NPCI_RF_Operator_2,6));
        max_RSRQ_Op_2=max(max_RSRQ_temp_Op_2,max_RSRQ_Op_2);
        sum_abs_RSSI_Op_2=sum_abs_RSSI_Op_2+sum(abs(dataSet{i,3}(NPCI_RF_Operator_2,3)));
        sum_abs_SINR_Op_2=sum_abs_SINR_Op_2+sum(abs(dataSet{i,3}(NPCI_RF_Operator_2,4)));
        sum_abs_RSRP_Op_2=sum_abs_RSRP_Op_2+sum(abs(dataSet{i,3}(NPCI_RF_Operator_2,5)));
        sum_abs_RSRQ_Op_2=sum_abs_RSRQ_Op_2+sum(abs(dataSet{i,3}(NPCI_RF_Operator_2,6)));
        sum_sq_RSSI_Op_2=sum_sq_RSSI_Op_2+sum((dataSet{i,3}(NPCI_RF_Operator_2,3)).^2);
        sum_sq_SINR_Op_2=sum_sq_SINR_Op_2+sum((dataSet{i,3}(NPCI_RF_Operator_2,4)).^2);
        sum_sq_RSRP_Op_2=sum_sq_RSRP_Op_2+sum((dataSet{i,3}(NPCI_RF_Operator_2,5)).^2);
        sum_sq_RSRQ_Op_2=sum_sq_RSRQ_Op_2+sum((dataSet{i,3}(NPCI_RF_Operator_2,6)).^2);
    end
    if any(NPCI_ToA_Operator_2)
        max_ToA_temp_Op_2=max(dataSet{i,3}(NPCI_ToA_Operator_2,7));
        max_ToA_Op_2=max(max_ToA_temp_Op_2,max_ToA_Op_2);
        sum_abs_ToA_Op_2=sum_abs_ToA_Op_2+sum(abs(dataSet{i,3}(NPCI_ToA_Operator_2,7)));
        sum_sq_ToA_Op_2=sum_sq_ToA_Op_2+sum((dataSet{i,3}(NPCI_ToA_Operator_2,7)).^2);
    end
    if any(NPCI_RF_Operator_3)
        max_RSSI_temp_Op_3=max(dataSet{i,3}(NPCI_RF_Operator_3,3));
        max_RSSI_Op_3=max(max_RSSI_temp_Op_3,max_RSSI_Op_3);
        max_SINR_temp_Op_3=max(dataSet{i,3}(NPCI_RF_Operator_3,4));
        max_SINR_Op_3=max(max_SINR_temp_Op_3,max_SINR_Op_3);
        max_RSRP_temp_Op_3=max(dataSet{i,3}(NPCI_RF_Operator_3,5));
        max_RSRP_Op_3=max(max_RSRP_temp_Op_3,max_RSRP_Op_3);
        max_RSRQ_temp_Op_3=max(dataSet{i,3}(NPCI_RF_Operator_3,6));
        max_RSRQ_Op_3=max(max_RSRQ_temp_Op_3,max_RSRQ_Op_3);
        sum_abs_RSSI_Op_3=sum_abs_RSSI_Op_3+sum(abs(dataSet{i,3}(NPCI_RF_Operator_3,3)));
        sum_abs_SINR_Op_3=sum_abs_SINR_Op_3+sum(abs(dataSet{i,3}(NPCI_RF_Operator_3,4)));
        sum_abs_RSRP_Op_3=sum_abs_RSRP_Op_3+sum(abs(dataSet{i,3}(NPCI_RF_Operator_3,5)));
        sum_abs_RSRQ_Op_3=sum_abs_RSRQ_Op_3+sum(abs(dataSet{i,3}(NPCI_RF_Operator_3,6)));
        sum_sq_RSSI_Op_3=sum_sq_RSSI_Op_3+sum((dataSet{i,3}(NPCI_RF_Operator_3,3)).^2);
        sum_sq_SINR_Op_3=sum_sq_SINR_Op_3+sum((dataSet{i,3}(NPCI_RF_Operator_3,4)).^2);
        sum_sq_RSRP_Op_3=sum_sq_RSRP_Op_3+sum((dataSet{i,3}(NPCI_RF_Operator_3,5)).^2);
        sum_sq_RSRQ_Op_3=sum_sq_RSRQ_Op_3+sum((dataSet{i,3}(NPCI_RF_Operator_3,6)).^2);
    end
    if any(NPCI_ToA_Operator_3)
        max_ToA_temp_Op_3=max(dataSet{i,3}(NPCI_ToA_Operator_3,7));
        max_ToA_Op_3=max(max_ToA_temp_Op_3,max_ToA_Op_3);
        sum_abs_ToA_Op_3=sum_abs_ToA_Op_3+sum(abs(dataSet{i,3}(NPCI_ToA_Operator_3,7)));
        sum_sq_ToA_Op_3=sum_sq_ToA_Op_3+sum((dataSet{i,3}(NPCI_ToA_Operator_3,7)).^2);
    end
    if isempty(max_RSSI_Op_1)
        fprintf('Error\n');
    end
end
max_Vector_Op_1=[max_RSSI_Op_1,max_SINR_Op_1,max_RSRP_Op_1,max_RSRQ_Op_1,max_ToA_Op_1];
max_Vector_Op_2=[max_RSSI_Op_2,max_SINR_Op_2,max_RSRP_Op_2,max_RSRQ_Op_2,max_ToA_Op_2];
max_Vector_Op_3=[max_RSSI_Op_3,max_SINR_Op_3,max_RSRP_Op_3,max_RSRQ_Op_3,max_ToA_Op_3];
sum_abs_Vector_Op_1=[sum_abs_RSSI_Op_1, sum_abs_SINR_Op_1,sum_abs_RSRP_Op_1,sum_abs_RSRQ_Op_1, sum_abs_ToA_Op_1];
sum_sq_Vector_Op_1=[sum_sq_RSSI_Op_1, sum_sq_SINR_Op_1,sum_sq_RSRP_Op_1,sum_sq_RSRQ_Op_1,sum_sq_ToA_Op_1];
sum_abs_Vector_Op_2=[sum_abs_RSSI_Op_2, sum_abs_SINR_Op_2,sum_abs_RSRP_Op_2,sum_abs_RSRQ_Op_2, sum_abs_ToA_Op_2];
sum_sq_Vector_Op_2=[sum_sq_RSSI_Op_3, sum_sq_SINR_Op_3,sum_sq_RSRP_Op_3,sum_sq_RSRQ_Op_3,sum_sq_ToA_Op_3];
sum_abs_Vector_Op_3=[sum_abs_RSSI_Op_2, sum_abs_SINR_Op_2,sum_abs_RSRP_Op_2,sum_abs_RSRQ_Op_2, sum_abs_ToA_Op_2];
sum_sq_Vector_Op_3=[sum_sq_RSSI_Op_3, sum_sq_SINR_Op_3,sum_sq_RSRP_Op_3,sum_sq_RSRQ_Op_3,sum_sq_ToA_Op_3];
end
