require(stringr)
library(RColorBrewer)

# MODIFIED THE CODE FROM https://github.com/kartong88/Plot-Mutation-Landscape

generate_plot<-function(file_path, filename=0, filename100=0, graphTitle){
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
  #print(data)
  #print(t(data[ , -1]))
  #print(data[ , 1])
  #data_t <- setNames(data.frame(t(data[,-1])), data[,1])
  #print(data_t)
 
  
  conv.data<-setNames(data.frame(t(data[,-1])), data[,1])
  #print(conv.data)
  
  
  # Set missing mutations as value of zero
  #conv.data[conv.combi[!(conv.combi %in% names(conv.data))]] = 0
  
  #print(names(conv.data))
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
  colour_array <- brewer.pal(6, "Dark2")
  #colour_array<-c("red","blue","green","yellow", "purple", "black")
  text_array=c("C>A","C>G","C>T","T>A","T>C","T>G")
  
  # Convert the data to percentage
  ## Calculate the new row and add it
  ## Add Mutation Percentage
  mutation_percentage <- as.numeric(conv.data["mutNum",]/conv.data["totalRootNum",])*100
  conv.data <- rbind(conv.data, MutationPercentage = mutation_percentage)
  #print(conv.data)
  
  conv.data.norm<-as.numeric(conv.data["mutNum",]/conv.data["totalRootNum",]*100)
  pct_yaxs_max <- ceiling(max(na.omit(as.numeric(conv.data.norm[conv.label.all.sorted])))) + 5

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

  ### print Top 10 and Worst 10
  # Print the sorted data frame
  print("Data sorted by Mutation Percentage:")
  print(conv.data.sorted)

  cat("\n\nTop 10:\n")
  print(conv.data.sorted[,1:10])
  cat("\n\nWorst 10:\n")
  print(conv.data.sorted[, (ncol(conv.data.sorted)-9):ncol(conv.data.sorted)])
  # Get the reverse order of indices based on 'MutationPercentage' values
  col_order_rev <- order(as.numeric(conv.data["MutationPercentage", ]))
  # Reorder the columns based on sorted indices
  conv.data.revsorted <- conv.data[, col_order_rev]
  cat("\n\nWorst 10 (rev):\n")
  # Reverse-sort the data frame 'conv.data.sorted' based on the third row
  print(conv.data.revsorted[,1:10])

  
  ### Barplot for Trinucleotide Mutation rate (Percentage)
  # Make the PDF plot of the graph
  if(!filename==0){
    pdf(filename)
    barplot(as.numeric(conv.data.norm[conv.label.all.sorted]), col=rep(colour_array,each=16), cex.names=0.3, las=3, names.arg=trinuc.lab.sorted,ylim=c(0,pct_yaxs_max), ylab="Percentage of #Mutations/#totalRootTrinucs (%)", xlab="Trinucleotides", main = graphTitle)
    
    for(i in 1:6){
      # Size of 1.2 per bar.
      # Total size of 19.2 for 16 barplots
      left<-(i -1)*19.2 + 0.2 # to create a bit of white space
      right<-i* 19.2 - 0.2
      label_mid<-19.2/2 +(i-1)*19.2
      
      #rect(left,5.1,right,5.2, col=colour_array[i], border=NA)
      rect(left,0.95*pct_yaxs_max,right,0.96*pct_yaxs_max, col=colour_array[i], border=NA)
      text(x=label_mid, y=0.98*pct_yaxs_max, labels=text_array[i])
    }
    
    dev.off()
  }
  
  pct_yaxs_max = 100
  ### Barplot for Trinucleotide Mutation rate (Percentage)
  # Make the PDF plot of the graph
  if(!filename100==0){
    pdf(filename100)
    barplot(as.numeric(conv.data.norm[conv.label.all.sorted]), col=rep(colour_array,each=16), cex.names=0.3, las=3, names.arg=trinuc.lab.sorted,ylim=c(0,pct_yaxs_max), ylab="Percentage of #Mutations/#totalRootTrinucs (%)", xlab="Trinucleotides", main = graphTitle)
    
    for(i in 1:6){
      # Size of 1.2 per bar.
      # Total size of 19.2 for 16 barplots
      left<-(i -1)*19.2 + 0.2 # to create a bit of white space
      right<-i* 19.2 - 0.2
      label_mid<-19.2/2 +(i-1)*19.2
      
      #rect(left,5.1,right,5.2, col=colour_array[i], border=NA)
      rect(left,0.95*pct_yaxs_max,right,0.96*pct_yaxs_max, col=colour_array[i], border=NA)
      text(x=label_mid, y=0.98*pct_yaxs_max, labels=text_array[i])
    }
    
    dev.off()
  }
}


args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
graph_path <- args[2] # File path for the output graph, .pdf
orgName <- args[3] # Name of the organism

# Extract the path without an extension from graph_path
path_without_extension <- tools::file_path_sans_ext(graph_path)

generate_plot(tsv_path, filename = graph_path, filename100=paste0(path_without_extension, "_100.pdf"), graphTitle=orgName)