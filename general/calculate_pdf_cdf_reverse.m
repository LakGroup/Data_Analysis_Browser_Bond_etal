function [x_pdf,y_pdf,x_cdf,y_cdf] = calculate_pdf_cdf_reverse(data,percentile)
data = 1./data;
I1 = prctile(data,percentile(1));
I2 = prctile(data,percentile(2));
wanted = data(data<I2 & data>I1);
x_hist = linspace(min(wanted),max(wanted),1000);
y_pdf = histcounts(wanted,x_hist,'normalization','probability');
y_cdf = histcounts(wanted,x_hist,'normalization','cdf');
x_pdf = x_hist(1:end-1);
x_cdf = x_hist(1:end-1);
end