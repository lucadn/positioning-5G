function [km_k,nmi_k,mi_k] = haversine_array(real_position,lat_k_RFP,long_k_RFP)
estim_position_k=[lat_k_RFP long_k_RFP];
for i_comp_k=1:size(estim_position_k,1)
    [km_k(i_comp_k,1) nmi_k(i_comp_k,1) mi_k(i_comp_k,1)] = haversine(real_position(i_comp_k,:),estim_position_k(i_comp_k,:));
end
end