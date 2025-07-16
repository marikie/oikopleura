library(dplyr)

tsv_path <- "~/biohazard/data/test_test_test/oikAlb_20250407_annot.tsv"
generate_plots <- function(tsv_path) {
  data <- read.csv(tsv_path, sep = "\t", header = TRUE)

  # Add transition column to data
  # Add observed figure of mutNum/totalRootNum
  # Add observed figure of s_ncds/o_ncds
  data <- data %>%
    mutate(trans = substr(mutType, 3, 5)) %>%
    mutate(obs_mut_over_ori = mutNum / totalRootNum) %>%
    mutate(obs_sncd_over_onc = s_ncds / o_ncds)
  # Group by trans
  trans_nullRate <- data %>%
    group_by(trans) %>%
    summarise(nullRate_all = sum(mutNum) / sum(totalRootNum), nullRate_ncds = sum(s_ncds) / sum(o_ncds))
  # Add logRatio of obs_mut_over_ori/nullRate
  data <- data %>%
    mutate(logRatio_all = log2(obs_mut_over_ori / (trans_nullRate %>% filter(trans == trans) %>% pull(nullRate_all)))) %>%
    mutate(logRatio_ncds = log2(obs_sncd_over_onc / (trans_nullRate %>% filter(trans == trans) %>% pull(nullRate_ncds))))
}
