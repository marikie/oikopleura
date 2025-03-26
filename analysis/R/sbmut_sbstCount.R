# This script is to plot the substitution signatures without normalization.

require(stringr)
library(RColorBrewer)
library(showtext)

generate_plot<-function(file_path, filename=0){
  ## Perform analysis for the trinucleotide variants
  
  ### Check which of the mutation variant is missing and add that to the named vector
  Letters<-c("A", "T", "C", "G")
  conversion<-c("C>A", "C>G", "C>T", "T>A", "T>C", "T>G")
  trinuc.combi<-c()
  
  # Get all combinations of the conversions
  conv.combi<-c()
  for(i in 1:length(Letters)){
    for(j in 1:length(conversion)){
      for(k in 1:length(Letters)){
        combination<-paste(Letters[i], "[" , conversion[j], "]" , Letters[k], sep="")
        conv.combi<-c(conv.combi, combination)
      }
    }
  }
  
  data <- read.csv(file_path, sep="\t", header=TRUE)
  # Debug: Print the first few rows of the data
  # print(head(data))

  conv.data<-setNames(data.frame(t(data[,-1])), data[,1])

  # Debug: Print the structure of conv.data
  # print(str(conv.data))
  # print(head(conv.data))
  # print(rownames(conv.data))
  # Check if "mutNum" is a valid row name
  if (!"mutNum" %in% rownames(conv.data)) {
    stop("Error: 'mutNum' is not a valid row name in conv.data")
  }

  # Set missing mutations as value of zero
  conv.data[conv.combi[!(conv.combi %in% names(conv.data))]] = 0
  
  data.conv<-names(conv.data)
  
  conv.label<-str_extract(data.conv, ".>.")
  firstchar<-str_extract(data.conv, "^.")
  lastchar<-str_extract(data.conv, ".$")
  conv.label.all<-paste(conv.label, "_", firstchar, lastchar, sep="")
  conv.label.all.sorted<-order(conv.label.all)
  
  # Generate the trinucleotide label
  midrefchar<-str_extract(str_extract(data.conv, "(.)>"), "^.")
  trinuc.lab<-paste(firstchar, midrefchar, lastchar, sep="")
  trinuc.lab.sorted<-trinuc.lab[conv.label.all.sorted]
  
  # Labels information for subsequent barplot
  # colour_array <- brewer.pal(6, "Set2")
  colour_array <- brewer.pal(6, "Dark2")
  #colour_array<-c("red","blue","green","yellow", "purple", "black")
  text_array=c("C > A","C > G","C > T","T > A","T > C","T > G")
  
  # Extract the "mutNum" row
  conv.data<-as.numeric(conv.data["mutNum",])
  pct_yaxs_max <- ceiling(max(na.omit(as.numeric(conv.data[conv.label.all.sorted]))))
  

  ### Barplot for Trinucleotide substitution counts
  # Make the PDF plot of the graph
  if(!filename==0){
    pdf(filename, width=30, height=8)
    # default: c(5, 4, 4, 2) + 0.1
    # font_add_google("IBM Plex Mono", "mn", 500)
    font_add_google("Courier Prime", "mn", 700)
    font_add_google("Roboto", "os")
    showtext_auto()
    par(family="mn", mar=c(7.5, 6, 4, 1), cex.axis=2) # Increase the size of y-axis numbers # Increase the bottom, left, top, and right margins
    bar_positions <- barplot(
                      axes = FALSE,
                      family="os",
                      # main = orgName, # graph title
                      as.numeric(conv.data[conv.label.all.sorted]),
                      col=rep(colour_array,each=16), 
                      cex.names=0.7, # default size (manually write over later)
                      las=3,
                      names.arg=rep("", length(trinuc.lab.sorted)), # empty labels for now
                      #names.arg=trinuc.lab.sorted,
                      ylim=c(0,pct_yaxs_max+0.15*pct_yaxs_max),
                      space = 0) # Increase space between bars

    # manually add y axis
    axis(side=2, line=-3.5)

    # manually add labels
    #text(x=bar_positions, y=par("usr")[3] - 0.05 * (par("usr")[4] - par("usr")[3]), 
    #     labels=trinuc.lab.sorted, srt=90, adj=1, xpd=TRUE, cex=2) # modify size by cex, rotate by srt
    for (i in seq_along(trinuc.lab.sorted)) {
      label <- trinuc.lab.sorted[i]
      x_pos <- bar_positions[i]
      base_y <- par("usr")[3] - 0.03 * (par("usr")[4] - par("usr")[3])
      if(i%%16!=0){
        coln <- i %/% 16 + 1
      }else{
        coln <- i %/% 16
      }
      
      # print("strwidth:")
      # print(strwidth(label))
      # print("strheight:")
      # print(strheight(label))
      # print(label)

      # Last letter (slightly under the x axis)
      text(family="mn", x_pos, base_y, substr(label, 3, 3),
           xpd=TRUE, cex=2, srt=90)
      
      # Middle letter (colored red, slightly above the first letter)
      text(family="mn", x_pos, base_y - strwidth(label)*0.03*(par("usr")[4]-par("usr")[3]), substr(label, 2, 2),
          xpd=TRUE, cex=2, col=colour_array[coln], srt=90)
      
      # First letter (at the bottom)
      text(family="mn", x_pos, base_y - strwidth(label)*0.06*(par("usr")[4]-par("usr")[3]), substr(label, 1, 1),
          xpd=TRUE, cex=2, srt=90)
    }

    # add xlab and ylab
    mtext(family="os", "Original Trinucleotides", side=1, line=5.5, cex=2.5) # modify size by cex
    mtext(family="os", "Count of substitutions", side=2, line=0.5, cex=2.5) # cexでサイズ調整
    
    # Calculate the width of the bars
    bar_widths <- diff(bar_positions)
    bar_width <- mean(bar_widths)
    # Print the bar width for debugging
    #print(paste("Bar width: ", bar_width))
    
    total_size_per_group = bar_width * 16
    
    for(i in 1:6){
      # Size of 1.2 per bar.
      # Total size of 19.2 for 16 barplots
      left<-(i -1)*total_size_per_group + 0.2 # to create a bit of white space
      right<-i* total_size_per_group - 0.2
      label_mid<-total_size_per_group/2 +(i-1)*total_size_per_group
      
      #rect(left,5.1,right,5.2, col=colour_array[i], border=NA)
      rect(left,pct_yaxs_max + 0.05*pct_yaxs_max,right,pct_yaxs_max + 0.08*pct_yaxs_max, col=colour_array[i], border=NA)
      text(family="mn", x=label_mid, y=pct_yaxs_max + 0.12*pct_yaxs_max, labels=text_array[i], cex=2.5) # increase label size with cex
    }
    
    dev.off()
  }
  
}


args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
# Extract the path without an extension from tsv_path
path_without_extension <- tools::file_path_sans_ext(tsv_path)
graph_path <- paste(path_without_extension, "_sbstCount.pdf", sep="")

# generate_plot(tsv_path, filename = graph_path, as.numeric(ymax_plus), orgName)
generate_plot(tsv_path, filename = graph_path)
