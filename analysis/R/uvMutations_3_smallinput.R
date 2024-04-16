require(stringr)
library(RColorBrewer)

# MODIFIED THE CODE FROM https://github.com/kartong88/Plot-Mutation-Landscape

generate_plot<-function(file_path, filename=0, graphTitle){
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

  # Sorting columns directly based on 'MutationPercentage' row values
  # Get the order of indices based on 'MutationPercentage' values
  col_order <- order(as.numeric(conv.data["MutationPercentage", ]), decreasing = TRUE)
  # Reorder the columns based on sorted indices
  conv.data.sorted <- conv.data[, col_order]
  # Print the sorted data frame
  print("Data sorted by Mutation Percentage:")
  print(conv.data.sorted)
  
  #top_5 <- sort(conv.data.norm, decreasing = TRUE)[1:5]
  #worst_5 <- sort(conv.data.norm)[1:5]
  #print("top 5:")
  #print(top_5)
  #print("worst 5:")
  #print(worst_5)
  #print(pct_yaxs_max)
  #print(conv.data.norm)
  #print(conv.data.norm[conv.label.all.sorted])
  #print(typeof(conv.data.norm))
  #if(length(conv.data.norm[conv.label.all.sorted]) == 0) {
  #  stop("The height vector for barplot is empty. Check the processing of conv.data.norm and conv.label.all.sorted.")
  #}
  
  #simple_test <- conv.data.norm[1:10] # Just an example to test plotting
  #print(simple_test)
  #print(is.vector(simple_test))
  #print(is.matrix(simple_test))
  
  # Convert to a numeric vector explicitly
  #simple_test_vector <- as.numeric(simple_test)
  
  # Now, try plotting again
  #barplot(simple_test_vector, col=rep(colour_array, each=1, length.out=length(simple_test_vector)))
  
  
  
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
}


args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
file_path <- args[1]
dir_path <- args[2]
#print(file_path)
#print(dir_path)
#data <- read.csv(file_path, sep="\t", header=TRUE)
dirname <- basename(dir_path)
#print(dirname)
spc <- str_split(dirname, "_", simplify = TRUE)
#print(spc)
title <- paste0(spc[1,1], "-", spc[1,2], ", ", spc[1,1], "-", spc[1,3])
#print(title)
generate_plot(file_path, filename = paste0(dir_path, "/", dirname, ".pdf"), graphTitle=title)