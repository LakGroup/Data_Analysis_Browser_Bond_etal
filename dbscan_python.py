import scipy.io
from sklearn.cluster import DBSCAN
data = scipy.io.loadmat('temp_file.mat')
I = data['data_db']
I = I.astype(dtype = 'float32')
epsilon = data['epsilon']
epsilon = epsilon[0][0]
min_points = data['db_points']
min_points = min_points[0][0]
idx = DBSCAN(eps =epsilon, min_samples = min_points).fit(I)
idx = idx.labels_
scipy.io.savemat('idx.mat', {'idx':idx})