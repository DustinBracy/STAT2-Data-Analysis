

plotNAs <- function(x) {

  # Missing values code borrowed from: https://jenslaufer.com/data/analysis/visualize_missing_values_with_ggplot.html
  
  missing.values <- x %>% gather(key = "key", value = "val") %>%
    mutate(isna = is.na(val)) %>%   group_by(key) %>%
    mutate(total = n()) %>%   group_by(key, total, isna) %>%
    summarise(num.isna = n()) %>%   mutate(pct = num.isna / total * 100)
  
  
  levels <- (missing.values  %>% filter(isna == T) %>% arrange(desc(pct)))$key
  
  percentage.plot <- missing.values %>% ggplot() + geom_bar(aes(x = reorder(key, desc(pct)), y = pct, fill=isna), 
                                                            stat = 'identity', alpha=0.8) + scale_x_discrete(limits = levels) + 
    scale_fill_manual(name = "", values = c('steelblue', 'tomato3'), labels = c("Present", "Missing")) + 
    coord_flip() + labs(title = "Percentage of missing values", x = 'Columns with missing data', y = "Percentage of missing values")
  
  return(percentage.plot)
}

buildCorrPlot <- function(x){
  # Corrplot function from: http://www.sthda.com/english/wiki/visualize-correlation-matrix-using-correlogram
  # Vignette for corrplot is also useful
  
  data.cor <- cor(x)
  
  # mat : is a matrix of data
  # ... : further arguments to pass to the native R cor.test function
  cor.mtest <- function(mat, ...) {
    mat <- as.matrix(mat)
    n <- ncol(mat)
    p.mat<- matrix(NA, n, n)
    diag(p.mat) <- 0
    for (i in 1:(n - 1)) {
      for (j in (i + 1):n) {
        tmp <- cor.test(mat[, i], mat[, j], ...)
        p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
      }
    }
    colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
    p.mat
  }
  # matrix of the p-value of the correlation
  p.mat <- cor.mtest(x)
  
  col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
  
  # Build corrPlot.png ordered by Angular order of Eigenvectors
  png(height=1100, width=1200, pointsize=15, file="./figures/corrPlot.png")
  corrplot(data.cor, 
           method="circle", 
           order="AOE",
           tl.col="black", 
           type="full", 
           tl.cex = 1, 
           p.mat = p.mat, 
           sig.level = 0.01, 
           insig = "blank")
  ggsave("./figures/corrPlot.png", units="in", width=5, height=4, dpi=600)
  dev.off()
}