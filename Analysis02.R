###########Code generate survival curves for the transplant study################
########load the relevant packages############
rm(list=ls())

#readxl
#install.packages('readxl')
library("readxl")
#tibble
#install.packages("tibble")
library("tibble")
#dplyr
# install.packages('dplyr')
library('dplyr')
#tidyr
#install.packages("tidyr")
library("tidyr")
## tableone package itself
#install.packages("tableone")
library(tableone)
#ggplot - to plot the data
library(ggplot2)
#survminer
# install.packages("survminer")
library(survminer)
#survival
library(survival)
##############################################
##############################################
######Set working directory###################
getwd()
setwd('C:/Users/yxian33/OneDrive - Emory University/Projects_Yijin_Xiang/From_Tracy/transplant/for_plot')
outpat <- "C:/Users/yxian33/OneDrive - Emory University/Projects_Yijin_Xiang/From_Tracy/transplant/Output"
######Load the dataset########################
graft_failure<-as_tibble(read_xlsx('full_dem_grf_0524.xlsx', na = c(""))) # Indicate that  and NA represent missing value
death <- as_tibble(read_xlsx('full_dem_dt_0524.xlsx', na = c("")))


##############################################
#############generate plots for graft failure#
fit1 <- survfit(Surv(fu_time_grf_yrs,graft_failure) ~ complication, data = graft_failure)
summary(graft_failure$fu_time_grf_yrs)
#############generate plots for death#
fit2 <- survfit(Surv(fu_time_dt_yrs, death) ~ complication, data = death)
plot2 <- ggsurvplot(fit2,risk.table = TRUE, xlab = "Time (yrs)",
                    censor = FALSE,
                    legend.title = "",
                    legend.labs = c("No Complications", "PVT/PVS"),
                    linetype = "strata" ,
                    risk.table.y.text.col = FALSE,
                    risk.table.title ="At Risk",
                    tables.theme = theme_cleantable(),
                    tables.height = 0.18,
                    font.x =  16,
                    font.y = 16,
                    font.legend = 12)
# plot1$plot <- plot1$plot + 
#   theme(
#     plot.margin = unit(c(5.5, 10, 5.5, 50), "points"))
plot1$table <- plot1$table +  theme(
  plot.title = element_text(hjust = -0.2))
plot2


plot2 <- ggsurvplot(fit2,risk.table = TRUE, 
                    xlab = "Time from Transplant (years)",
                    ylab = "Patient Survival",
                    censor = FALSE,
                    xlim = c(0,10),
                    break.x.by= 2,
                    legend.title = "",
                    legend.labs = c("No PV Complications", "PVT/PVS"),
                    legend ="right",
                    linetype =  c("solid", "dashed") ,
                    palette = c("black","black"),
                    risk.table.y.text.col = FALSE,
                    risk.table.title ="At Risk",
                    tables.theme = theme_cleantable(),
                    tables.height = 0.2,
                    font.x =  16,
                    font.y = 16,
                    font.tickslab = 16,
                    font.legend = 16,
                    cex.lab=1.2) 
# plot1$plot <- plot1$plot + 
#   theme(
#     plot.margin = unit(c(5.5, 10, 5.5, 50), "points"))
plot2$table <- ggrisktable(fit2,
                           tables.theme = theme_cleantable(),
                           font.tickslab = c(16),
                           fontsize = 5,
                           xlim = c(0,10),
                           break.time.by= 2,
                           risk.table.title = "At Risk",
                           legend.labs =c("No PV Complications", "PVT/PVS"))
plot2
