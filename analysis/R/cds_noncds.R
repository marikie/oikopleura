library(stringr)
library(RColorBrewer)
library(showtext)
library(ggplot2)
library(reshape2)

file_path <- "~/biohazard/data/test_test_test/oikAlb_20250407_annot.tsv"
generate_plot <- function(file_path, filename = 0, graph_type) {
  # read file
  data <- read.csv(file_path, sep = "\t", header = TRUE)
  data.trans <- setNames(data.frame(t(data[, -1])), data[, 1])

  # make the horizontal trinuc labels
  data.names <- names(data.trans)
  firstchar <- str_extract(data.names, "^.")
  lastchar <- str_extract(data.names, "$")
  midorichar <- str_extract(str_extract(data.names, "(.)>"), "^.")
  trinuc.lab <- paste(firstchar, midorichar, lastchar, sep = "")

  # color and text array
  colour_array <- brewer.pal(6, "Dark2")
  text_array <- c("C > A", "C > G", "C > T", "T > A", "T > C", "T > G")

  # Calculate the proportions
  codingProportion <- (data.trans["coding", ] / data.trans["mutNum", ]) * 100
  nonCodingProportion <- (data.trans["non.coding", ] / data.trans["mutNum", ]) * 100

  # Add the proportions as new rows
  data.trans <- rbind(data.trans, 
                      codingProportion = codingProportion, 
                      nonCodingProportion = nonCodingProportion)
  
  # 1) 値をベクトルに取り出す
  coding_vals    <- as.numeric(data.trans["codingProportion", ])
  noncoding_vals <- as.numeric(data.trans["nonCodingProportion", ])
  
  # 2) Coding 用の色ベクトルを作成（6 色 × 16 = 96 本）
  coding_cols <- rep(brewer.pal(6, "Dark2"), each = 16)
  
  # make the stacked bar chart
  font_add_google("Courier Prime", "mn", 700)
  font_add_google("Roboto", "os")
  showtext_auto()
  # Increase the size of y-axis numbers # Increase the bottom, left, top, and right margins
  par(family = "mn", mar = c(7.5, 6, 4, 1), cex.axis = 2) 
  
  # 4) Coding 部分を描く（border="black" で黒枠を付与、lwd=1 で線幅を調整）
  bp <- barplot(
    coding_vals,
    col       = coding_cols,
    border    = "black",
    lwd       = 1,
    axes      = FALSE,
    names.arg = rep("", length(coding_vals)), 
    ylim      = c(0, 100),
    space     = 0
  )
  
  # 5) Non-coding 部分を重ねて描く
  barplot(
    noncoding_vals,
    col       = "grey70",
    border    = "black",
    lwd       = 1,
    add       = TRUE,
    axes      = FALSE, 
    names.arg = rep("", length(noncoding_vals)),
    space     = 0,
    offset    = coding_vals
  )
  
  # 6) Y 軸だけ追加
  axis(
    side   = 2,
    at     = seq(0, 100, by = 20),
    labels = paste0(seq(0, 100, by = 20), "%"),
    las    = 1
  )

  # 7) 凡例
  legend(
    "bottommright",
    legend = c("Coding", "Non-coding"),
    fill   = c("white", "grey70"),
    border = NA,
    bty    = "n"
  )
  
  # add xlab and ylab
  mtext(family = "os", "Original Trinucleotides", side = 1, line = 5.5, cex = 2.5) # modify size by cex
  mtext(family = "os", "#Subs/#OrigTrinucs (%)", side = 2, line = 0.5, cex = 2.5) # cexでサイズ調整

  # Calculate the width of the bars
  bar_widths <- diff(bar_positions)
  bar_width <- mean(bar_widths)
  # Print the bar width for debugging
  # print(paste("Bar width: ", bar_width))

  total_size_per_group <- bar_width * 16

  # print("pct_yaxs_max: ")
  # print(pct_yaxs_max)
  for (i in 1:6) {
    # Size of 1.2 per bar.
    # Total size of 19.2 for 16 barplots
    left <- (i - 1) * total_size_per_group + 0.2 # to create a bit of white space
    right <- i * total_size_per_group - 0.2
    label_mid <- total_size_per_group / 2 + (i - 1) * total_size_per_group

    # rect(left,5.1,right,5.2, col=colour_array[i], border=NA)
    # rect(left,0.90*pct_yaxs_max,right,0.93*pct_yaxs_max, col=colour_array[i], border=NA)
    rect(left, pct_yaxs_max + 0.05 * pct_yaxs_max, right, pct_yaxs_max + 0.08 * pct_yaxs_max, col = colour_array[i], border = NA)
    text(family = "mn", x = label_mid, y = pct_yaxs_max + 0.12 * pct_yaxs_max, labels = text_array[i], cex = 2.5) # increase label size with cex
  }


  # Save the plot if a filename is provided
  if (filename != 0) {
    ggsave(filename, width = 10, height = 6)
  }
}

args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
# Extract the path without an extension from tsv_path
path_without_extension <- tools::file_path_sans_ext(tsv_path)
stackedBarChart_path <- paste(path_without_extension, "_stackedBarChart.pdf", sep = "")

generate_plot(tsv_path, filename = stackedBarChart_path, graph_type = "stacked")
