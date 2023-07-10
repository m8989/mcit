library(RMySQL)

# 连接到 MySQL 数据库
con <- dbConnect(MySQL(), 
                 user = "root", 
                 password = "Hiaming791127", 
                 dbname = "airdata", 
                 host = "127.0.0.1")

# 执行查询函数
mysql_query <- function( query) {
  data <- tryCatch({
    dbGetQuery(con, query)
  }, error = function(e) {
    message(paste("Error executing query:", e$message))
    NULL
  })
  return(data)
}



#在别的文件中  source("helper_functions.R")  省得到处改