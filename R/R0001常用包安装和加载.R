# 安装项目用到的包。
# 因为不该每次都加载，所以放在if里面，必要时手动进入执行
if(FALSE){

  install.packages("Rtools")
  install.packages("RMySQL")
  install.packages("DBI")
  
  install.packages("openxlsx")
  
  install.packages("rnaturalearth")
  install.packages("rnaturalearthdata")
  install.packages("rnaturalearthhires")
  #devtools::install_github("ropensci/rnaturalearthhires")
  #本地安装，在线总下不了
  install.packages("./ropensci-rnaturalearthhires-c3785a8.tar.gz", repos = NULL, type = "source")
  install.packages("mapdata")
  
  install.packages("ggplot2")
  install.packages("ggspatial")
  install.packages("ggrepel")
  install.packages("dplyr")
  
  install.packages("sf")
  install.packages("stringr")

  install.packages("aTSA")
  install.packages("forecast")
  install.packages("zoo")

}

# 加载  包
library(RMySQL)   # RMySQL包提供了访问MySQL数据库的函数和方法
library(DBI)      # DBI是R中的一个通用数据库接口，提供了一致的方法来连接不同的数据库系统
library(openxlsx) # openxlsx包提供了一些函数和方法来读写Excel文件

# 使用rnaturalearth包绘制中国地图
library(rnaturalearth)        # rnaturalearth包提供了自然地球数据的下载和处理功能
library(rnaturalearthdata)    # rnaturalearthdata包提供了与自然地球数据相关的数据集
library(rnaturalearthhires)   # rnaturalearthhires包提供了高分辨率的自然地球数据
library(mapdata)              # mapdata包提供了一些地图数据集和函数

library(ggplot2)    # ggplot2包提供了一种基于图层的绘图语法，可以用来绘制各种类型的统计图表
library(ggspatial)  # ggspatial包是基于ggplot2的一个扩展包，提供了绘制空间数据的功能
library(ggrepel)    # ggrepel包提供了绘制避免重叠标签的功能

library(sf)       # sf包提供了一种基于Simple Features标准的空间数据处理方法
library(dplyr)    # dplyr包提供了一些数据处理函数，如过滤、排序、筛选等
library(stringr)  # stringr包提供了一些字符串处理函数，如正则表达式

library(aTSA)     # aTSA包提供了一些时间序列分析的函数和方法
library(forecast) # forecast包提供了一些时间序列预测的函数和方法
library(zoo)      # zoo包提供了一些处理和分析时间序列数据的函数和方法


