#제무제표 다운로드
#copy in 2020-03-06
# curl을 인스톨 해야 하나..install.packages(c("curl", "httr"))
#오늘도  안되네...

library(httr)
library(rvest)
library(curl)

ifelse(dir.exists('data/KOR_fs'), FALSE,
       dir.create('data/KOR_fs'))

Sys.setlocale("LC_ALL", "English")

url = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930')

data = GET(url)
content(data)

data = data %>%
  read_html() %>%
  html_table()

Sys.setlocale("LC_ALL", "Korean")
