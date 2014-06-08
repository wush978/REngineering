---
title       : R語言的工程面
subtitle    : 
author      : Wush Wu
job         : Taiwan R User Group
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : zenburn      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
--- &vcenter .large

R 是最火熱的分析工具之一

--- &vcenter .large

有時候

我們需要分析不停變動的資料

--- &vcenter .large

需要有資料工程

才能不停的取得分析用的資料

--- &vcenter .large

今天以親身經驗跟大家介紹

我所建立的數個以R 為核心的系統

--- &vcenter .large

Outline

1. 定時進行資料的ETL以及和雲端資料庫的同步
2. 定時的機器學習系統建立服務所需的模型
3. 自動在雲端布署學習系統來進行電腦實驗及數據分析以改進機器學習的效能
4. 利用客製化的Dashboard來監控系統成效
5. 利用jenkins達成R 套件的自動測試和布署
6. 利用講者自行開發的CRAN套件進行系統狀態的通知

--- &vcenter .segue .dark

## <div>定時進行資料的ETL以及</br></br>和雲端資料庫的同步</div>

--- &vcenter .large

ETL

<img src="assets/img/ETL.png" class="fit100"/>

--- &vcenter .large

讀取檔案的具體步驟

請期待R Tutorial系列課程

--- &vcenter .large

給一個檔案: 

`impression201406012300.txt`

製作一個R script讀取該檔案:

```r
in_path <- "impression2014060123.txt"
# ...
saveRDS(out, "out.Rdata")
```

--- &vcenter .large

需要定時啟動器

需要依據時間做不同的變化

--- &vcenter .large

定時啟動系統:

### crontab，工作排程 <img src="assets/img/scheduler.jpeg" class="fit50"/>
### jenkins <img src="assets/img/jenkins.png" class="fit50"/>

--- &vcenter .large

利用時間建立不同的行為

```r
saveRDS(out, 
  sprintf(
    "out%s.Rdata", 
    format(Sys.time(), "%Y%m%d%H")
  ))
```

--- &vcenter .large

事情不會永遠美好...

我們需要寫記錄(Log)

我們需要處理錯誤

--- &vcenter .large

`logging` 

一個R 中寫log的套件

```r
library(logging)
basicConfig("DEBUG")
logdebug("DEBUG")
loginfo("INFO")
logwarn("WARN")
logerror("ERROR")
```

--- &vcenter .large

除錯後，需要追回耽誤的工作

需要一個檢查工作是否完成的機制

```r
current <- Sys.time()
for(i in 0:23) {
  target_time <- current - 3600 * i
  check_result <- file.exists(sprintf(
    "out%s.Rdata", 
    format(Sys.time(), "%Y%m%d%H")
  ))
  # ...
}
```

--- &vcenter .large

