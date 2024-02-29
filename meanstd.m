function [mCurve,sCurve,uCurve,lCurve] = meanstd(Data,multiplier)
% -------------------------------------------------------------------------
% Function that calculates meand and standard deviation for the curves
% provided, and returns the mean, the mean+std and the mean-std of the
% result.
% -------------------------------------------------------------------------
% Input:
%   Data:       The matrix containing the replicates of the data.
%                   This matrix can be a 2D matrix (m x n; m: replicates,
%                   n: data points), or a 3D array (m x n x k; m:
%                   replicates, n: data points, k: different curves).
%                   If the data is a 3D data array, the curves are
%                   calculated per layer (i.e. k results)
%   Multiplier: The multiplier for the upper and lower bounds (default: 1).
%                   e.g., 95% confidence intervals: Multiplier = 1.96.
%
% Output:
%   mCurve:     The mean of the data (averaged over each data point).
%                   If input is 3D, then the different curves will be
%                   stored in the rows.
%   sCurve:     The std of the data (averaged over each data point).
%                   If input is 3D, then the different curves will be
%                   stored in the rows.
%   uCurve:     The mean+std of the data (for each data point).
%                   If input is 3D, then the different curves will be
%                   stored in the rows.
%   lCurve:     The mean-std of the data (for each data point).
%                   If input is 3D, then the different curves will be
%                   stored in the rows.
% -------------------------------------------------------------------------
% Code written by:
%   Siewert Hugelier    Lakadamyali lab, University of Pennsylvania (USA)
% -------------------------------------------------------------------------

% Set the default value
if nargin < 2 || multiplier <= 0
    multiplier = 1;
end

% Calculate the mean and standard deviation of the data and create the 
% upper and lower curves.
mCurve = zeros(size(Data,3),size(Data,2));
sCurve = zeros(size(Data,3),size(Data,2));
uCurve = zeros(size(Data,3),size(Data,2));
lCurve = zeros(size(Data,3),size(Data,2));
for i = 1:size(Data,3)
    mCurve(i,:) = mean(Data(:,:,i));
    sCurve(i,:) = std(Data(:,:,i));
    uCurve(i,:) = mCurve(i,:) + multiplier*sCurve(i,:);
    lCurve(i,:) = mCurve(i,:) - multiplier*sCurve(i,:);
end