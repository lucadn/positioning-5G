function [average_error_pow,percLocated, TPs_located, TP_est_location] = Wei_Cov_strategy(dataSet, dataSet_smoothed, operatorChoiceVector, RF_param,kMax)
warning off

RSSI=3;
SINR=4;
RSRP=5;
RSRQ=6;

switch RF_param
    case RSSI
        missRefValue=-160;
    case SINR
        missRefValue=-40;
    case RSRQ
        missRefValue=-40;
    case RSRP
        missRefValue=-160;
end

%Random selection of Test Points and Reference Points
TP_probability=0.3;
pointTypeFlagVector=(rand(size(dataSet,1),1)<=TP_probability)+1; %1: Reference Point; 2: Test Point

dataSet = [dataSet(:,1:end) num2cell(pointTypeFlagVector)];
dataSet_smoothed = [dataSet_smoothed(:,1:end) num2cell(pointTypeFlagVector)];

irfp=(pointTypeFlagVector==1);
itp=(pointTypeFlagVector==2);

%Creation of data structures for TPs and RFPs

lRFP = nnz(irfp);
lTP = nnz(itp);
struct_RFP=dataSet_smoothed(irfp,:);
struct_TP=dataSet(itp,:);

% Select unique PCIs, defined as triplets of PCIs, SSB index and
% Operator ID
temp_RFP = cellfun(@(a){{a(:,[1 2 10])}},struct_RFP(:,3));
RFP_PCI_ID_Op=cell2mat(cellfun(@(x) cell2mat(x),temp_RFP,'un',0));
temp_TP = cellfun(@(a){{a(:,[1 2 10])}},struct_TP(:,3));
TP_PCI_ID_Op=cell2mat(cellfun(@(x) cell2mat(x),temp_TP,'un',0));
uniquePCIs = unique([TP_PCI_ID_Op; RFP_PCI_ID_Op], 'rows');

%Restrict the set of unique PCIs to the set of selected operators
opIndexes=zeros(size(uniquePCIs,1),1);
for i=1:length(operatorChoiceVector)
    opIndexesTemp=(uniquePCIs(:,3)==operatorChoiceVector(i));
    opIndexes=or(opIndexesTemp,opIndexes);
end
uniquePCIs=uniquePCIs(opIndexes,:);

M_RFP = (missRefValue)*ones(size(struct_RFP,1), size(uniquePCIs,1)); % Reference Point matrix (Reference Point x PCI)
M_TP = (missRefValue)*ones(size(struct_TP,1), size(uniquePCIs,1));   % Test Point matrix (Test Point x PCI)
idx2=zeros(size(struct_RFP,1), size(uniquePCIs,1));
idx1=zeros(size(struct_TP,1), size(uniquePCIs,1));

%Depending on the choice of operators some points might have no useful
%data: identify and label them as "dummy points"

for i = 1:size(struct_RFP,1)
    RFP_mat=cell2mat(struct_RFP(i,3));
    [~,lib] = ismember(RFP_mat(:,[1 2 10]), uniquePCIs, 'rows');
    M_RFP(i,lib(logical(lib))) = RFP_mat(logical(lib),RF_param);
    potentialPCIs=lib(logical(lib));
    actualPCIs=potentialPCIs(~isnan(RFP_mat(logical(lib),RF_param)));
    idx2(i,actualPCIs) = 1;
end

for i = 1:size(struct_TP,1)
    TP_mat=cell2mat(struct_TP(i,3));
    [~,lib] = ismember(TP_mat(:,[1 2 10]), uniquePCIs, 'rows');
    M_TP(i,lib(logical(lib))) = TP_mat(logical(lib),RF_param);
    potentialPCIs=lib(logical(lib));
    actualPCIs=potentialPCIs(~isnan(TP_mat(logical(lib),RF_param)));
    idx1(i,actualPCIs) = 1;
end
M_TP(isnan(M_TP))=missRefValue;
M_RFP(isnan(M_RFP))=missRefValue;

dummyTPs=~any(idx1,2);
nDummyTPs=nnz(dummyTPs);
dummyRFPs=~any(idx2,2);
validRFPs=any(idx2,2);

D = pdist2(M_TP, M_RFP, 'euclidean');

%This strategy technically works even when there are no PCIs in common
%between TP and any RP. But in this case the position will be determined
%picking the first k RPs, so pretty much randomly. Out of fairness with
%strategies where TPs without PCIs in common with any RP are excluded, we
%do the same here.
TPs_located=zeros(1,size(struct_TP,1));

L = zeros(size(struct_TP,1), size(struct_RFP,1));    %% matrix of BTS elements in common
for i = 1:size(struct_TP,1)
    match = bsxfun(@and, idx1(i,:), idx2);  % match between i-th TP and each RFP
    s = sum(match,2);                       % sum the number of matches (number of unique PCIs in common)
    z = find(s==0);                         % find zeros (no unique PCIs in common)
    nz = find(s~=0);                        % find non-zeros (at least one unique PCI in common)

    L(i,:) = s';
    bin = unique(L(i,:));  %% number of unique PCIs in common
    if (length(bin)>1 || (bin~=0))
        TPs_located(i)=1;
    else
        %fprintf('TP %d not located\n',i);
    end

    for j = nz'
        D(i,j) = D(i,j)/(s(j));
    end
    for j = z'
        D(i,j) = realmax;
    end
end
D(:,dummyRFPs)=realmax;
TPs_located=logical(TPs_located);


% In the unlikely event we have a null distance we set it to a very small
% value (5% of the minimum value), to avoid a singularity when we invert
% the distances

D(D==0) = min(D(D~=0))/20;

[D_sort, idx_sort] = sort(D,2);
W = 1./D_sort;          %%% weights matrix (inverted distances)



real_lat=cell2mat(struct_TP(:,1));
real_long=cell2mat(struct_TP(:,2));
real_position=[real_lat real_long];

%----------------HOUSEKEEPING---------------------------------------------
clear struct_needed D_sort;
clear lib M_RFP M_TP;
clear idx_TP idx_RFP;
clear real_lat real_long;
clear itp irfp;

%----------------WKNN with RF data---------------------------------------------


k=1:1:kMax;
TP_est_location= deal(cell(1, length(k)));
for i=1:length(k)
    this_k = k(i);

    RFP_selected_idx = idx_sort(TPs_located,1:this_k);
    
    lat_k_RFP_matrix = reshape(cell2mat(struct_RFP(RFP_selected_idx(:),1)), size(RFP_selected_idx));
    long_k_RFP_matrix = reshape(cell2mat(struct_RFP(RFP_selected_idx(:),2)), size(RFP_selected_idx));
    
    % weighted sum
    sum_lat=sum(lat_k_RFP_matrix.*(W(TPs_located,1:this_k)),2);
    sum_long=sum(long_k_RFP_matrix.*(W(TPs_located,1:this_k)),2);

    % taking the average
    lat_k_TP = sum_lat./sum(W(TPs_located,1:this_k),2);
    long_k_TP = sum_long./sum(W(TPs_located,1:this_k),2);

    [km_pow(:,i),~,~]=haversine_array(real_position(TPs_located,:),lat_k_TP,long_k_TP);
    average_error_pow(i)=mean(km_pow(:,i));
    TP_est_location_k=zeros(lTP,2);
    TP_est_location_k(TPs_located,1)=lat_k_TP;
    TP_est_location_k(TPs_located,2)=long_k_TP;
    TP_est_location{i}= TP_est_location_k;
end

percLocated=length(TPs_located)/(lTP-nDummyTPs);

