
#report_down()함수를 통해 정기 공시를 엑셀로 다운로드함

report_down <-
  function(name, type = 1, force = F) {
    search_result <- ticker_list[grepl(name, ticker_list$종목명, fixed = T), 1:2]
    
    #api.key <- '직접 스스로 받은 API키를 치세요'
    api.key <- 'c64c3daa9ef85f81a7993bf1026dc9a262686261'
    start.date <- '19990101'
    ticker <- search_result[1, 1]
    url <- paste0("http://dart.fss.or.kr/api/search.json?auth=",
                  api.key,"&crp_cd=",ticker,"&start_dt=",start.date,
                  "&bsn_tp=A00", type)
    
    # auth  발급받은 인증키(40자리)(필수)
    # crp_cd    공시대상회사의 종목코드(상장사:숫자 6자리) 또는 고유번호(기타법인:숫자 8자리)
    # start_dt  검색시작 접수일자(YYYYMMDD) : 없으면 end_dt
    # bsn_tp    #A001: 정기 #A002: 반기 #A003: 분기
    
    #setwd("자신이 파일을 다운받을 경로를 치세요")
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
