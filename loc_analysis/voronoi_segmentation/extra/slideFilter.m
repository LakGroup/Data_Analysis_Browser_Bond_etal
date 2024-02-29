function slidetraj = slideFilter(type,data,win,dimorig)

%%% J. Otterstrom, Matlab 2012a, July 2013

% sliding filter that makes a window around each time point in a
% trajectory of width 2*win.  If a difference filter is used, then the
% difference between the later half of the window from the first half of
% the window is returned.  If an average filter is used, then the average
% value over the entire 2*win size is returned.  In the early and late
% portions of input data, the window is less than 2*win to have some
% values returned and reduce the padding at the edges

% INPUTS
% type - values can be 'diff' or 'avg' to set the filtering to difference
%     or average, respectively.  'diff' is default if none is given
% data - array of data to be filtered.  by default the rows of the array
%     are taken to be the dimension over which the filter should be 
%     applied.
% win - number of rows + and - to be used for filter calculations
% dimorig - dimension for filtering.  Default = 1, rows.  If input value of
%     2 is input, then the data is rotated before flitering and filtered
%     data is rotated back before being output

% OUTPUT
% slidetraj - sliding window filtered data from calculations
%%

if length(size(data)) > 2
    error('entered data has too many dimensions, maximally 2 are allowed')
end

[nr,nc] = size(data);
long = max([nr,nc]);

if long < 20, error('Sorry babe, size matters and your data is too small.'), end

if ~exist('win','var'), win = max([10 round(0.01*long)]); end

if ~exist('dimorig','var')
    dimorig = 1; 
else
    if sum(dimorig == [1 2]) == 0
       error('Dimention entered for averaging must be ''1'' for rows or ''2'' for columns') 
    end
end

if ~exist('type','var')
    type = 'diff';
    warning('WarnFiltType:slidingFilterID','defaulted to sliding window difference filtering')
elseif sum(strcmp(type,{'diff','avg'})) == 0
    error('Slow down turbo. I don''t know what you were thinking, but the script ''slideFilter'' just isn''t that kind of filter ...')
end


% will average over rows, so make sure it's in the correct format,
% presuming more frames than particles
if dimorig == 2
    data = data';
    numCol = nr;
    numRow = nc;
else
    numCol = nc;
    numRow = nr;
end
dim = 1;

% initialize
slidetraj = zeros(numRow,numCol);
        
switch type
    case 'diff'
        
        halfwin = round(win/2);
        
        % reduce padding at leading edge
        for r = halfwin-1:win
            st1 = 1; ed1 = r-1; 
            st2 = r; ed2 = r+win-1;
            
            slidetraj(r,:) = mean(data(st2:ed2,:),dim) - mean(data(st1:ed1,:),dim);
        end
        % main filtering calculation
        for r = (win+1):(long-win)            
            st1 = r-win; ed1 = r-1; 
            st2 = r;     ed2 = r+win-1;
            
            slidetraj(r,:) = mean(data(st2:ed2,:),dim) - mean(data(st1:ed1,:),dim);
            
        end
        % reduce padding at trailing edge
        for r = (long-win+1):long-halfwin+2
            st1 = r-win; ed1 = r-1;
            st2 = r;     ed2 =long;
            
            slidetraj(r,:) = mean(data(st2:ed2,:),dim) - mean(data(st1:ed1,:),dim);
        end
        
    case 'avg'
        
        halfwin = round(win/2);
        
        % set initial values
        for r = 1:halfwin-2
            slidetraj(r,:) = mean(data(1:halfwin-2,:),dim);
        end
        % reduce padding at leading edge
        for r = halfwin-1:win            
            st = 1; ed = r+win-1;
            
            slidetraj(r,:) = mean(data(st:ed,:),dim);
        end
        % main filtering calculation
        for r = (win+1):(long-win)            
            st = r-win; ed = r+win-1;
            
            slidetraj(r,:) = mean(data(st:ed,:),dim);            
        end
        % reduce padding at trailing edge
        for r = (long-win+1):long-halfwin+2
            st = r-win; ed = long;
            
            slidetraj(r,:) = mean(data(st:ed,:),dim);
        end
        % set ending values
        for r = long-halfwin+3:long
            slidetraj(r,:) = mean(data(long-halfwin+3:long,:),dim);
        end
end

if dimorig == 2
    slidetraj = slidetraj';
end


end