function [lat_new,lon_new]=intrp_lat_lon_ow(lat_temp,lon_temp,max_gap)

% max_gap is the largest gap (in km) that you are willing to liniear interpolate
% over.


missing_lat=find(~isfinite(lat_temp)==1);
missing_lon=find(~isfinite(lon_temp)==1);
lat_new=lat_temp;
lon_new=lon_temp;
if ~isempty(missing_lat) || ~isempty(missing_lon)
    good=find((isfinite(lat_temp)==1) & (isfinite(lon_temp)==1));
    lon2=lon_temp(good);
    lat2=lat_temp(good);
    ind=[1:length(lat_temp)];
    lat_new=interp1(ind(good),lat2,ind);
    
    
    lon_new=interp1(ind(good),lon2,ind);
    lon2_shift=lon2;
    pos_shift=find(lon2>180);
    lon2_shift(pos_shift)=lon2(pos_shift)-360;
    lon_new_shift=interp1(ind(good),lon2_shift,ind);
    
   
    diff_lon_new_shift=abs(diff(lon_new_shift));
    diff_lon_new=abs(diff(lon_new));
    pos_shift2=find(lon_new_shift<0);
    lon_new_shift(pos_shift2)=lon_new_shift(pos_shift2)+360;
    pos_boundry=find(diff_lon_new_shift<diff_lon_new)+1;

    lon_new(pos_boundry)=lon_new_shift(pos_boundry);
    
    %%%% HGH (requires  Mapping Toolbox)
    %         also, the call is distance(lat1,lon1,lat2,lon2)??
    %d=deg2km(distance(lon2(1:end-1),lat2(1:end-1),lon2(2:end),lat2(2:end)));
    d=gsw_distance(lon2,lat2)/1e3; 
    d=[0,d];
    dall=nan(1,length(ind));
    dall(good)=d;
   
    
    diff_good=abs(diff(good))-1;
    pos_gap=find(diff_good>0);
    diff_good=diff_good(pos_gap);
    pos_all_gap=good(pos_gap)+1;
    
    for i=1:length(pos_all_gap)
        
        dall(pos_all_gap(i):pos_all_gap(i)+diff_good(i)-1)=ones(1,diff_good(i)).*dall(pos_all_gap(i)-1);
    end
     
    large_gap= dall >max_gap;
    lat_new(large_gap)=nan;
    lon_new(large_gap)=nan;

end

