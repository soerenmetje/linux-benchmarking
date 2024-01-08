import os
import numpy as np
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

import common

benchmark = "sysbench-cpu"

# If script is executed from plot directory, change to content root directory
if os.path.split(os.getcwd())[-1] == "plot":
    os.chdir("../..")

# Read data
plot_path = f"plots/plot-{benchmark}.jpg"

data_dir = f"data/{benchmark}"
directories = [d for d in os.listdir(data_dir) if os.path.isdir(os.path.join(data_dir, d))]
project_dirs = [os.path.join(data_dir, p) for p in directories]

# Find file with the highest number
benchmark_files = [os.path.join(d, max(os.listdir(d))) for d in project_dirs if os.path.exists(d)]
print(benchmark_files)

df = pd.concat([pd.read_csv(p, sep=";") for p in benchmark_files])
print(df)

# Plot data

sns.set_theme(style="whitegrid")
chart = sns.barplot(data=df[["project", "score"]], hue="project",
                    x="project", y="score",
                    estimator=np.mean, errorbar='sd', capsize=.1, alpha=0.8)
chart.set(xlabel='Machine', ylabel='Compute Performance  [Events/s]\nhigher is better')

for i in chart.containers:
    chart.bar_label(i, label_type="center", fmt="%.0f")

plt.tight_layout(h_pad=2)
plt.savefig(plot_path, dpi=300)
#plt.show()

print(f"\nPlot {plot_path} created / updated")
