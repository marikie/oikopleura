require(stringr)
library(RColorBrewer)

# MODIFIED THE CODE FROM https://github.com/kartong88/Plot-Mutation-Landscape

generate_plot<-function(file_path, filename=0, ymax_plus){
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
  
  conv.data<-setNames(data.frame(t(data[,-1])), data[,1])
  
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
  colour_array <- brewer.pal(6, "Set2")
  #colour_array<-c("red","blue","green","yellow", "purple", "black")
  text_array=c("C > A","C > G","C > T","T > A","T > C","T > G")
  
  # Convert the data to percentage
  ## Calculate the new row and add it
  ## Add Mutation Percentage
  mutation_percentage <- as.numeric(conv.data["mutNum",]/conv.data["totalRootNum",])*100
  conv.data <- rbind(conv.data, MutationPercentage = mutation_percentage)
  
  conv.data.norm<-as.numeric(conv.data["mutNum",]/conv.data["totalRootNum",]*100)
  pct_yaxs_max <- ceiling(max(na.omit(as.numeric(conv.data.norm[conv.label.all.sorted]))))+ymax_plus
  
  # Transform each column name according to the specified pattern
  transformed_names <- sapply(colnames(conv.data), function(name) {
    # Split the name into a character vector
    char_vector <- strsplit(name, "")[[1]]
    # Check if the length of char_vector is less than 7
    if (length(char_vector) < 7) {
      return(name)  # Return original name if it's too short
    }
    # Extract characters based on the specified positions
    original_chars <- char_vector[c(1, 3, 7)]
    final_chars <- char_vector[c(1, 5, 7)]
    # Combine into the new format
    result <- paste(paste(original_chars, collapse = ""), " → ", paste(final_chars, collapse = ""), sep = "")
    return(result)
  })
  # Update the column names of the data frame
  colnames(conv.data) <- transformed_names
  
  # Sorting columns directly based on 'MutationPercentage' row values
  # Get the order of indices based on 'MutationPercentage' values
  col_order <- order(as.numeric(conv.data["MutationPercentage", ]), decreasing = TRUE)
  # Reorder the columns based on sorted indices
  conv.data.sorted <- conv.data[, col_order]

  
  ### Barplot for Trinucleotide Mutation rate (Percentage)
  # Make the PDF plot of the graph
  if(!filename==0){
    pdf(filename, width=30, height=8)
    # default: c(5, 4, 4, 2) + 0.1
    par(family="mono", mar=c(7.5, 6, 2, 1), cex.axis=2) # Increase the size of y-axis numbers # Increase the bottom, left, top, and right margins
    bar_positions <- barplot(as.numeric(conv.data.norm[conv.label.all.sorted]),
                      col=rep(colour_array,each=16), 
                      cex.names=0.7, # default size (manually write over later)
                      las=3,
                      names.arg=rep("", length(trinuc.lab.sorted)), # empty labels for now
                      #names.arg=trinuc.lab.sorted,
                      ylim=c(0,pct_yaxs_max),
                      space = 0.1) # Increase space between bars
    
    
    # manually add labels
    text(x=bar_positions, y=par("usr")[3] - 0.05 * (par("usr")[4] - par("usr")[3]), 
         labels=trinuc.lab.sorted, srt=90, adj=1, xpd=TRUE, cex=2) # modify size by cex, rotate by srt
    
    # add xlab and ylab
    mtext("Original Trinucleotides", side=1, line=6, cex=2.5) # modify size by cex
    mtext("#Subs/#OrigTrinucs (%)", side=2, line=4, cex=2.5) # cexでサイズ調整
    
    # Calculate the width of the bars
    bar_widths <- diff(bar_positions)
    bar_width <- mean(bar_widths)
    # Print the bar width for debugging
    print(paste("Bar width: ", bar_width))
    
    total_size_per_group = bar_width * 16
    
    for(i in 1:6){
      # Size of 1.2 per bar.
      # Total size of 19.2 for 16 barplots
      left<-(i -1)*total_size_per_group + 0.2 # to create a bit of white space
      right<-i* total_size_per_group - 0.2
      label_mid<-total_size_per_group/2 +(i-1)*total_size_per_group
      
      #rect(left,5.1,right,5.2, col=colour_array[i], border=NA)
      rect(left,0.90*pct_yaxs_max,right,0.93*pct_yaxs_max, col=colour_array[i], border=NA)
      text(x=label_mid, y=0.97*pct_yaxs_max, labels=text_array[i], cex=2.5) # increase label size with cex
    }
    
    dev.off()
  }
  
}


args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
graph_path <- args[2] # File path for the output graph, .pdf
ymax_plus <- args[3]
#orgName <- args[3] # Name of the organism
print("ymax_plus:")
print(ymax_plus)
# Extract the path without an extension from graph_path
# path_without_extension <- tools::file_path_sans_ext(graph_path)

generate_plot(tsv_path, filename = graph_path, as.numeric(ymax_plus))