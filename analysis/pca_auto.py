#!/usr/bin/env python3

import argparse
import json
import os
import sys
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from matplotlib import rcParams
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler

rcParams["font.family"] = "MS Gothic"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Run PCA and clustering on substitution TSV files")
    parser.add_argument("--tsv_dir", required=True, help="Directory containing TSV files")
    parser.add_argument("--metadata_dir", required=True, help="Directory containing accession metadata JSON files")
    parser.add_argument("--output_dir", required=True, help="Directory to write PCA outputs")
    parser.add_argument("--dimensions", type=int, nargs="*", default=[2], choices=[2, 3], help="Target dimensions for PCA (2 and/or 3)")
    parser.add_argument("--tsv_pattern", default="*.tsv", help="Glob pattern to select TSV files")
    parser.add_argument("--random_state", type=int, default=42, help="Random seed for clustering")
    parser.add_argument("--max_clusters", type=int, default=10, help="Maximum number of clusters to test")
    return parser.parse_args()


def load_tsv_files(tsv_dir: Path, pattern: str) -> list[Path]:
    files = sorted(tsv_dir.glob(pattern))
    if not files:
        raise FileNotFoundError(f"TSV files matching pattern '{pattern}' not found in {tsv_dir}")
    return files


def parse_filename_info(tsv_path: Path) -> tuple[str, str, str]:
    name = tsv_path.stem
    parts = name.split("_")
    if len(parts) < 3:
        raise ValueError(f"Unexpected TSV filename format: {tsv_path.name}")
    accession = parts[0]
    short_name = parts[1]
    date = parts[2]
    return accession, short_name, date


def load_metadata(metadata_dir: Path, accession: str) -> dict:
    json_path = metadata_dir / f"{accession}.json"
    if not json_path.exists():
        raise FileNotFoundError(f"Metadata JSON not found for accession {accession} at {json_path}")
    with json_path.open("r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def extract_label(accession: str, short_name: str, metadata: dict) -> str:
    reports = metadata.get("reports", [])
    if not reports:
        return f"{short_name} ({accession})"

    organism_info = reports[0].get("organism", {})
    organism_name = organism_info.get("organism_name")
    infra = organism_info.get("infraspecific_names", [])

    if organism_name:
        label = organism_name.replace(" ", "_")
        if infra:
            infra_text = "_".join(str(item).replace(" ", "_") for item in infra)
            label = f"{label}_{infra_text}"
        return f"{label} ({short_name})"
    return f"{short_name} ({accession})"


def read_tsv_matrix(tsv_file: Path) -> np.ndarray:
    df = pd.read_csv(tsv_file, sep="\t")
    if {"mutNum", "totalRootNum"} - set(df.columns):
        raise ValueError(f"TSV file {tsv_file} missing required columns")
    values = df[["mutNum", "totalRootNum"]].to_numpy(dtype=float)
    with np.errstate(divide="ignore", invalid="ignore"):
        fractions = np.divide(values[:, 0], values[:, 1], out=np.zeros_like(values[:, 0]), where=values[:, 1] != 0)
    return fractions


def build_matrix(tsv_files: list[Path]) -> np.ndarray:
    rows = []
    for file in tsv_files:
        rows.append(read_tsv_matrix(file))
    return np.vstack(rows)


def determine_clusters(data: np.ndarray, max_clusters: int, random_state: int) -> tuple[int, list[float], list[float]]:
    inertia_values = []
    silhouette_scores = []

    if data.shape[0] < 2:
        raise ValueError("At least two samples are required for clustering")

    if data.shape[0] <= max_clusters:
        max_clusters = data.shape[0] - 1
        if max_clusters < 2:
            max_clusters = 2

    for k in range(2, max_clusters + 1):
        model = KMeans(n_clusters=k, random_state=random_state, n_init=10)
        labels = model.fit_predict(data)
        inertia_values.append(model.inertia_)
        silhouette_scores.append(silhouette_score(data, labels))

    best_k = silhouette_scores.index(max(silhouette_scores)) + 2
    return best_k, inertia_values, silhouette_scores


def plot_metrics(output_dir: Path, inertia: list[float], silhouette: list[float]) -> None:
    ks = range(2, 2 + len(inertia))
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    axes[0].plot(ks, inertia, "bo-")
    axes[0].set_xlabel("Number of Clusters")
    axes[0].set_ylabel("Inertia")
    axes[0].set_title("Elbow Method")
    axes[0].grid(True)

    axes[1].plot(ks, silhouette, "ro-")
    axes[1].set_xlabel("Number of Clusters")
    axes[1].set_ylabel("Silhouette Score")
    axes[1].set_title("Silhouette Scores")
    axes[1].grid(True)

    plt.tight_layout()
    fig.savefig(output_dir / "clustering_metrics.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


def ensure_output_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def run_pca(data: np.ndarray, n_components: int) -> tuple[np.ndarray, PCA]:
    if n_components > min(data.shape[0], data.shape[1]):
        n_components = min(data.shape[0], data.shape[1])
    scaler = StandardScaler()
    scaled = scaler.fit_transform(data)
    pca = PCA(n_components=n_components)
    transformed = pca.fit_transform(scaled)
    return transformed, pca


def visualize_pca(pca_data: np.ndarray, cluster_labels: np.ndarray, centroids: np.ndarray, labels: list[str], n_components: int, output_dir: Path) -> None:
    if n_components == 2:
        fig, ax = plt.subplots(figsize=(14, 12))
        scatter = ax.scatter(pca_data[:, 0], pca_data[:, 1], c=cluster_labels, cmap="viridis", alpha=0.7, s=70)
        ax.scatter(centroids[:, 0], centroids[:, 1], marker="X", s=200, c="red", label="Cluster Center")

        for idx, text in enumerate(labels):
            ax.annotate(text, (pca_data[idx, 0], pca_data[idx, 1]), xytext=(5, 5), textcoords="offset points", fontsize=9, bbox=dict(boxstyle="round,pad=0.3", fc="white", alpha=0.7))

        ax.set_xlabel("PC1")
        ax.set_ylabel("PC2")
        ax.set_title(f"K-means Clustering (k={len(centroids)})")
        ax.legend()
        ax.grid(True)
        fig.savefig(output_dir / "pca_2d_clustering.png", dpi=300, bbox_inches="tight")
        plt.close(fig)

    elif n_components == 3:
        from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

        fig = plt.figure(figsize=(14, 10))
        ax = fig.add_subplot(111, projection="3d")
        scatter = ax.scatter(pca_data[:, 0], pca_data[:, 1], pca_data[:, 2], c=cluster_labels, cmap="viridis", alpha=0.7, s=70)
        ax.scatter(centroids[:, 0], centroids[:, 1], centroids[:, 2], marker="X", s=200, c="red", label="Cluster Center")

        for idx, text in enumerate(labels):
            ax.text(pca_data[idx, 0], pca_data[idx, 1], pca_data[idx, 2], text, size=8, zorder=1, color="black")

        ax.set_xlabel("PC1")
        ax.set_ylabel("PC2")
        ax.set_zlabel("PC3")
        ax.set_title(f"K-means Clustering (k={len(centroids)})")
        ax.legend()
        plt.tight_layout()
        fig.savefig(output_dir / "pca_3d_clustering.png", dpi=300, bbox_inches="tight")
        plt.close(fig)


def save_results(output_dir: Path, files: list[Path], pca_data_map: dict[int, np.ndarray], cluster_labels: np.ndarray, metadata: list[dict]) -> None:
    lines = []
    for idx, file in enumerate(files):
        dims = {}
        for n_components, data in pca_data_map.items():
            dims[f"PC{n_components}"] = data[idx].tolist()

        info = metadata[idx]
        entry = {
            "file": file.name,
            "accession": info["accession"],
            "short_name": info["short"],
            "date": info["date"],
            "cluster": int(cluster_labels[idx]),
        }
        for dim_index, data in pca_data_map.items():
            entry[f"PC{dim_index}"] = data[idx].tolist()

        lines.append(entry)

    df = pd.DataFrame(lines)
    df.to_csv(output_dir / "clustering_results.csv", index=False)


def main() -> None:
    args = parse_args()

    tsv_dir = Path(args.tsv_dir)
    metadata_dir = Path(args.metadata_dir)
    output_dir = Path(args.output_dir)

    ensure_output_dir(output_dir)

    tsv_files = load_tsv_files(tsv_dir, args.tsv_pattern)

    matrix_rows = []
    metadata_records = []
    labels = []

    for tsv_file in tsv_files:
        accession, short_name, date = parse_filename_info(tsv_file)
        metadata_json = {}
        try:
            metadata_json = load_metadata(metadata_dir, accession)
            label = extract_label(accession, short_name, metadata_json)
        except FileNotFoundError:
            metadata_json = {}
            label = f"{short_name} ({accession})"

        matrix_rows.append(read_tsv_matrix(tsv_file))
        metadata_records.append({"accession": accession, "short": short_name, "date": date, "label": label})
        labels.append(label)

    data_matrix = np.vstack(matrix_rows)

    clustering_basis_dim = min(3, data_matrix.shape[1], data_matrix.shape[0])
    cluster_input_data, _ = run_pca(data_matrix, n_components=clustering_basis_dim)
    best_k, inertia_values, silhouette_scores = determine_clusters(
        cluster_input_data, args.max_clusters, args.random_state
    )
    plot_metrics(output_dir, inertia_values, silhouette_scores)

    final_model = KMeans(n_clusters=best_k, random_state=args.random_state, n_init=10)
    final_labels = final_model.fit_predict(cluster_input_data)

    pca_results: dict[int, np.ndarray] = {}

    for dim in args.dimensions:
        transformed, _ = run_pca(data_matrix, n_components=dim)
        pca_results[dim] = transformed

        if dim <= clustering_basis_dim:
            centroids_subset = final_model.cluster_centers_[:, :dim]
        else:
            extra_dims = dim - clustering_basis_dim
            centroids_subset = np.hstack(
                (final_model.cluster_centers_, np.zeros((final_model.cluster_centers_.shape[0], extra_dims)))
            )

        visualize_pca(transformed, final_labels, centroids_subset, labels, dim, output_dir)

    save_results(output_dir, tsv_files, pca_results, final_labels, metadata_records)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
