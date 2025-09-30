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



fig, (axs1, axs2, axs3) = plt.subplots(3, 1, figsize=[10,14], dpi=500)
    
resistance1_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-100ohm-200nH.txt')
resistance2_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-130ohm-200nH.txt')
resistance3_file_path =         os.path.join(path, 'snspd-thermal-nonlinear-200ohm-200nH.txt')

resistance1_data =              load_data(resistance1_file_path)
resistance2_data =              load_data(resistance2_file_path)
resistance3_data =              load_data(resistance3_file_path)


time1 =                         resistance1_data['time'] * 10**(9) #ns
time2 =                         resistance2_data['time'] * 10**(9) #ns
time3 =                         resistance3_data['time'] * 10**(9) #ns
times =                         [time1, time2, time3]

data_SP =                       load_data(resistance1_file_path)
time_SP =                       data_SP['time'] * 10**(9)
T_sub_SP =                      data_SP['V(u1:tsub)']
res_hs_SP =                     data_SP['V(u1:r_hs)']
V_out_SP =                      data_SP['V(vout1)'] * 10**(3)

data_AP =                       load_data(resistance2_file_path)
time_AP =                       data_AP['time'] * 10**(9)
T_sub_AP =                      data_AP['V(u1:tsub)']
res_hs_AP =                     data_AP['V(u1:r_hs)']
V_out_AP =                      data_AP['V(vout1)'] * 10**(3)

data_L =                        load_data(resistance3_file_path)
time_L =                        data_L['time'] * 10**(9)
T_sub_L =                       data_L['V(u1:tsub)']
res_hs_L =                     data_L['V(u1:r_hs)']
V_out_L =                       data_L['V(vout1)'] * 10**(3)


color0 = (172/255, 77/255, 219/255)
color1 = (76/255,139/255,255/255)
color2 = (255/255,103/255,76/255)

colors = [color0, color1, color2]


generate_plot(
    axs1,
    x_data=[time_SP, time_AP, time_L],
    y_data=[V_out_SP, V_out_AP, V_out_L],
    line_styles=['-', '--', '-.'],
    line_widths = [6, 4, 4],
    labels=[r'$1.0$ ns', r'$1.5$ ns', 
            r'$2.0$ ns' ],
    xlabel=r'',
    ylabel=r"voltage [mV]",
    font_size=45,
    title=r'',
    colors=colors,
    tick_label_size=40,
    xlim=(0, 15)
    )
axs1.set_xticks([])
axs1.set_yticks(np.arange(0, 1.6, 0.5))


twin = axs2.twinx()

# draw on twin
generate_plot(
    twin,
    x_data=[time_SP, time_AP, time_L],
    y_data=[T_sub_SP, T_sub_AP, T_sub_L],
    line_styles=['-', '--', '-.'],
    line_widths=[6, 4, 4],
    xlabel='',
    ylabel='',
    font_size=45,
    title='',
    colors=colors,
    tick_label_size=40,
    xlim=(0, 15)
    )

# hide ticks on the base axis
axs2.set_yticks([])
axs2.set_xticks([])

# configure twin: label, major ticks, no minor ticks, tick length
twin.set_ylabel(r'temperature [K]')
twin.set_yticks(np.arange(2, 9, 2))

generate_plot(
    axs3, 
    x_data=[time_SP, time_AP, time_L],
    y_data=[res_hs_SP, res_hs_AP, res_hs_L],
    line_styles=['-', '--', '-.'],
    line_widths = [6, 4, 4],
    xlabel=r'time [ns]',
    ylabel=r"$\begin{array}{c} \mathrm{hotspot} \\ \mathrm{resistance \, [}\Omega\mathrm{]} \end{array}$",
    font_size=45,
    title=r'',
    colors=colors,
    tick_label_size=40,
    xlim=(0, 15)
    )     

axs3.set_yticks(np.arange(0, 2000, 500))

fig.subplots_adjust(hspace=0) 
axs1.legend(title=r'$\tau_\mathrm{e}$', title_fontsize=40, prop={'size': 30}, loc='best', handlelength=0.5)