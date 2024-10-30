get_bar_ratios <-function(file_path){
    data <- data.frame(read.csv(file_path, sep="\t", header=TRUE))
    sbst_ratio <- as.numeric(data$mutNum/data$totalRootNum)
    data <- cbind(data, sbstRatio=as.numeric(data$mutNum/data$totalRootNum))
    data <- cbind(data, barRatio=as.numeric(data$sbstRatio/sum(data$sbstRatio)))
    # print(data)

    # Calculate the sum of barRatios for C>T substitutions
    ct_sum <- sum(data$barRatio[grepl("C>T", data$mutType)])
    print(paste("Sum of barRatios for C>T substitutions:", ct_sum))
    # Calculate the sum of barRatios for T>C substitutions
    tc_sum <- sum(data$barRatio[grepl("T>C", data$mutType)])
    print(paste("Sum of barRatios for T>C substitutions:", tc_sum))
    # Calculate the sum of barRatios for CG>TG substitutions
    cgtg_sum <- sum(data$barRatio[grepl("C>T]G", data$mutType)])
    print(paste("Sum of barRatios for CG>TG substitutions:", cgtg_sum))
}

args <- commandArgs(trailingOnly = TRUE)

# Access the arguments
tsv_path <- args[1] # File path for the input data, .tsv file
get_bar_ratios(tsv_path)