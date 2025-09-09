library(dplyr)
library(ggplot2)
library(stringr)
library(RColorBrewer)
library(showtext)
library(sysfonts)
library(rlang)

generate_plots <- function(tsv_path) {
  data <- read.csv(tsv_path, sep = "\t", header = TRUE)
  isAnno <- check_annotation_columns(data)

  path_without_extension <- tools::file_path_sans_ext(tsv_path)

  graph_path <- paste(path_without_extension, "_logRatio.pdf", sep = "")
  data <- add_logRatio(data)
  create_pdf(graph_path, data, value_col = "logRatio")

  if (isAnno) {
    graph_path_ncds <- paste(path_without_extension, "_logRatio_ncds.pdf", sep = "")
    data <- add_logRatio_ncds(data)
    create_pdf(graph_path_ncds, data, value_col = "logRatio_ncds")
  }
}

create_pdf <- function(graph_path, data, value_col = "logRatio") {
  # Prepare ordering by substitution type groups and within-group order
  group_order <- c("C>A", "C>G", "C>T", "T>A", "T>C", "T>G")
  # Fonts for labels
  sysfonts::font_add_google("Courier Prime", "mn", 700)
  sysfonts::font_add_google("Roboto", "os")
  showtext::showtext_auto()
  data <- data %>%
    mutate(trans = substr(mutType, 3, 5)) %>%
    mutate(trans = factor(trans, levels = group_order)) %>%
    arrange(trans, oriType)

  # Insert small gaps between groups on the x-axis
  gap_width <- 1
  data <- data %>%
    group_by(trans) %>%
    mutate(pos_in_group = row_number()) %>%
    ungroup()

  group_info <- data %>%
    group_by(trans) %>%
    summarise(group_size = max(pos_in_group), .groups = "drop") %>%
    arrange(trans) %>%
    mutate(offset = cumsum(dplyr::lag(group_size + gap_width, default = 0)))

  data <- data %>%
    left_join(group_info, by = "trans") %>%
    mutate(pos = pos_in_group + offset)

  # Stats
  value_sym <- rlang::sym(value_col)
  mean_val <- mean(data[[value_col]], na.rm = TRUE)
  # mean_val <- data %>%
  #   filter(substr(oriType, 2, 2) == "C") %>%
  #   pull(!!value_sym) %>%
  #   mean(na.rm = TRUE)
  sd_val <- sd(data[[value_col]], na.rm = TRUE)

  # X labels: oriType in the arranged order
  x_breaks <- data$pos
  x_labels <- data$oriType

  # Header rectangles like sbmut.R's add_colored_rectangles
  color_array <- RColorBrewer::brewer.pal(6, "Dark2")
  fill_map <- setNames(color_array, group_order)
  # Line colors: use Dark2 7th and 8th colors
  line_palette <- RColorBrewer::brewer.pal(8, "Dark2")
  line_base_col_a <- line_palette[7] # for y=0 and mean
  line_base_col_b <- line_palette[8] # for ±SD and ±2SD
  line_col_0 <- grDevices::adjustcolor(line_base_col_b, alpha.f = 1.00)
  line_col_mean <- grDevices::adjustcolor(line_base_col_a, alpha.f = 1.00)
  line_col_sd <- grDevices::adjustcolor(line_base_col_a, alpha.f = 1.00)
  line_col_2sd <- grDevices::adjustcolor(line_base_col_a, alpha.f = 1.00)

  yr <- range(data[[value_col]], na.rm = TRUE)
  y_span <- diff(yr)
  if (!is.finite(y_span) || y_span == 0) y_span <- 1
  yrect_low <- yr[2] + 0.16 * y_span
  yrect_high <- yr[2] + 0.20 * y_span
  y_text <- yr[2] + 0.24 * y_span
  # Custom x labels positions (moved further down)
  y_label3 <- yr[1] - 0.10 * y_span
  y_label2 <- yr[1] - 0.14 * y_span
  y_label1 <- yr[1] - 0.18 * y_span

  gdf <- data %>%
    group_by(trans) %>%
    summarise(
      xmin = min(pos) - 0.5,
      xmax = max(pos) + 0.5,
      xmid = (min(pos) + max(pos)) / 2,
      .groups = "drop"
    ) %>%
    mutate(trans = factor(trans, levels = group_order)) %>%
    arrange(trans) %>%
    mutate(label = c("C > A", "C > G", "C > T", "T > A", "T > C", "T > G"))

  labels_df <- data %>%
    distinct(pos, oriType, trans) %>%
    mutate(
      c1 = substr(oriType, 1, 1),
      c2 = substr(oriType, 2, 2),
      c3 = substr(oriType, 3, 3)
    )

  p <- ggplot(data, aes(x = pos, y = !!value_sym)) +
    geom_rect(
      data = gdf,
      aes(xmin = xmin, xmax = xmax, ymin = yrect_low, ymax = yrect_high, fill = trans),
      inherit.aes = FALSE, show.legend = FALSE
    ) +
    scale_fill_manual(values = fill_map, guide = "none") +
    # Make the header labels bold by setting fontface = "bold"
    annotate("text", x = gdf$xmid, y = y_text, label = gdf$label, size = 10, family = "os", fontface = "bold") +
    geom_segment(
      data = data,
      aes(x = pos, xend = pos, y = mean_val, yend = !!value_sym, color = trans),
      inherit.aes = FALSE,
      linewidth = 0.6, alpha = 0.8, show.legend = FALSE
    ) +
    scale_color_manual(values = fill_map, guide = "none") +
    geom_point(size = 4, aes(color = trans), show.legend = FALSE) +
    # Custom x labels: outer letters in black, middle letter in group color
    geom_text(
      data = labels_df, aes(x = pos, y = y_label3, label = c3),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = "black"
    ) +
    geom_text(
      data = labels_df, aes(x = pos, y = y_label1, label = c1),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = "black"
    ) +
    geom_text(
      data = subset(labels_df, trans == "C>A"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["C>A"]
    ) +
    geom_text(
      data = subset(labels_df, trans == "C>G"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["C>G"]
    ) +
    geom_text(
      data = subset(labels_df, trans == "C>T"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["C>T"]
    ) +
    geom_text(
      data = subset(labels_df, trans == "T>A"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["T>A"]
    ) +
    geom_text(
      data = subset(labels_df, trans == "T>C"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["T>C"]
    ) +
    geom_text(
      data = subset(labels_df, trans == "T>G"), aes(x = pos, y = y_label2, label = c2),
      inherit.aes = FALSE, angle = 90, size = 8, family = "mn", color = fill_map["T>G"]
    ) +
    geom_hline(yintercept = 0, linetype = "dotted", color = line_col_0) +
    geom_hline(yintercept = mean_val, linetype = "solid", color = line_col_mean, linewidth = 0.8) +
    geom_hline(yintercept = mean_val + sd_val, linetype = "dashed", color = line_col_sd) +
    geom_hline(yintercept = mean_val - sd_val, linetype = "dashed", color = line_col_sd) +
    geom_hline(yintercept = mean_val + 2 * sd_val, linetype = "dashed", color = line_col_2sd) +
    geom_hline(yintercept = mean_val - 2 * sd_val, linetype = "dashed", color = line_col_2sd) +
    scale_x_continuous(breaks = x_breaks, labels = x_labels, expand = c(0, 0), minor_breaks = NULL) +
    # labs(x = "Ancestral Trinucleotides", y = "Log2{(#Observed sbst/#Observed anc)\n/ ((sum of all sbst/sum of all anc)/3)}") +
    labs(x = "Ancestral Trinucleotides", y = "Log2{(#Observed sbst/#Observed anc)\n/ (sum of all sbst/sum of all anc)}") +
    theme_minimal(base_size = 12) +
    ggplot2::theme(
      axis.text.x = element_blank(),
      axis.title.x = element_text(size = 26, margin = margin(t = 60), family = "os"),
      axis.title.y = element_text(size = 26, margin = margin(r = 10), family = "os"),
      axis.text.y = element_text(size = 22, margin = margin(r = 8)),
      panel.grid.minor.x = element_blank(),
      plot.margin = margin(t = 12, r = 12, b = 12, l = 20)
    ) +
    coord_cartesian(ylim = c(yr[1], y_text), clip = "off")

  ggsave(filename = graph_path, plot = p, device = "pdf", width = 30, height = 8)
}

add_logRatio <- function(data) {
  # Add transition column to data
  # Add observed figure of mutNum/totalRootNum
  data <- data %>%
    mutate(trans = substr(mutType, 3, 5)) %>%
    mutate(obs_mut_over_ori = mutNum / totalRootNum)

  all_sbst_sum <- data %>%
    select(mutNum) %>%
    sum()
  all_ori_sum <- data %>%
    select(oriType, totalRootNum) %>%
    unique() %>%
    pull(totalRootNum) %>%
    sum()
  allsbst_over_allori <- all_sbst_sum / all_ori_sum

  data <- data %>%
    mutate(logRatio = log2(obs_mut_over_ori / allsbst_over_allori))
  return(data)
}

add_logRatio_ncds <- function(data) {
  data <- data %>%
    mutate(obs_snc_over_onc = s_ncds / o_ncds)

  all_sbst_ncds_sum <- data %>%
    select(s_ncds) %>%
    sum()
  sbst_ncds_c_sum <- data %>%
    filter(substr(oriType, 2, 2) == "C") %>%
    select(s_ncds) %>%
    sum()
  sbst_ncds_t_sum <- data %>%
    filter(substr(oriType, 2, 2) == "T") %>%
    select(s_ncds) %>%
    sum()
  all_ori_ncds_sum <- data %>%
    select(oriType, o_ncds) %>%
    unique() %>%
    pull(o_ncds) %>%
    sum()
  # Get the sum of o_ncds where the middle letter of oriType is "C"
  ori_ncds_c_sum <- data %>%
    filter(substr(oriType, 2, 2) == "C") %>%
    select(oriType, o_ncds) %>%
    unique() %>%
    pull(o_ncds) %>%
    sum()
  ori_ncds_t_sum <- data %>%
    filter(substr(oriType, 2, 2) == "T") %>%
    select(oriType, o_ncds) %>%
    unique() %>%
    pull(o_ncds) %>%
    sum()

  allsbst_ncds_over_allori_ncds <- all_sbst_ncds_sum / all_ori_ncds_sum
  sbst_ncds_c_over_ori_ncds_c <- sbst_ncds_c_sum / ori_ncds_c_sum
  sbst_ncds_t_over_ori_ncds_t <- sbst_ncds_t_sum / ori_ncds_t_sum
  print(paste("sbst_ncds_c_over_ori_ncds_c: ", sbst_ncds_c_over_ori_ncds_c))
  print(paste("sbst_ncds_t_over_ori_ncds_t: ", sbst_ncds_t_over_ori_ncds_t))
  print(paste("allsbst_ncds_over_allori_ncds: ", allsbst_ncds_over_allori_ncds))
  print(paste("sbst_ncds_c_over_ori_ncds_c/3: ", sbst_ncds_c_over_ori_ncds_c / 3))
  print(paste("sbst_ncds_t_over_ori_ncds_t/3: ", sbst_ncds_t_over_ori_ncds_t / 3))
  print(paste("allsbst_ncds_over_allori_ncds/3: ", allsbst_ncds_over_allori_ncds / 3))

  print(paste("mean of obs_snc_over_onc: ", data %>% pull(obs_snc_over_onc) %>% mean(na.rm = TRUE)))
  print(paste("mean of obs_snc_over_onc_c: ", data %>% filter(substr(oriType, 2, 2) == "C") %>% pull(obs_snc_over_onc) %>% mean(na.rm = TRUE)))
  print(paste("mean of obs_snc_over_onc_t: ", data %>% filter(substr(oriType, 2, 2) == "T") %>% pull(obs_snc_over_onc) %>% mean(na.rm = TRUE)))

  mean_obs_snc_over_onc <- data %>%
    pull(obs_snc_over_onc) %>%
    mean(na.rm = TRUE)
  # Add logRatio_ncds column based on the middle base of oriType
  # data <- data %>%
  #   mutate(
  #     logRatio_ncds = case_when(
  #       substr(oriType, 2, 2) == "C" ~ log2(obs_snc_over_onc / (sbst_ncds_c_over_ori_ncds_c / 3)),
  #       substr(oriType, 2, 2) == "T" ~ log2(obs_snc_over_onc / (sbst_ncds_t_over_ori_ncds_t / 3)),
  #       TRUE ~ NA_real_
  #     )
  #   )

  data <- data %>%
    mutate(logRatio_ncds = log2(obs_snc_over_onc / mean_obs_snc_over_onc))
  # mutate(logRatio_ncds = log2(obs_snc_over_onc / allsbst_ncds_over_allori_ncds))

  print(paste("mean of logRatio_ncds: ", data %>% pull(logRatio_ncds) %>% mean(na.rm = TRUE)))
  # logRatio_ncds_c_mean <- data %>%
  #   filter(substr(oriType, 2, 2) == "C") %>%
  #   pull(logRatio_ncds) %>%
  #   mean(na.rm = TRUE)
  # logRatio_ncds_t_mean <- data %>%
  #   filter(substr(oriType, 2, 2) == "T") %>%
  #   pull(logRatio_ncds) %>%
  #   mean(na.rm = TRUE)
  # print(paste("logRatio_ncds_c_mean: ", logRatio_ncds_c_mean))
  # print(paste("logRatio_ncds_t_mean: ", logRatio_ncds_t_mean))

  return(data)
}

check_annotation_columns <- function(data) {
  required_cols <- c("s_cds", "s_ncds", "o_cds", "o_ncds")
  return(all(required_cols %in% colnames(data)))
}
# Access the arguments
args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
generate_plots(tsv_path)
