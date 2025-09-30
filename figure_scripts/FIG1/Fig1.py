import pandas as pd
from matplotlib import pyplot as plt
from plot_utils import generate_plot

import os

path = os.path.dirname(os.path.abspath(__file__))

fig_size = (8,6)
color_0 = (76/255,139/255,255/255)
color_1 = (255/255,103/255,76/255)
color_2 = (52/255, 235/255, 213/255)
colors = [color_0, color_1, color_2]

def load_data(file_path, delimiter='\t'):
    """Load data from a given file path."""
    return pd.read_csv(file_path, delimiter=delimiter)

fig, ax = plt.subplots(figsize=fig_size, dpi=500)

iv_file_path =  os.path.join(path, 'snspd-thermal-iv-data.txt')
iv_data =       load_data(iv_file_path)

nw_v =                  iv_data['V(nw_v)'] #V
I_wire =                iv_data['I(u1:L_kinetic)'] * 10**(6) #uV


generate_plot(
    axs=ax,
    x_data=nw_v,
    y_data=[I_wire],
    legend = False,
    xlabel=r'voltage [V]',
    ylabel=r'current [$\mu$A]',
    title=r'',
    tick_label_size=30,
    font_size=40,
    sort=False,
    colormap="husl",
    xlim=(-15, 15),
    ylim=(-10, 10),
    x_tick_interval=5,
    y_tick_interval=5
    )
