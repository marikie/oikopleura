library(dplyr)
library(ggplot2)
library(ggrepel)

# tsv_path <- "~/biohazard/data/mytTro_mytEdu_mytGal/mytEdu_20250407_maflinked_annot.tsv"
generate_plots <- function(tsv_path) {
  data <- read.csv(tsv_path, sep = "\t", header = TRUE)

  # Add transition column to data
  # Add observed figure of mutNum/totalRootNum
  # Add observed figure of s_ncds/o_ncds
  data <- data %>%
    mutate(trans = substr(mutType, 3, 5)) %>%
    mutate(obs_mut_over_ori = mutNum / totalRootNum) %>%
    mutate(obs_snc_over_onc = s_ncds / o_ncds)
  all_ori_sum <- data %>%
    select(oriType, totalRootNum) %>%
    unique() %>%
    pull(totalRootNum) %>%
    sum()
  all_ori_sum_ncds <- data %>%
    select(oriType, o_ncds) %>%
    unique() %>%
    pull(o_ncds) %>%
    sum()

  allsbst_over_allori <- (data %>% select(mutNum) %>% sum()) / all_ori_sum
  allsbst_ncds_over_allori_ncds <- (data %>% select(s_ncds) %>% sum()) / all_ori_sum_ncds

  print(paste("all_ori_sum: ", all_ori_sum))
  print(paste("all_sbst_sum: ", data %>% select(mutNum) %>% sum()))
  print(paste("allsbst_over_allori: ", allsbst_over_allori))

  print(paste("all_ori_sum_ncds: ", all_ori_sum_ncds))
  print(paste("all_sbst_sum_ncds: ", data %>% select(s_ncds) %>% sum()))
  print(paste("allsbst_ncds_over_allori_ncds", allsbst_ncds_over_allori_ncds))

  data <- data %>%
    mutate(logRatio = log2(obs_mut_over_ori / allsbst_over_allori)) %>%
    mutate(logRatio_ncds = log2(obs_snc_over_onc / allsbst_ncds_over_allori_ncds))

  print(data)

  # Calculate mean and standard deviation
  mean_val <- mean(data$logRatio_ncds, na.rm = TRUE)
  sd_val <- sd(data$logRatio_ncds, na.rm = TRUE)

  # Plot logRatio_ncds for each transition
  p <- ggplot(data, aes(x = trans, y = logRatio_ncds)) +
    geom_point(size = 3, alpha = 0.7) +
    geom_text_repel(aes(label = oriType), hjust = -0.2, vjust = 0.5, size = 3, max.overlaps = Inf) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    geom_hline(yintercept = mean_val, linetype = "solid", color = "blue", linewidth = 1) +
    geom_hline(yintercept = mean_val + sd_val, linetype = "dotted", color = "green", linewidth = 1) +
    geom_hline(yintercept = mean_val - sd_val, linetype = "dotted", color = "green", linewidth = 1) +
    geom_hline(yintercept = mean_val + 2 * sd_val, linetype = "dotted", color = "orange", linewidth = 1) +
    geom_hline(yintercept = mean_val - 2 * sd_val, linetype = "dotted", color = "orange", linewidth = 1) +
    labs(
      title = "Log Ratio of Observed vs Null Rate (Non-CDS)",
      subtitle = paste("Mean =", round(mean_val, 3), ", SD =", round(sd_val, 3)),
      x = "Transition Type",
      y = "Log2 Ratio (Observed/Null)"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5, color = "blue")
    )

  # Create a separate plot for all logRatio_ncds with mutType names
  p2 <- ggplot(data, aes(x = "All Data", y = logRatio_ncds)) +
    geom_point(size = 3, alpha = 0.7, color = "red") +
    geom_text_repel(aes(label = mutType), hjust = -0.2, vjust = 0.5, size = 3, angle = 45, max.overlaps = Inf) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "black") +
    geom_hline(yintercept = mean_val, linetype = "solid", color = "blue", linewidth = 1) +
    geom_hline(yintercept = mean_val + sd_val, linetype = "dotted", color = "green", linewidth = 1) +
    geom_hline(yintercept = mean_val - sd_val, linetype = "dotted", color = "green", linewidth = 1) +
    geom_hline(yintercept = mean_val + 2 * sd_val, linetype = "dotted", color = "orange", linewidth = 1) +
    geom_hline(yintercept = mean_val - 2 * sd_val, linetype = "dotted", color = "orange", linewidth = 1) +
    labs(
      title = "All logRatio_ncds Values with mutType Labels",
      subtitle = paste("Mean =", round(mean_val, 3), ", SD =", round(sd_val, 3)),
      x = "",
      y = "Log2 Ratio (Observed/Null)"
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5, color = "blue")
    )

  # Extract the path without an extension from tsv_path
  path_without_extension <- tools::file_path_sans_ext(tsv_path)
  # Create file paths for the plots
  p_path <- paste(path_without_extension, "_p.pdf", sep = "")
  p2_path <- paste(path_without_extension, "_p2.pdf", sep = "")

  ggsave(filename = p_path, plot = p, device = "pdf", width = 10, height = 8)
  ggsave(filename = p2_path, plot = p2, device = "pdf", width = 10, height = 8)
}

# Access the arguments
args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
generate_plots(tsv_path)
