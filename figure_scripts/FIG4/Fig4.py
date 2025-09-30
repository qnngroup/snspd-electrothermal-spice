import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from plot_utils import generate_plot

import os

path = os.path.dirname(os.path.abspath(__file__))

fig_size = (8,6)
color_0 = (76/255,139/255,255/255)
color_1 = (255/255,103/255,76/255)
color_2 = (52/255, 235/255, 213/255)
colors = [color_1, color_2, color_0]

def load_data(file_path, delimiter='\t'):
    """Load data from a given file path."""
    return pd.read_csv(file_path, delimiter=delimiter)


fig, axs = plt.subplots(3,1, figsize=[10,12], dpi=500, sharey=True, squeeze=True)


T_sub_list = np.linspace(3,10.499, 100)
T_c = 10.5
Jc = 45 * 10 ** (9)
width = 100 * 10 ** (-9)
thickness = 4 * 10 ** (-9)
hc = 50 * 10 ** (3)
C = 0.5
I_c = Jc*width*thickness*C
I_sw = I_c * (1 - (T_sub_list / T_c) ** 2) ** (3/2)
J_sw = I_sw / (width*thickness*C)
sheetRes = 300
psi = (sheetRes*(J_sw * thickness)**2) * ( hc * (T_c-T_sub_list)) ** (-1)
I_r = np.minimum(np.sqrt(2/psi) * I_sw, I_sw)

resistance1_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-100ohm-200nH.txt')
resistance2_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-130ohm-200nH.txt')
resistance3_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-200ohm-200nH.txt')

data_SP =                       load_data(resistance1_file_path)
T_sub_SP =                      data_SP['V(u1:tsub)']
I_wire_SP =                     data_SP['abs(I(u1:L_kinetic))'] * 10**(6)    

data_AP =                       load_data(resistance2_file_path)
T_sub_AP =                      data_AP['V(u1:tsub)']
I_wire_AP =                     data_AP['abs(I(u1:L_kinetic))'] * 10**(6)

data_L =                        load_data(resistance3_file_path)
T_sub_L =                       data_L['V(u1:tsub)']
I_wire_L =                      data_L['abs(I(u1:L_kinetic))'] * 10**(6)



currents_SP = [I_r * 10 ** 6, I_sw * 10 ** 6,np.abs( I_wire_SP)]
currents_AP = [I_r * 10 ** 6, I_sw * 10 ** 6, np.abs(I_wire_AP)]
currents_L = [I_r * 10 ** 6, I_sw * 10 ** 6, np.abs(I_wire_L)]

generate_plot(
    axs = axs[0],
    x_data=[T_sub_list, T_sub_list, T_sub_SP],
    y_data=currents_SP,
    labels=[r'$i_\mathrm{D}$', r'$I_\mathrm{rt}$', r'$I_\mathrm{sw}$'],
    xlabel=r'',
    ylabel=r'',
    xlim=(3, 10.5),
    line_styles=['dashed', 'dashed', 'solid'],
    title=r'',
    sort=False,
    colors=colors,
    font_size=45
    )
axs[0].text(7.5, 7.5, r'$\tau_\mathrm{e} = 1.0$ ns', ha='center', va='top', fontsize=40)
# axs[0].text(3.2, 0.6, r'\textbf{(a)}')
axs[0].set_xticks([])
generate_plot(
    axs = axs[1],
    x_data=[T_sub_list, T_sub_list, T_sub_AP],
    y_data=currents_AP,
    xlabel=r'',
    ylabel=r'current [$\mu$A]',
    xlim=(3, 10.5),
    line_styles=['dashed', 'dashed', 'solid'],
    title=r'',
    sort=False,
    colors=colors,
    font_size=45
    )
axs[1].text(7.5, 7.5, r'$\tau_\mathrm{e} = 1.5$ ns', ha='center', va='top', fontsize=40)
# axs[1].text(3.2, 0.6, r'\textbf{(b)}')
axs[1].set_xticks([])
generate_plot(
    axs = axs[2],
    x_data=[T_sub_list, T_sub_list, T_sub_L],
    y_data=currents_L,
    xlabel=r'temperature [K]',
    ylabel=r'',
    xlim=(3, 10.5),
    line_styles=['dashed', 'dashed', 'solid'],
    title=r'',
    sort=False,
    colors=colors,
    font_size=45
    )
axs[2].text(7.5, 7.5, r'$\tau_\mathrm{e} = 2.0$ ns', ha='center', va='top', fontsize=40)
axs[2].set_xticks(np.arange(3, 11, 2))
axs[2].set_yticks(np.arange(0, 9, 3))
# axs[2].text(3.2, 0.6, r'\textbf{(c)}')
fig.subplots_adjust(hspace=0) 
axs[0].legend(prop={'size': 30}, loc='best', handlelength=0.5)