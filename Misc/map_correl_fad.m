function lambda = map_correl_fad( rho )
%mapping desired correlation coefficients into white noise
%correlation coeficients, for generating
%any number of correlated paths of equal or non-equal powers,
%algorithm of Natarajan & Nassar & Chandrasekhar
%IEEE Comm. Letters, vol. 4, Jan 2000.
%
%rho    = envelope correlation coeff
%lambda = Gaussian correlation coeff

%envelope correlation coefficient(rho) and its mapping to complex
%Gaussian variables correlation coefficient (lambda) (taken from Table 2,
%above mentioned paper)

%rho_ref=[0:.05:1];
%lambda_ref=[0 0.23337 0.32945 0.40277 0.46424 0.51807 0.56644 ...
%	0.61065 0.65152 0.68964 0.72543 ...
%	0.75922 0.79123 0.82168 0.85070 0.87842 0.90494 ...
%	0.93033 0.95463 0.97787 1];

rho_ref = [0 0.0047 0.0056 0.0243 0.0337 0.0559 0.0737 0.0965 0.1494 ...
    0.1836 0.2227 0.2752 0.3327 0.4133 0.4562 0.541 0.6073 ...
    0.6974 0.7913 0.9005 1];

lambda_ref = [0:0.05:1];

temp = find(rho == rho_ref);

if length(temp) >= 1,
    lambda = lambda_ref(temp);
else %use linear interpolation
    t1 = find(rho > rho_ref);
    t2 = find(rho < rho_ref);
    index2 = min(t2);
    index1 = max(t1);
    a = (lambda_ref(index2) - lambda_ref(index1)) / (rho_ref(index2)- ...
        rho_ref(index1));
    b = lambda_ref(index2) - a*rho_ref(index2);
    lambda = a*rho + b;
end;
end