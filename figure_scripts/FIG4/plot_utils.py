# plot_utils.py
import numpy as np
import seaborn as sns
from matplotlib import pyplot as plt

def generate_plot(axs, x_data, y_data, labels=None, xlabel="X-axis", ylabel="Y-axis", 
                  title="Plot Title", line_widths=4, line_styles=None, colors=None, 
                  colormap=None, legend=True, leg_title='', sort=False, tick_label_size=50, 
                  font_size=60, tick_thickness=2, grid=False, xlim=None, ylim=None, 
                  border=True, border_thickness=2, x_tick_interval=None, y_tick_interval=None):

    sns.set(style="whitegrid" if grid else "ticks")

    is_shared_x = not isinstance(x_data, list)
    is_shared_y = not isinstance(y_data, list)

    if colormap:
        colors = sns.color_palette(colormap, len(y_data))

    for i in range(len(y_data)):
        line_style = line_styles[i] if line_styles and i < len(line_styles) else 'solid'
        line_width = line_widths[i] if isinstance(line_widths, list) else line_widths
        color = colors[i] if colors and i < len(colors) else None
        label = labels[i] if labels and i < len(labels) else None

        x_vals = x_data if is_shared_x else x_data[i]
        y_vals = y_data if is_shared_y else y_data[i]

        myplot = sns.lineplot(
            x=x_vals, y=y_vals, label=label,
            linestyle=line_style, color=color, lw=line_width,
            sort=sort, ax=axs
        )

    axs.set_xlabel(rf'{xlabel}', fontsize=font_size)
    axs.set_ylabel(rf'{ylabel}', fontsize=font_size)
    axs.set_title(rf'{title}', fontsize=font_size)
    axs.tick_params(axis='both', which='major', labelsize=tick_label_size, width=tick_thickness)

    if not grid:
        axs.grid(False)

    if xlim:
        axs.set_xlim(xlim)
    if ylim:
        axs.set_ylim(ylim)

    if x_tick_interval:
        axs.set_xticks(np.arange(xlim[0], xlim[1], x_tick_interval))
    if y_tick_interval:
        axs.set_yticks(np.arange(ylim[0], ylim[1], y_tick_interval))

    if border:
        for spine in axs.spines.values():
            spine.set_linewidth(border_thickness)
    else:
        for spine in axs.spines.values():
            spine.set_visible(False)

    if legend and labels:
        axs.legend(title=leg_title, title_fontsize=font_size*0.8, 
                   prop={'size': font_size*0.8}, handlelength=0.5)

    plt.rcParams.update({
        'text.usetex': True,
        'font.family': 'serif',
        'font.serif': ['Computer Modern'],
        'axes.labelsize': font_size,
        'font.size': font_size
    })

    return myplot
