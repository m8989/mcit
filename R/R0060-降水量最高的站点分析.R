# 降水量分析

# 包含文件-常用包安装和加载
source("R0001常用包安装和加载.R")

# 包含文件-连接到 MySQL 数据库
source("inc_mysql.R")




# 设置工作目录
setwd("D:\\Lzm-Src\\空气数据集\\R")

# 设置数字显示格式,不用科学计数法
options(scipen = 999)

# 设置变量
year <- 2011  #开始年份
# month <- 5
# day <- 1



# 查询每个站点每年中日降水量最高的记录
query <- ""
for (i in 2011:2023) {
  query <- paste0( query, sprintf("
  UNION 
SELECT %s AS year,y2.usaf,site.`STATION NAME`, LAT, LON, max(val) AS val
FROM (
	SELECT y.usaf,sum(precipitation_6h/2) AS val
	FROM airdata_%s AS y 
	WHERE precipitation_6h >0
	GROUP BY y.year, y.month, y.day,y.usaf
) y2 INNER JOIN	site	ON 		y2.usaf = site.USAF
GROUP BY usaf, LAT, LON,site.`STATION NAME`
                   ", i,i),collapse = "")
}  
# 去掉前 10 个字符
query <- substr(query, 11, nchar(query))
print(query);

data <- dbGetQuery(con, query)



# 将选择的数据保存到新的xlsx文件,方便美化加工
write.xlsx(data, "保存-全国日降水量最高的记录.xlsx", rowNames = FALSE)




# 查看数据的格式和前几行
str(data)
head(data)


# ========================数据分析===================================
# (在数据入库时和查询条件中已经清理过了)

# 按照val值的降序排序，并取出前30行记录
top30 <- data %>% arrange(desc(val)) %>% head(30)

# 将选择的数据保存到新的xlsx文件,方便美化加工
write.xlsx(top30, "保存-全国日降水高峰点Top30分布.xlsx", rowNames = FALSE)

# 获取中国地图数据
china <- ne_countries(country = "china", returnclass = "sf")

# 绘制地图和站点
ggplot() +
  geom_sf(data = china, fill = "white", color = "black") +
  geom_point(data = top30, aes(x = LON, y = LAT, color = val), size = 3, alpha = 0.8) +
  scale_color_gradientn(colors = c("blue", "green", "yellow", "red"),
                        values = c(0, 0.25, 0.5, 0.75, 1),
                        name = "val",
                        guide = guide_colorbar(direction = "horizontal",
                                               title.position = "top",
                                               title.hjust = 0.5,
                                               ticks = FALSE,
                                               barwidth = 10,
                                               barheight = 0.5,
                                               label.position = "bottom",
                                               label.hjust = 0.5)) +
  labs(title = "全国日降水高峰点Top30分布图",
       x = "LON", y = "LAT") +
  #theme_bw(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none") +
  #添加站点名
  #geom_text(data = top30, aes(x = LON, y = LAT, label = `STATION NAME`), size = 3, fontface = "bold") +
  #添加值
  geom_text(data = top30, aes(x = LON, y = LAT, label = round(val, digits = 2)), size = 3, vjust = -1)

# 保存为PNG图片
ggsave("保存-全国日降水高峰点Top30分布图.png", plot = last_plot(), width = 10, height = 6, dpi = 300)



# 关闭连接
dbDisconnect(con)
