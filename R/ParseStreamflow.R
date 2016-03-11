# These functions read and parse the realtime streamflow sites
require(xts)
require(lubridate)
require(TSA)

getStreamflow <- function(siteId,startDate,endDate){
  
  file_url <- paste("http://waterdata.usgs.gov/sc/nwis/uv?format=rdb&site_no=",siteId,"&period=&begin_date=",startDate,"&end_date=",endDate,sep='')
  print(file_url)
  #eventually, this will scan the header to determine the column names...
  #streamflow_data <- scan(file=file_url,what=character(),nlines=50,sep='\n')
  sc <- read.table(file_url,sep='\t',header = T,stringsAsFactors = F)
  
  #TODO: Abstraction of this process...
  colnames(sc)[grep('00065_cd',colnames(sc))] <- "Gage_cd"
  colnames(sc)[grep('00065',colnames(sc))] <- "Gage"
  colnames(sc)[grep('00060_cd',colnames(sc))] <- "Discharge_cd"
  colnames(sc)[grep('00060',colnames(sc))] <- "Discharge"
  colnames(sc)[grep('00045_cd',colnames(sc))] <- "Precip_cd"
  colnames(sc)[grep('00045',colnames(sc))] <- "Precipitation"
  colnames(sc)[grep('00300_cd',colnames(sc))] <- "DissO2_cd"
  colnames(sc)[grep('00300',colnames(sc))] <- "DissolvedOxygen"
  colnames(sc)[grep('00010_cd',colnames(sc))] <- "Temperature_cd"
  colnames(sc)[grep('00010',colnames(sc))] <- "Temperature"
  
  sc[-1,]
}

prepareTwoWayTXFunction <- function(upstream.df,dnstream.df,target){
  upstreamMinutes = table(strftime(upstream.df$datetime,"%M"))
  dnstreamMinutes = table(strftime(dnstream.df$datetime,"%M"))
  #TODO: compare these two with error catching block
  print(upstreamMinutes)
  print(dnstreamMinutes)
  #TODO: automatic column selection
  keep <- c('datetime','site_noUP','site_noDN',paste(target,'UP',sep=''),paste(target,'DN',sep=''))
  res <- merge(upstream.df,dnstream.df,by="datetime",suffixes=c('UP','DN'))
  res <- res[,names(res) %in% keep]

}

#Get two discharge series for analyis. I already know that these two sensors are in line, several miles apart
# and are consistent at 15 minute intervals.  All of this has to be taken into consideration, and a
# TODO: check the series to make sure that they have the same sampling periodicity.

up <- getStreamflow("02168504",'2016-02-01','2016-03-07')
dn <- getStreamflow("02169000",'2016-02-01','2016-03-07')
r1 <- prepareTwoWayTXFunction(up,dn,"Discharge")

#plot the crosscorrelation function 
ccf <- ccf(x=as.numeric(r1$DischargeDN), y=as.numeric(r1$DischargeUP),  type = "correlation",plot = TRUE)
maxind <- which(ccf$acf == max(ccf$acf))
# you can use the ccf$lag[maxind] if you need the max lag number for something else
lx <- matrix(nrow = 2, ncol=2 ,c(ccf$lag[maxind],ccf$lag[maxind],0,ccf$acf[maxind]))
lines(lx,col='red',lwd=2)

dischargeUp <- diff(as.numeric(r1$DischargeUP) - mean(as.numeric(r1$DischargeUP),na.rm=T))
dischargeDn <- diff(as.numeric(r1$DischargeDN))

# Fit a transfer function model - THIS IS PLACEHOLDER CODE - NO MODELING HAS BEEN DONE YET!!!!!!
# m <- arimax(dischargeDn,order=c(1,0,1),include.mean = T,xtransf = dischargeUp,  transfer = list(c(0,1)),method='ML')

# Plot the xts series. I am not happy with this yet
r1.tsDN <- with(r1,xts(as.numeric(DischargeDN),order.by=as.POSIXct(datetime,"UTC")))
r1.tsUP <- with(r1,xts(as.numeric(DischargeUP),order.by=as.POSIXct(datetime,"UTC")))

plot(r1.tsDN,axes = T)
lines(r1.tsUP,col='red')

