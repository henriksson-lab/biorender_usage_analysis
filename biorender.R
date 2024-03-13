library(stringr)
library(ggpl)


list_biorender <- read.table("/husky/otherdataset/pubmed_fulltext/new/out_all.txt")$V1


papermeta <- list()
rootdir <- "/husky/otherdataset/pubmed_fulltext/new/text"
for(f in list.files(rootdir,pattern = "*.filelist.csv")){
  papermeta[[f]] <- read.csv(file.path(rootdir, f))
}
papermeta <- do.call(rbind, papermeta)

papermeta$got_biorender <- papermeta$Article.File %in% list_biorender

sum(papermeta$got_biorender)
table(papermeta$got_biorender, papermeta$License)


###### Assignment of year, approximate
papermeta$year <- NA
papermeta$year[str_detect(papermeta$Article.Citation, "2014")] <- 2014
papermeta$year[str_detect(papermeta$Article.Citation, "2015")] <- 2015
papermeta$year[str_detect(papermeta$Article.Citation, "2016")] <- 2016
papermeta$year[str_detect(papermeta$Article.Citation, "2017")] <- 2017
papermeta$year[str_detect(papermeta$Article.Citation, "2018")] <- 2018
papermeta$year[str_detect(papermeta$Article.Citation, "2019")] <- 2019
papermeta$year[str_detect(papermeta$Article.Citation, "2020")] <- 2020
papermeta$year[str_detect(papermeta$Article.Citation, "2021")] <- 2021
papermeta$year[str_detect(papermeta$Article.Citation, "2022")] <- 2022
papermeta$year[str_detect(papermeta$Article.Citation, "2023")] <- 2023
papermeta$year[str_detect(papermeta$Article.Citation, "2024")] <- 2024

gotit <- papermeta[papermeta$got_biorender,]
tab <- sqldf::sqldf("select License, year, count(*) as cnt from gotit group by License, year")
tab <- tab[!is.na(tab$year) & tab$year>=2018 & tab$year<=2023,]
tab_tot <- sqldf::sqldf("select year, count(*) as tot_cnt from papermeta group by year")
tab_tot <- merge(tab, tab_tot)
tab_tot$frac <- tab_tot$cnt/tab_tot$tot_cnt


p1 <- ggplot(tab, aes(year, cnt, fill=License)) + geom_bar(stat="identity") + ylab("Numer of papers") + 
    theme(legend.background=element_blank()) + theme_set(theme_bw() + theme(legend.key=element_blank())) +
    scale_x_continuous(breaks=c(2018,2019,2020,2021,2022,2023))
p2 <- ggplot(tab_tot, aes(year, frac*100, fill=License)) + geom_bar(stat="identity") + ylab("% of papers") + 
  theme(legend.background=element_blank()) + theme_set(theme_bw() + theme(legend.key=element_blank())) +
  scale_x_continuous(breaks=c(2018,2019,2020,2021,2022,2023))
ptot <- p1 | p2
ptot
ggsave("/home/mahogny/biorender.svg", plot=ptot, width = 12, height = 4)

##################

#how many in total
sum(gotit$License!="CC BY-NC-ND" & gotit$License!="CC0")

sum(gotit$License!="CC BY-NC-ND" & gotit$License!="CC0" & !is.na(gotit$year) & gotit$year==2023)


