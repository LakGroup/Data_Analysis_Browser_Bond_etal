import scipy.io
import numpy as np
from scipy.spatial import Voronoi
import math

data = scipy.io.loadmat('temp_file.mat')
points = data['points']

def PolyArea(x,y):
    return 0.5*np.abs(np.dot(x,np.roll(y,1))-np.dot(y,np.roll(x,1)))

vor = Voronoi(points)
point_to_cell_index = list(vor.point_region)
regions = vor.regions
vertices = vor.vertices

inf_empty_index = [regions.index(i) for i in regions if -1 in i or i ==[]]

voronoi_cells = [vertices[i] for i in regions]

voronoi_areas = [PolyArea(i[:,0],i[:,1]) for i in voronoi_cells]
  
for i in inf_empty_index:
    voronoi_areas[i] = math.inf
    if -1 in regions[i]:
        regions[i].remove(-1)
        
voronoi_areas = [voronoi_areas[i] for i in point_to_cell_index]  
voronoi_cells = [voronoi_cells[i] for i in point_to_cell_index] 

regions = [regions[i] for i in point_to_cell_index]

regions_corrected = [list(map(lambda x: x+1, i)) for i in regions]

to_save = {'voronoi_areas': voronoi_areas,'vertices':vertices,'connections':regions_corrected}

scipy.io.savemat('va.mat', to_save)
print('job finished')