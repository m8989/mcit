# 从地图和从站点定位自动匹配更新站点所在省份信息

# 包含文件-常用包安装和加载
source("R0001常用包安装和加载.R")

# 包含文件-连接到 MySQL 数据库
source("inc_mysql.R")

# 设置工作目录
setwd("D:\\Lzm-Src\\空气数据集\\R")



# 查询站点数据，过滤掉无定位的站点,距杭州市政府200公里的
query <- "SELECT USAF, `STATION NAME`, LAT, LON, `END` IS NOT NULL AND `END` < '2023-01-01' AS isstop
          FROM site
          WHERE LAT IS NOT NULL AND LON IS NOT NULL AND (LAT != 0 OR LON != 0) 
          "
data <- dbGetQuery(con, query)

# 获取中国所有省份级行政区域的地图数据
china_admin1 <- ne_states(country = "China", returnclass = "sf")

# 将地图数据保存为shapefile格式,其它分析有用
st_write(china_admin1, "china_admin1.shp")


# 将data转换为sf对象,会增加一个字段geometry ,4326代表WGS84坐标系
data <- st_as_sf(data, coords = c("LON", "LAT"), crs = 4326)
# 空间连接站点数据和市级地图数据
data <- st_join(data, china_admin1, join = st_within)
### st_join()函数支持的连接方式：
### st_intersects：连接两个对象中相交的部分。
### st_contains：连接一个对象包含另一个对象的部分。
### st_within：连接一个对象被另一个对象包含的部分。
### st_touches：连接两个对象相邻的部分。
### st_covers：连接一个对象覆盖另一个对象的部分。
### st_crosses：连接两个对象交叉的部分。
### st_equals：连接两个对象完全相等的部分。


# 使用str_split()函数将name_local列按照管道符进行分割
data$name_local <- str_split(data$name_local, "\\|")

# 对于没有管道符的值，将其转换为只包含它本身的向量
data$name_local <- sapply(data$name_local, function(x) if (length(x) > 1) x[length(x)] else x)
# 对于NA值，使用name列进行填充
data$name_local[is.na(data$name_local)] <- data$name[is.na(data$name_local)]

# 提取省份名称并更新到数据库中
for (i in seq_along(data$USAF)) {
  province <- data$name[i]
  provinceName <- data$name_local[i]
  usaf <- data$USAF[i]
  query <- paste("UPDATE site SET province = '", province, "', provinceName = '", provinceName, "' WHERE USAF = '", usaf, "'", sep = "")
  dbSendQuery(con, query)
  print(paste("成功更新",usaf,"站点归属信息"))
}
# 注：没有港澳台的,少量站点没能自动找到位置

# 关闭连接
dbDisconnect(con)

