# 包含文件-常用包安装和加载
source("R0001常用包安装和加载.R")

# 包含文件-连接到 MySQL 数据库
source("inc_mysql.R")


# 设置工作目录
setwd("D:\\Lzm-Src\\空气数据集\\R")

# 设置数字显示格式,不用科学计数法
options(scipen = 999)


# 查询站点数据，过滤掉无定位的站点
query <- "SELECT USAF, `STATION NAME`, LAT, LON, `END` IS NOT NULL AND `END` < '2023-01-01' AS isstop
          FROM site
          WHERE LAT IS NOT NULL AND LON IS NOT NULL AND (LAT != 0 OR LON != 0)"
data <- dbGetQuery(con, query)

# 将选择的数据保存到新的xlsx文件,方便美化加工
write.xlsx(data, "保存-全国站点分布定位数据.xlsx", rowNames = FALSE)





# 获取中国地图数据
#china <- ne_countries(country = "china", returnclass = "sf")
china_admin1 <- ne_states(country = "China", returnclass = "sf")


# 计算每个组的行数
n_stops <- sum(data$isstop == 1)
n_nonstops <- sum(data$isstop == 0)

# 绘制地图和站点
ggplot() +
  geom_sf(data = china_admin1, fill = "white", color = "black") +
  geom_point(data = data, aes(x = LON, y = LAT, color = factor(isstop)),
             size = 2, alpha = 0.8) +
  scale_color_manual(values = c( "green","red"),
                     labels = c( "运行中站点","已停运站点")) +
  labs(title = "全国气象站点分布图",
       x = "LON", y = "LAT") +
  theme_bw(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        legend.box.background = element_rect(colour = "black", size = 0.5),
        legend.title = element_blank()) +
  ggrepel::geom_text_repel(data = data, aes(label = `STATION NAME`, x = LON, y = LAT),
                           size = 3, fontface = "bold", 
                           min.segment.length = 0.2, 
                           segment.alpha = 0.2,
                           max.overlaps = 1) +
  # 添加文本标签显示每个组的总行数
  geom_text(data = data.frame(x = 83, y = 14.5, label = paste0("已停运站点: ", n_stops)), 
            aes(x = x, y = y, label = label), size = 5, vjust = -1) +
  geom_text(data = data.frame(x = 83, y = 13.5, label = paste0("运行中站点: ", n_nonstops)), 
            aes(x = x, y = y, label = label), size = 5, vjust = 1)



# 保存为PNG图片
ggsave("保存-全国气象站点分布图.png", plot = last_plot(), width = 10, height = 6, dpi = 300)


# =====================找出浙江的站点=================================
# 连接到 MySQL 数据库

# 查询站点数据，过滤掉无定位的站点,找出浙江的站点
query <- "SELECT USAF, `STATION NAME`, LAT, LON, `END` IS NOT NULL AND `END` < '2023-01-01' AS isstop
          FROM site
          WHERE LAT IS NOT NULL AND LON IS NOT NULL AND (LAT != 0 OR LON != 0) 
          AND province='Zhejiang'
          "
data <- dbGetQuery(con, query)

# 将选择的数据保存到新的xlsx文件,方便美化加工
write.xlsx(data, "保存-浙江站点定位数据.xlsx", rowNames = FALSE)



#过滤出浙江省
zhejiang <- china_admin1[china_admin1$name == "Zhejiang", ]
# 将地图数据保存为shapefile格式,其它分析有用
st_write(zhejiang, "zhejiang.shp")

# 计算每个组的行数
n_stops <- sum(data$isstop == 1)
n_nonstops <- sum(data$isstop == 0)

# 绘制地图和站点
ggplot() +
  geom_sf(data = zhejiang, fill = "white", color = "black") +
  geom_point(data = data, aes(x = LON, y = LAT, color = factor(isstop)),
             size = 2, alpha = 0.8) +
  scale_color_manual(values = c( "green","red"),
                     labels = c( "运行中站点","已停运站点")) +
  labs(title = "浙江气象站点分布图",
       x = "LON", y = "LAT") +
  theme_bw(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "bottom",
        legend.box.background = element_rect(colour = "black", size = 0.5),
        legend.title = element_blank()) +
  ggrepel::geom_text_repel(data = data, aes(label = `STATION NAME`, x = LON, y = LAT),
                           size = 3, fontface = "bold", 
                           min.segment.length = 0.2, 
                           segment.alpha = 0.2,
                           max.overlaps = 1) +
  # 添加文本标签显示每个组的总行数
  geom_text(data = data.frame(x = 120, y = 28.0, label = paste0("已停运站点: ", n_stops)), 
            aes(x = x, y = y, label = label), size = 5, vjust = -1) +
  geom_text(data = data.frame(x = 120, y = 27.5, label = paste0("运行中站点: ", n_nonstops)), 
            aes(x = x, y = y, label = label), size = 5, vjust = 1)

# 保存为PNG图片
ggsave("保存-浙江气象站点分布图.png", plot = last_plot(), width = 10, height = 6, dpi = 300)


# 关闭连接
dbDisconnect(con)