library(shiny)
library(plotly)

muni_data <- read_csv("piemunicipal.csv")

code <- "01107"
data <- muni_data %>% 
  filter(CODIGO==code) %>% 
  gather(VARIABLE,TOTAL,CASINO:MINERAS)

comuna <- unique(data$MUNICIPIO)

plot_ly(data, x = ~VARIABLE,y = ~TOTAL,type = 'bar') %>% 
  layout(title =comuna,xaxis = list(title = "", tickangle = -45),
         yaxis = list(title = ""),
         margin = list(b = 100))