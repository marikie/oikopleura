library(stringr)
library(RColorBrewer)
library(showtext)
library(ggplot2)
library(reshape2)

generate_plot <- function(file_path, filename, graph_type) {
  # read file
  data <- read.csv(file_path, sep = "\t", header = TRUE)
  data.trans <- setNames(data.frame(t(data[, -1])), data[, 1])

  # make the horizontal trinuc labels
  data.names <- names(data.trans)
  firstchar <- str_extract(data.names, "^.")
  lastchar <- str_extract(data.names, ".$")
  midorichar <- str_extract(str_extract(data.names, "(.)>"), "^.")
  trinuc.lab <- paste(firstchar, midorichar, lastchar, sep = "")

  # color and text array
  colour_array <- brewer.pal(6, "Dark2")
  text_array <- c("C > A", "C > G", "C > T", "T > A", "T > C", "T > G")

  # Extract values into vectors
  coding_vals <- as.numeric((data.trans["coding", ] / data.trans["mutNum", ]) * 100)
  noncoding_vals <- as.numeric((data.trans["non.coding", ] / data.trans["mutNum", ]) * 100)

  # Create color vector for Coding (6 colors × 16 = 96 bars)
  coding_cols <- rep(brewer.pal(6, "Dark2"), each = 16)

  ##########################################
  #  make the stacked bar chart
  ##########################################
  pdf(filename, width = 30, height = 8)
  font_add_google("Courier Prime", "mn", 700)
  font_add_google("Roboto", "os")
  showtext_auto()
  # Increase the size of y-axis numbers # Increase the bottom, left, top, and right margins
  par(family = "mn", mar = c(7.5, 6, 7.5, 1), cex.axis = 2)

  # Draw Coding part (add black border with border="black" and adjust line width with lwd=1)
  bp <- barplot(
    coding_vals,
    col = coding_cols,
    border = "black",
    lwd = 1,
    axes = FALSE,
    ylim = c(0, 100),
    space = 0,
  )

  # Draw Non-coding part (add black border with border="black" and adjust line width with lwd=1)
  barplot(
    noncoding_vals,
    col       = "grey70",
    border    = "black",
    lwd       = 1,
    add       = TRUE,
    axes      = FALSE,
    space     = 0,
    offset    = coding_vals
  )

  # Add Y axis
  axis(
    side   = 2,
    at     = seq(0, 100, by = 20),
    labels = paste0(seq(0, 100, by = 20), "%"),
    las    = 1
  )

  # Add x-axis trinucleotide labels
  for (i in seq_along(trinuc.lab)) {
    label <- trinuc.lab[i]
    x_pos <- bp[i]
    base_y <- par("usr")[3] - 0.03 * (par("usr")[4] - par("usr")[3])
    if (i %% 16 != 0) {
      coln <- i %/% 16 + 1
    } else {
      coln <- i %/% 16
    }
    # Last letter (slightly under the x axis)
    text(
      family = "mn", x_pos, base_y, substr(label, 3, 3),
      xpd = TRUE, cex = 2, srt = 90
    )
    # Middle letter (colored red, slightly above the first letter)
    text(
      family = "mn", x_pos, base_y - strwidth(label) * 0.03 * (par("usr")[4] - par("usr")[3]), substr(label, 2, 2),
      xpd = TRUE, cex = 2, col = colour_array[coln], srt = 90
    )
    # First letter (at the bottom)
    text(
      family = "mn", x_pos, base_y - strwidth(label) * 0.06 * (par("usr")[4] - par("usr")[3]), substr(label, 1, 1),
      xpd = TRUE, cex = 2, srt = 90
    )
  }

  # add xlab and ylab
  mtext(family = "os", "Original Trinucleotides", side = 1, line = 5.5, cex = 2.5) # modify size by cex
  # mtext(family = "os", "#Subs/#OrigTrinucs (%)", side = 2, line = 0.5, cex = 2.5) # cexでサイズ調整


  # Calculate the width of the bars
  bar_widths <- diff(bp)
  bar_width <- mean(bar_widths)

  total_size_per_group <- bar_width * 16
  pct_yaxs_max <- 100

  for (i in 1:6) {
    left <- (i - 1) * total_size_per_group + 0.2 # to create a bit of white space
    right <- i * total_size_per_group - 0.2
    label_mid <- total_size_per_group / 2 + (i - 1) * total_size_per_group

    rect(left, pct_yaxs_max + 0.05 * pct_yaxs_max, right, pct_yaxs_max + 0.08 * pct_yaxs_max, col = colour_array[i], border = NA)
    text(family = "mn", x = label_mid, y = pct_yaxs_max + 0.12 * pct_yaxs_max, labels = text_array[i], cex = 2.5) # increase label size with cex
  }

  # Add legend
  legend(
    "bottomright",
    legend = c("Coding", "Non-coding"),
    fill   = c("white", "grey70"),
    border = NA,
    bty    = "n"
  )

  dev.off()
}

args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
# Extract the path without an extension from tsv_path
path_without_extension <- tools::file_path_sans_ext(tsv_path)
stackedBarChart_path <- paste(path_without_extension, "_stackedBarChart.pdf", sep = "")

generate_plot(tsv_path, filename = stackedBarChart_path, graph_type = "stacked")
