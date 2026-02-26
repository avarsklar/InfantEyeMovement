import csv
import matplotlib.pyplot as plt

filename = "ZooMus_115_features_raw.csv"

time = []
roughness = []

with open(filename, newline='') as file:
    reader = csv.reader(file)
    next(reader)  # skip header
    
    for row in reader:
        time.append(float(row[0]) / 1000)  # convert ms → seconds
        roughness.append(float(row[3]))    # roughness column

# --- Clean Plot ---

plt.figure(figsize=(9, 5))

plt.plot(time, roughness, color="#2ca02c", linewidth=2)

plt.xlabel("Time (seconds)", fontsize=12)
plt.ylabel("Roughness", fontsize=12)
plt.title("Roughness Over Time", fontsize=14)

plt.grid(True, linestyle="--", linewidth=0.5, alpha=0.6)

# Remove extra borders (minimalist style)
plt.gca().spines["top"].set_visible(False)
plt.gca().spines["right"].set_visible(False)

plt.tight_layout()
plt.savefig("roughness_plot.png", dpi=300)
plt.show()
