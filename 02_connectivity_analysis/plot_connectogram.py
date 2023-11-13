# Imports
import sys,subprocess

try: 
    import scipy.io as sio
except ModuleNotFoundError: 
    subprocess.run([sys.executable, '-m', 'pip', 'install', 'scipy'])
    import scipy.io as sio
try:
    import numpy as np
except ModuleNotFoundError:
    subprocess.run([sys.executable, '-m', 'pip', 'install', 'numpy'])
    import numpy as np
try:
    import matplotlib.pyplot as plt
except ModuleNotFoundError:
    subprocess.run([sys.executable, '-m', 'pip', 'install', 'matplotlib'])
    import matplotlib.pyplot as plt
try:
    from mne.viz import circular_layout
    from mne_connectivity.viz import plot_connectivity_circle
except ModuleNotFoundError:
    subprocess.run([sys.executable, '-m', 'pip', 'install', 'mne'])
    subprocess.run([sys.executable, '-m', 'pip', 'install', 'mne-connectivity'])
    from mne.viz import circular_layout
    from mne_connectivity.viz import plot_connectivity_circle




def connectogram(filename,separate_hemispheres):
    # Get information from matrix file
    connectivity = sio.loadmat(filename)
    connectivity = connectivity['matrix']

    # Get number of edges in the connectogram and whether the user want to separate hemispheres
    number_edges = int(np.count_nonzero(connectivity) / 2)  # since the matrix is symmetric, there is twice the number of edges we will want in our graph

    # Get labels of nodes
    label_names = open("label_names.txt", "r").read().splitlines()

    if separate_hemispheres:

        # Create one group for left hemisphere and another for right hemisphere
        lh_labels = [name for name in label_names if name.startswith('L ')]
        rh_labels = [name for name in label_names if name.startswith('R ')]
        vermis = [name for name in label_names if (not name.startswith('R ') and not name.startswith('L '))]
        
        if vermis: # if vermis exists and it is not empty
            node_order = list()
            node_order.extend(lh_labels)  
            node_order.extend(vermis)  
            node_order.extend(rh_labels[::-1])

            # Define variables for the circular layout
            group_boundaries_final = [0, len(lh_labels), len(lh_labels)+len(vermis)]
            node_order_final = node_order
        else:

            node_order = list()
            node_order.extend(lh_labels)  
            node_order.extend(rh_labels[::-1])

            # Define variables for the circular layout
            group_boundaries_final = [0, len(label_names) / 2]
            node_order_final = node_order

    else:
        # Define variables for the circular layout if the user does not want to separate hemispheres
        group_boundaries_final = None
        node_order_final = label_names

    
    
    # Determine the nodes' angles in the connectogram
    node_angles = circular_layout(label_names, node_order_final, start_pos=90,group_boundaries=group_boundaries_final)
    #print(node_order_final)

    # Set node colors

    # Get colors of nodes
    node_colors = open("ROI_colors.txt", "r").read().splitlines()


    # standard_colors = ['lightskyblue', 'sandybrown', 'mediumpurple','limegreen', 'royalblue', 'gold', 'pink']
    # last_node_colors = ['firebrick','firebrick','slategrey','slategrey','slategrey','slategrey','slategrey']
    
    # n_rois=len(label_names) # AAL=15
    # extra_rois = len(standard_colors)*2+len(last_node_colors) - n_rois
    

    # standard_colors=standard_colors[0:int(len(standard_colors)-(extra_rois/2))]


    # node_colors = standard_colors+standard_colors+last_node_colors



    # Create plot
    fig, ax = plt.subplots(1, 1, figsize=(20, 20), facecolor='white', subplot_kw=dict(projection="polar"))
    plot_connectivity_circle(connectivity, label_names, n_lines=number_edges, colormap="Greys",node_colors=node_colors,
                            node_angles=node_angles, facecolor='white', textcolor='black', node_edgecolor='white', ax=ax,
                            colorbar_pos=(-0.1, -0.1), padding=3,fontsize_names=15,fontsize_colorbar=11,vmax=6,vmin=0,linewidth=5)
    fig.tight_layout()
    fig.axes[1]._colorbar.set_ticks=[-1,1,2]

connectogram("matrix.mat",True)

