
#%%
# Imports
import scipy.io as sio
from nichord.coord_labeler import get_idx_to_label
import numpy as np
from nichord.chord import plot_chord
from nichord.glassbrain import plot_glassbrain

#%%
def read_coordinates_file(file_path):
    coordinates_list = []
    with open(file_path, 'r') as file:
        for line in file:
            # Split the line into individual coordinates
            coordinates = line.strip().split()
            x, y, z = map(float, coordinates)
            coordinates_list.append([x, y, z])

    return coordinates_list


#%%
def chord_diagram(filename, label_names,node_colors,coords3):
    # Get information from matrix file
    connectivity = sio.loadmat(filename)
    connectivity = connectivity['matrix']

    edges=list()
    edge_weights=list()
    for i in range(len(connectivity)):
        for j in range(i+1,len(connectivity[0])):
            if connectivity[i][j]!=0:
                edges.append((i,j))
                edge_weights.append(connectivity[i][j])
                
    # Create labels 
    idx_to_label=dict()
    label_names = open(label_names, "r").read().splitlines()
    for i in range(len(label_names)):
        idx_to_label[i]=label_names[i]

    # Define node colors
    node_colors = open(node_colors, "r").read().splitlines()
    network_colors=dict()
    for i in (idx_to_label.keys()):
        network_colors[idx_to_label[i]]=node_colors[i]

    # Plot chord diagram
    plot_chord(idx_to_label, edges, edge_weights=edge_weights,cmap="gray_r",
        linewidths=15, alphas=0.9, do_ROI_circles=True, label_fontsize=20, vmax=6,
        ROI_circle_radius=0.02,network_colors=network_colors)

    # Create coordinates
    coords3=read_coordinates_file(coords3)

    plot_glassbrain(idx_to_label, edges, edge_weights,'/Users/ana/Desktop/ex0_glassbrain.png',
             coords3, linewidths=15, cmap="gray_r",node_size=100,network_colors=network_colors,alphas=0)



chord_diagram("matrix.mat", "label_names.txt","ROI_colors.txt","AAL116_coords_mean.txt")

# %%
