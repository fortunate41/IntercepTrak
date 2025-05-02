function ChannelCoefficients_correlated=Coloured_noise(ChannelCoefficients_uncorrelated, ...
    correl_type, ...
    av_powers_dB, ...
    rho_correl, alpha_correl)
%Generate correlated fading matrix (for multiple paths)
%algorithm of Natarajan & Nassar & Chandrasekhar
%IEEE Comm. Letters, vol. 4, Jan 2000.
%functions used: map_correl_fad.m
%correl_type ='exponential' or 'constant' or 'zero' (no correlation)
%rho_correl = value used for 'exponential' (rho^(alpha*i) or
%            'constant' (rho) correlation coefficients; should be
%            less than 1
%alpha_correl = value (power) used for    'exponential'
%              correlation coefficients
%used functions: map_correl_fad.m

if size(ChannelCoefficients_uncorrelated,1)< ...
        size(ChannelCoefficients_uncorrelated,2),
    ChannelCoefficients_uncorrelated= ...
        transpose(ChannelCoefficients_uncorrelated);
end;

if rho_correl >1,
    error('Correlation coefficient should be less than 1');
end;


N_random=size(ChannelCoefficients_uncorrelated,1);
%maximum number of paths;
L=size(ChannelCoefficients_uncorrelated,2);

if size(av_powers_dB,1)>size(av_powers_dB,2),
    av_powers_dB=av_powers_dB.';
end;

powers_i=10.^(av_powers_dB/10);
powers=powers_i/sum(powers_i);
norm_powers=powers'*powers; %matrix L xL


% env_correl_coeff = vector of correlation coefficients between
%                  paths, it has L-1 values; we assume
%                  rho_i,j=rho_j,i
if strcmp(correl_type, 'exponential'),
    env_correl_coeff=rho_correl.^(alpha_correl*[1:L-1]);
else
    if strcmp(correl_type, 'constant'),
        env_correl_coeff=rho_correl*ones(1,L-1);
    else
        if strcmp(correl_type, 'zero'),
            env_correl_coeff=zeros(1,L-1);
        else
            error('Inknown correlation profile');
        end;
    end;
end;


%desired covariance matrix, size L x L
matrix_Rxx=toeplitz([0 env_correl_coeff.*sqrt(norm_powers(1,2:L))]);

for ii=1:L,
    matrix_Rxx(ii,ii)=powers(ii);
end;

%normalized covariance matrix
norm_matrix_Rxx=matrix_Rxx;

WGN_matrix=eye(L);
%norm_matrix_Rxx=norm_matrix_Rxx./sqrt(norm_powers);

for ii=1:L,
    for jj=1:L,
        if ii~=jj,
            if (norm_matrix_Rxx(ii,jj)>1),
                error('Correlation coefficients should be less than 1')
            end;
            WGN_matrix(ii,jj)= map_correl_fad(norm_matrix_Rxx(ii,jj));
        end;
    end;
end;

WGN_corr_coeff=WGN_matrix(1,2:L);
L_chol=chol(WGN_matrix)';


ChannelCoefficients_correlated=L_chol*transpose([ChannelCoefficients_uncorrelated]);

if (strcmp(correl_type, 'constant')) || (strcmp(correl_type, 'exponential')),
    fact_g=(2-pi/2)*1/2; %normalization factor
    for ii=1:L,
        ChannelCoefficients_correlated(ii,:)=ChannelCoefficients_correlated(ii,:)*sqrt(powers(ii)/fact_g);
    end;
end;
