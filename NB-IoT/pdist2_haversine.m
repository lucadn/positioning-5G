% D = PDIST2_HAVERSINE(X1, X2)
%
% Returns a matrix D of pairwise geographical distances between X1 and X2.
%
% X1 is 2 x M matrix
% X2 is 2 x N matrix
%
% The first rows of X1 and X2 are longitudes (in degrees) and the second
% rows are latitudes (in degrees). The resulting distance matrix D is M x N.
% The distance is measured in kilometers and the Earth is approximated as
% a sphere.
% 
% Haversine formula is used for evaluation, thus the method is accurate on
% small distances but inaccurate when points are at (almost) opposite sides
% of the sphere. Thus, use this distance measure with local data.

function D = pdist2_haversine(X1, X2)

radius = 6371; % quadratic mean radius of the Earth

% Convert to radians
q = pi / 180;
lon1 = X1(1,:) * q;
lat1 = X1(2,:) * q;
lon2 = X2(1,:) * q;
lat2 = X2(2,:) * q;

% Form the grid
[LON2,LON1] = meshgrid(lon2,lon1);
[LAT2,LAT1] = meshgrid(lat2,lat1);

% Distance calculation (haversine formula)
DLAT = LAT2 - LAT1;
DLON = LON2 - LON1;
A = sin(DLAT/2).^2 + cos(LAT1).*cos(LAT2).*(sin(DLON/2).^2);
C = 2 * atan2(sqrt(A), sqrt(1-A));
D = radius * C;