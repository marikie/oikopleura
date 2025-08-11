library(stringr)
library(RColorBrewer)
library(showtext)
library(sysfonts)

# MODIFIED THE CODE FROM https://github.com/kartong88/Plot-Mutation-Landscape

generate_plots <- function(tsv_path) {
  data <- read_and_transform_data(tsv_path)
  isAnno <- check_annotation_columns(data)
  trinuc.lab <- generate_trinuc_labels(data)

  # Extract the path without an extension from tsv_path
  path_without_extension <- tools::file_path_sans_ext(tsv_path)
  # Create file paths for the plots (PNG)
  normgraph_path <- paste(path_without_extension, "_norm.pdf", sep = "")
  sbstgraph_path <- paste(path_without_extension, "_sbst.pdf", sep = "")
  origraph_path <- paste(path_without_extension, "_ori.pdf", sep = "")

  print(paste("Creating norm graph...", normgraph_path))
  create_pdf_plot(normgraph_path, data, trinuc.lab, "norm")
  print(paste("Creating sbst graph...", sbstgraph_path))
  create_pdf_plot(sbstgraph_path, data, trinuc.lab, "sbst")
  print(paste("Creating ori graph...", origraph_path))
  create_pdf_plot(origraph_path, data, trinuc.lab, "ori")

  # Generate additional plots if annotation data is present
  if (isAnno) {
    cdsgraph_path <- paste(path_without_extension, "_norm_cds.pdf", sep = "")
    noncdsgraph_path <- paste(path_without_extension, "_norm_noncds.pdf", sep = "")
    sbstcdsgraph_path <- paste(path_without_extension, "_sbst_cds.pdf", sep = "")
    oricdsgraph_path <- paste(path_without_extension, "_ori_cds.pdf", sep = "")
    sbstnoncdsgraph_path <- paste(path_without_extension, "_sbst_noncds.pdf", sep = "")
    orinoncdsgraph_path <- paste(path_without_extension, "_ori_noncds.pdf", sep = "")
    print(paste("Creating cds graph...", cdsgraph_path))
    create_pdf_plot(cdsgraph_path, data, trinuc.lab, "cds")
    print(paste("Creating noncds graph...", noncdsgraph_path))
    create_pdf_plot(noncdsgraph_path, data, trinuc.lab, "noncds")
    print(paste("Creating sbst cds graph...", sbstcdsgraph_path))
    create_pdf_plot(sbstcdsgraph_path, data, trinuc.lab, "sbstcds")
    print(paste("Creating ori cds graph...", oricdsgraph_path))
    create_pdf_plot(oricdsgraph_path, data, trinuc.lab, "oricds")
    print(paste("Creating sbst noncds graph...", sbstnoncdsgraph_path))
    create_pdf_plot(sbstnoncdsgraph_path, data, trinuc.lab, "sbstnoncds")
    print(paste("Creating ori noncds graph...", orinoncdsgraph_path))
    create_pdf_plot(orinoncdsgraph_path, data, trinuc.lab, "orinoncds")
  }

  process_norm_graph(data)
}

read_and_transform_data <- function(file_path) {
  data <- read.csv(file_path, sep = "\t", header = TRUE)
  data.trans <- setNames(data.frame(t(data[, -1])), data[, 1])
  return(data.trans)
}

check_annotation_columns <- function(data) {
  required_rows <- c("s_cds", "s_ncds", "o_cds", "o_ncds")
  return(all(required_rows %in% rownames(data)))
}

generate_trinuc_labels <- function(data) {
  data.names <- names(data)
  firstchar <- str_extract(data.names, "^.")
  lastchar <- str_extract(data.names, ".$")
  midorichar <- str_extract(str_extract(data.names, "(.)>"), "^.")
  trinuc.lab <- paste(firstchar, midorichar, lastchar, sep = "")
  return(trinuc.lab)
}

extract_values <- function(data, graph_type) {
  if (graph_type == "norm") {
    return(as.numeric(as.numeric(data["mutNum", ]) / as.numeric(data["totalRootNum", ]) * 100))
  } else if (graph_type == "sbst") {
    return(as.numeric(data["mutNum", ]))
  } else if (graph_type == "ori") {
    return(as.numeric(data["totalRootNum", ]))
  } else if (graph_type == "cds") {
    return(as.numeric(as.numeric(data["s_cds", ]) / as.numeric(data["o_cds", ]) * 100))
  } else if (graph_type == "noncds") {
    return(as.numeric(as.numeric(data["s_ncds", ]) / as.numeric(data["o_ncds", ]) * 100))
  } else if (graph_type == "sbstcds") {
    return(as.numeric(data["s_cds", ]))
  } else if (graph_type == "sbstnoncds") {
    return(as.numeric(data["s_ncds", ]))
  } else if (graph_type == "oricds") {
    return(as.numeric(data["o_cds", ]))
  } else if (graph_type == "orinoncds") {
    return(as.numeric(data["o_ncds", ]))
  } else {
    stop("Invalid graph type")
  }
}

compute_y_axis_max <- function(conv.data.norm) {
  raw_max <- max(na.omit(conv.data.norm))
  if (ceiling(raw_max) == 1) {
    if (raw_max < 0.1) {
      return(round(raw_max, 2))
    } else {
      return(round(raw_max, 1))
    }
  } else {
    return(ceiling(raw_max))
  }
}

create_pdf_plot <- function(filename, data, trinuc.lab, graph_type) {
  conv.data.norm <- extract_values(data, graph_type)
  pct_yaxs_max <- compute_y_axis_max(conv.data.norm)
  color_array <- brewer.pal(6, "Dark2")
  pdf(filename, width = 30, height = 8)
  font_add_google("Courier Prime", "mn", 700)
  font_add_google("Roboto", "os")
  showtext_auto()
  par(family = "mn", mar = c(7.5, 6, 4, 1), cex.axis = 2)
  bar_positions <- barplot(
    axes = FALSE,
    family = "os",
    as.numeric(conv.data.norm),
    col = rep(color_array, each = 16),
    cex.names = 0.7,
    las = 3,
    ylim = c(0, pct_yaxs_max + 0.15 * pct_yaxs_max),
    space = 0
  )
  # manually add y axis
  axis(side = 2, line = -3.5)
  add_labels(trinuc.lab, bar_positions)
  add_axis_names(graph_type)
  if (graph_type != "ori" && graph_type != "oricds" && graph_type != "orinoncds") {
    add_colored_rectangles(bar_positions, pct_yaxs_max, color_array)
  }
  dev.off()
}

add_labels <- function(trinuc.lab, bar_positions) {
  for (i in seq_along(trinuc.lab)) {
    label <- trinuc.lab[i]
    x_pos <- bar_positions[i]
    base_y <- par("usr")[3] - 0.03 * (par("usr")[4] - par("usr")[3])
    if (i %% 16 != 0) {
      coln <- i %/% 16 + 1
    } else {
      coln <- i %/% 16
    }
    text(family = "mn", x_pos, base_y, substr(label, 3, 3), xpd = TRUE, cex = 2, srt = 90)
    text(family = "mn", x_pos, base_y - strwidth(label) * 0.03 * (par("usr")[4] - par("usr")[3]), substr(label, 2, 2), xpd = TRUE, cex = 2, col = brewer.pal(6, "Dark2")[coln], srt = 90)
    text(family = "mn", x_pos, base_y - strwidth(label) * 0.06 * (par("usr")[4] - par("usr")[3]), substr(label, 1, 1), xpd = TRUE, cex = 2, srt = 90)
  }
}

add_axis_names <- function(graph_type) {
  if (graph_type == "norm") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#Sbst/#AncTrinucs (%)", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "sbst") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#Substitutions", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "ori") {
    mtext(family = "os", "Trinucleotide Patterns", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#Trinucleotides", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "cds") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#SbstInCDS/#AncTrinucsInCDS (%)", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "noncds") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#SbstInNoncds/#AncInNoncds (%)", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "sbstcds") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#SbstInCDS", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "sbstnoncds") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#SbstInNoncds", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "oricds") {
    mtext(family = "os", "Ancestral Trinucleotides", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#AncInCDS", side = 2, line = 0.5, cex = 2.5)
  } else if (graph_type == "orinoncds") {
    mtext(family = "os", "Trinucleotide Patterns", side = 1, line = 5.5, cex = 2.5)
    mtext(family = "os", "#AncInNoncds", side = 2, line = 0.5, cex = 2.5)
  }
}

add_colored_rectangles <- function(bar_positions, pct_yaxs_max, color_array) {
  total_size_per_group <- mean(diff(bar_positions)) * 16
  for (i in 1:6) {
    left <- (i - 1) * total_size_per_group + 0.2
    right <- i * total_size_per_group - 0.2
    label_mid <- total_size_per_group / 2 + (i - 1) * total_size_per_group
    rect(left, pct_yaxs_max + 0.05 * pct_yaxs_max, right, pct_yaxs_max + 0.08 * pct_yaxs_max, col = color_array[i], border = NA)
    text(family = "mn", x = label_mid, y = pct_yaxs_max + 0.12 * pct_yaxs_max, labels = c("C > A", "C > G", "C > T", "T > A", "T > C", "T > G")[i], cex = 2.5)
  }
}

process_norm_graph <- function(data) {
  mutation_percentage <- as.numeric(as.numeric(data["mutNum", ]) / as.numeric(data["totalRootNum", ]) * 100)
  data <- rbind(data, MutationPercentage = mutation_percentage)

  # Transform column names
  transformed_names <- sapply(colnames(data), function(name) {
    char_vector <- strsplit(name, "")[[1]]
    if (length(char_vector) < 7) {
      return(name)
    }
    original_chars <- char_vector[c(1, 3, 7)]
    final_chars <- char_vector[c(1, 5, 7)]
    result <- paste(paste(original_chars, collapse = ""), " → ", paste(final_chars, collapse = ""), sep = "")
    return(result)
  })
  colnames(data) <- transformed_names

  # Sort data
  col_order <- order(as.numeric(data["MutationPercentage", ]), decreasing = TRUE)
  data.sorted <- data[, col_order]
  print("Data sorted by Mutation Percentage:")
  print(data.sorted)
  cat("\n\nTop 10:\n")
  print(data.sorted[, 1:10])
  cat("\n\nWorst 10:\n")
  print(data.sorted[, (ncol(data.sorted) - 9):ncol(data.sorted)])

  # Reverse sort
  col_order_rev <- order(as.numeric(data["MutationPercentage", ]))
  data.revsorted <- data[, col_order_rev]
  cat("\n\nWorst 10 (rev):\n")
  print(data.revsorted[, 1:10])
}


args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
generate_plots(tsv_path)
