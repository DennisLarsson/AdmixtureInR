library(parallel)

setwd("/path/to/workDirectory")  #give the path to the work directory where you files are and/or where you would like to output files to go
pedfile="inputfile.ped"          #give the name of the file if it is in the work directory or the full path if it is somewhere else
outputFolder="outputfolder"      #give the name of the output folder
popmap="/path/to/popmap"         #give the name of the popmap if it is in the work directory or the full path if it is somewhere else
maxK=10

NrCores=NULL # NULL can be replaced with a number of cores if you don't want to use all.

pop <- read.delim(popmap, header = FALSE)
pop_sorted<-pop[order(pop[,2]),]

filename = strsplit(pedfile,split = ".", fixed = TRUE)
filename = filename[[1]][1]

if (dir.exists(outputFolder) == FALSE) {
  dir.create(outputFolder)
}
currentWD<-getwd()
setwd(paste(currentWD,"/",outputFolder,sep=""))

if (is.null(NrCores)) {NrCores=detectCores()} #detects how many cores are available

for (K in 1:maxK) {
  if (K < 10) {
    Kstring=paste("0",K,sep="")
  }
  else {
    Kstring=K
  }
  #print(paste("admixture --cv -j",NrCores," ../",pedfile," ",K," | tee log",Kstring,".out",sep=""))
  system(paste("admixture --cv -j",NrCores," ../",pedfile," ",K," | tee log",Kstring,".out",sep=""))
}

logfile=paste(outputFolder,".log",sep="")
#print(paste("grep -h CV log*.out > ../",logfile,sep=""))
system(paste("grep -h CV log*.out > ../",logfile,sep=""))

CV<-read.table(file=paste("../",logfile,sep=""))

pdf(file=paste(filename,"_admixture.pdf",sep=""), height = 5, width = 8, title = filename)
plot(CV$V4,main = "Cross validation error estimates",type = "b", ylab = "Cross validation score", xlab = "K-value")
for (K in 2:maxK) {
  qmatrix<-read.table(paste(filename,".",K,".","Q",sep=""))
  
  colorsPlot = c("red", "blue", "orange", "green","purple", "brown","darkgrey", "yellow", "darkgreen", "cyan")
  barplot(t(qmatrix), border = NA, space = 0, ylab = "Ancestry coefficients", col = colorsPlot, main = paste("Ancestry coefficients for K=",K,sep = ""))
  
  #plot lines and names of populations into the plot
  axis(1, tapply(1:nrow(pop), pop[,2],mean),unique(pop_sorted[,2]),las=2, cex.axis=0.7, tick = F, line = -0.8)
  abline(v=tapply(1:nrow(pop), pop[,2],max), lty=2, lwd=0.5)
  
  #write the qmatrix to a csv file that can be used in other applications.
  write.csv(qmatrix,paste(outputFolder,"_K",K,"_admixture.csv",sep=""), row.names = pop$V1)
}
dev.off()

