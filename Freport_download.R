
#report_down()함수를 통해 정기 공시를 엑셀로 다운로드함


    mydir <- getwd()
    setwd(mydir)
    
    if (nrow(search_result) == 1) {
      
      print(search_result)
      
      #data download
      data <- fromJSON(url)
      data.df <- data$list
      data.df.rcp <- data.df$rcp_no #보고서번호
      
      #Excel download
      for (i in 1:10) {
        
        url.business.report = paste0('http://dart.fss.or.kr/dsaf001/main.do?rcpNo=',data.df.rcp[i])
        req <- GET(url.business.report)
        req <- read_html(req) %>% html_node(xpath = '//*[@id="north"]/div[2]/ul/li[1]/a')
        
        req = req %>% html_attr('onclick')
        dcm = stringr::str_split(req, ' ')[[1]][2] %>% readr::parse_number()
        
        
        query.base = list(
          rcp_no = data.df.rcp[i],
          dcm_no = dcm,
          lang = "ko" #이게 없으면 영문으로 다운로드 됨 (내 경우에만 그럴수도)
        )
        
        down.excel = POST('http://dart.fss.or.kr/pdf/download/excel.do',
                          query = query.base)
        
        
        writeBin(content(down.excel, "raw"), 
                 paste0(ticker, "_", data.df.rcp[i], '.xls'))  
      }
      
    } else if (nrow(search_result) == 0) {
      
      print("invalid company name")
      
    } else {
      
      if (force == F) {
        print("multiple result: force = T to force downloading")
        print(search_result)
      } else {
        print("multiple result: downloaded forcefully the first company")
        print(search_result)
        
        #data download
        data <- fromJSON(url)
        data.df <- data$list
        data.df.rcp <- data.df$rcp_no #보고서번호
        
        #Excel download
        for (i in 1:10) {
          
          url.business.report = paste0('http://dart.fss.or.kr/dsaf001/main.do?rcpNo=',data.df.rcp[i])
          req <- GET(url.business.report)
          req <- read_html(req) %>% html_node(xpath = '//*[@id="north"]/div[2]/ul/li[1]/a')
          
          req = req %>% html_attr('onclick')
          dcm = stringr::str_split(req, ' ')[[1]][2] %>% readr::parse_number()
          
          
          query.base = list(
            rcp_no = data.df.rcp[i],
            dcm_no = dcm,
            lang = "ko" #이게 없으면 영문으로 다운로드 됨 (내 경우에만 그럴수도)
          )
          
          down.excel = POST('http://dart.fss.or.kr/pdf/download/excel.do',
                            query = query.base)
          
          writeBin(content(down.excel, "raw"), 4
                   paste0(ticker, "_", data.df.rcp[i], '.xls'))  
        }
        
      }
      
    }
  }
