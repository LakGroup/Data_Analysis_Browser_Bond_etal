function intpctrange = interpercentilerange(data,percentiles)

%%% input
%%% 'data' = vector of data 
%%% 'percentiles' = lower and upper percentile values to be determined

if nargin < 2
    percentiles = [0.25 0.75];
end

if max(size(percentiles)) ~= 2
    error('give upper/lower percentiles as input')
end

if percentiles(1) == percentiles(2)
    error('how about ya give me some useful input percentiles, buddy')
end

low = min(percentiles);
up = max(percentiles);

if low > 10, low = low/100; end 
if up > 10, up = up/100; end 

[f,x] = ecdf(data);

intpctrange = [x(find(f >= low, 1, 'first')) x(find(f <= up, 1, 'last')) ];

end