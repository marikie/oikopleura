import os
os.environ["OMP_NUM_THREADS"] = "1" # ←Why this is not working?  P.S. This worked well on another environment.

from sklearn.cluster import KMeans

import matplotlib.pyplot as plt

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rcParams
rcParams['font.family'] = 'MS Gothic'
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
import pandas as pd

n_samples = 18
n_features = 96 # 4 x 4 x 6
X = np.zeros((n_samples, n_features))



file_names = []


for file in os.listdir('.'):  # 現在のディレクトリを使用
    if file.endswith('_20250325_maflinked.tsv') and len(file.split('_')[0]) == 6:
        file_names.append(file)

if len(file_names) != n_samples:
    raise ValueError("ファイル数がn_samplesと一致しません。")


for i, file_name in enumerate(file_names):
    with open(file_name, 'r') as f:
        lines = f.readlines()

    for j, line in enumerate(lines[1:97]):
        columns = line.strip().split('\t')
        mutNum = int(columns[1])
        totalRootNum = int(columns[2])
        X[i, j] = mutNum / totalRootNum


#print("ファイル名配列:", file_names)
#print("結果行列 X:", X)


# データの標準化
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# 3次元に圧縮
pca = PCA(n_components=3)
X_pca = pca.fit_transform(X_scaled)
print("元の形状:", X.shape)
print("圧縮後の形状:", X_pca.shape)
print("PC1の寄与率:", pca.explained_variance_ratio_[0])
print("PC2の寄与率:", pca.explained_variance_ratio_[1])
print("PC3の寄与率:", pca.explained_variance_ratio_[2])
print("合計寄与率:", sum(pca.explained_variance_ratio_))

# OptimalNumber of Clustersを見つける（ Elbow MethodとSilhouette Score）
#  Elbow Method: クラスタ数を増やし誤差平方和(WCSS,重心とデータ店の距離の平方の和)の減少を観察、Optimalクラスタ数を決定。
# Silhouette Score: 各データが適切なクラスタに属しているかを評価する指標(値は-1～1)。 S = (b - a)/max(a, b)
# a: クラスタ内のほかのデータ店との平均距離、コンパクトさの指標
# b: 最も近いクラスタのデータ点との平均距離
max_clusters = 10
inertia_values = []
silhouette_scores = []

for k in range(2, max_clusters + 1):
    kmeans = KMeans(n_clusters=k, random_state=1, n_init=10)
    kmeans.fit(X_pca)
    inertia_values.append(kmeans.inertia_)
    silhouette_scores.append(silhouette_score(X_pca, kmeans.labels_))

plt.figure(figsize=(12, 5))
plt.subplot(1, 2, 1)
plt.plot(range(2, max_clusters + 1), inertia_values, 'bo-')
plt.xlabel('Number of Clusters')
plt.ylabel('Inertia') #≒WCSS
plt.title('Optimization of the Number of Clusters by Elbow Method')
plt.grid(True)

plt.subplot(1, 2, 2)
plt.plot(range(2, max_clusters + 1), silhouette_scores, 'ro-')
plt.xlabel('Number of Clusters')
plt.ylabel('Silhouette Score')
plt.title('Optimization of the Number of Clusters by Silhouette Score')
plt.grid(True)
plt.tight_layout()
plt.show()

# OptimalNumber of Clustersを決定
optimal_clusters = silhouette_scores.index(max(silhouette_scores)) + 2
print(f"Optimal Clusters: {optimal_clusters} (Silhouette Score: {max(silhouette_scores):.4f})")

# K-meansを実行
kmeans = KMeans(n_clusters=optimal_clusters, random_state=42, n_init=10)
cluster_labels = kmeans.fit_predict(X_pca)
centroids = kmeans.cluster_centers_

# 3次元での可視化
fig = plt.figure(figsize=(14, 10))
ax = fig.add_subplot(111, projection='3d')

# 各クラスタを異なる色で表示
scatter = ax.scatter(
    X_pca[:, 0], X_pca[:, 1], X_pca[:, 2], 
    c=cluster_labels, 
    cmap='viridis', 
    alpha=0.7, 
    s=70
)

# クラスター中心を表示
ax.scatter(
    centroids[:, 0], centroids[:, 1], centroids[:, 2], 
    marker='X', 
    s=200, 
    c='red', 
    label='Center'
)

ax.set_xlabel('PC1', fontsize=12)
ax.set_ylabel('PC2', fontsize=12)
ax.set_zlabel('PC3', fontsize=12)
ax.set_title(f'K-means Clustering（Num of Clusters: {optimal_clusters}）', fontsize=14)



plt.savefig('pca_3d_clustering_result.png')
plt.tight_layout()
plt.show()

# 2 Dimentional Projection
fig, axs = plt.subplots(1, 3, figsize=(18, 6))

# PC1 vs PC2
axs[0].scatter(X_pca[:, 0], X_pca[:, 1], c=cluster_labels, cmap='viridis', alpha=0.7, s=70)
axs[0].scatter(centroids[:, 0], centroids[:, 1], marker='X', s=200, c='red')
axs[0].set_xlabel('PC1')
axs[0].set_ylabel('PC2')
axs[0].set_title('PC1 vs PC2')
axs[0].grid(True)

# PC1 vs PC3
axs[1].scatter(X_pca[:, 0], X_pca[:, 2], c=cluster_labels, cmap='viridis', alpha=0.7, s=70)
axs[1].scatter(centroids[:, 0], centroids[:, 2], marker='X', s=200, c='red')
axs[1].set_xlabel('PC1')
axs[1].set_ylabel('PC3')
axs[1].set_title('PC1 vs PC3')
axs[1].grid(True)

# PC2 vs PC3
axs[2].scatter(X_pca[:, 1], X_pca[:, 2], c=cluster_labels, cmap='viridis', alpha=0.7, s=70)
axs[2].scatter(centroids[:, 1], centroids[:, 2], marker='X', s=200, c='red')
axs[2].set_xlabel('PC2')
axs[2].set_ylabel('PC3')
axs[2].set_title('PC2 vs PC3')
axs[2].grid(True)

plt.tight_layout()
plt.savefig('pca_3d_projections.png')
plt.show()

# 各クラスターのサンプル数を表示
cluster_counts = pd.Series(cluster_labels).value_counts().sort_index()
print("\nNumber of Samples for Each Clusters:")
for cluster_id, count in cluster_counts.items():
    print(f"クラスター {cluster_id}: {count}サンプル")

# 結果のデータフレーム作成
result_df = pd.DataFrame({
    'file name': file_names[:],
    'PC1': X_pca[:, 0],
    'PC2': X_pca[:, 1],
    'PC3': X_pca[:, 2],
    'Cluster': cluster_labels
})

print("\nResult:")
print(result_df.head(n_samples))

# CSVに保存
result_df.to_csv('clustering_result_PC3.csv', index=False)