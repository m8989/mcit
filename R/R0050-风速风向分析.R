# 2022整年的风速风向分析

# 包含文件-常用包安装和加载
source("R0001常用包安装和加载.R")

# 包含文件-连接到 MySQL 数据库
source("inc_mysql.R")




# 设置工作目录
setwd("D:\\Lzm-Src\\空气数据集\\R")

# 设置数字显示格式,不用科学计数法
options(scipen = 999)

# 设置变量
year <- 2022  #开始年份
# month <- 5
# day <- 1

# 连接到 MySQL 数据库
source("inc_mysql.R")

# 查询一年的风速风向数据
query <- sprintf("
SELECT wind_direction, wind_speed, `STATION NAME` AS STATION_NAME, LAT, LON
  FROM airdata_%s AS y INNER JOIN site ON y.usaf = site.USAF
  WHERE  wind_direction IS NOT NULL AND wind_speed > 0
                  ", year)


print(query);

data <- dbGetQuery(con, query)





# 查看数据的格式和前几行
str(data)
head(data)


# ========================数据清理===================================
# (在数据入库时和查询条件中已经清理过了)

# 删除包含缺失值的数据行
data <- na.omit(data)

# 去掉风速为0的行
data <- data[data$wind_speed != 0, ]



#=======================风速和风向的平均值和标准差=============================================


# 为每个站点计算风速和风向的平均值和标准差
data_mean_sd <- data %>% 
  group_by(LAT, LON,STATION_NAME) %>% 
  summarize(wind_speed_mean = mean(wind_speed), 
            wind_direction_mean = mean(wind_direction), 
            wind_speed_sd = sd(wind_speed), 
            wind_direction_sd = sd(wind_direction))
# 节约内存
#rm(data)

# 按照风速降序排列，并选取前40个点
top40_data <- data_mean_sd %>% 
  arrange(desc(wind_speed_mean)) %>% 
  head(40)

# 将选择的数据保存到新的xlsx文件,方便美化加工
write.xlsx(top40_data, "保存-2022年风能资源top40.xlsx", rowNames = FALSE)


# 获取中国地图数据
china_admin1 <- ne_states(country = "China", returnclass = "sf")


# 绘制地图和站点
ggplot() +
  geom_sf(data = china_admin1, fill = "white", color = "black") +
  geom_point(data = top40_data, aes(x = LON, y = LAT, color = wind_speed_mean),
             size = 4, alpha = 0.8) +
  scale_color_gradient(low = "darkblue", high = "red") +
  labs(title = "2022年风能资源分布图", x = "LON", y = "LAT") +
  theme_bw(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5),
       # legend.position = "bottom",
        legend.box.background = element_rect(colour = "black", size = 0.5),
        legend.title = element_blank()) +
  # 添加风速和风向的平均值标签
  geom_text(data = top40_data, aes(x = LON, y = LAT,
                                   label = paste(" ", round(wind_speed_mean, 2), " m/s\n",
                                                  "°")),
            size = 3, fontface = "bold", color = "black", nudge_y = 0.2)

# 保存为 PNG 图片
  ggsave(sprintf("保存-全国%d年风能资源分布图.png", year), plot = last_plot(), width = 10, height = 6, dpi = 300)


# 绘制柱形图
ggplot(top40_data, aes(x = reorder(STATION_NAME, -wind_speed_mean), y = wind_speed_mean)) +
  geom_col(fill = "lightblue", color = "black", width = 0.5) +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x = element_blank(),
        axis.title.y = element_text(size = 12),
        plot.margin = unit(c(1, 1, 4, 1), "lines")) +
  labs(title = "2022年风能资源top40柱形图", y = "风速平均值")

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年风能资源top40柱形图.png", year), plot = last_plot(), width = 10, height = 6, dpi = 300)

# 箱线图
ggplot(top40_data, aes(x = reorder(STATION_NAME, -wind_speed_mean))) +
  geom_boxplot(aes(y = wind_speed_mean, fill = "lightblue"), color = "darkblue", width = 0.5) +
  geom_errorbar(aes(ymin = wind_speed_mean - wind_speed_sd, ymax = wind_speed_mean + wind_speed_sd, color = "red"),
                width = 0.5, size = 2, alpha = 0.5) +
  labs(title = "2022年风能资源top40箱线图",x="站点", y = "平均风速和方差范围") +
  scale_fill_manual(values = c("lightblue")) +
  scale_color_manual(values = c("red", "darkblue")) +
  theme(plot.title = element_text(hjust = 0.5),
        legend.position = "none",
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年风能资源top40箱线图.png", year), plot = last_plot(), width = 10, height = 6, dpi = 300)


#创建风向雷达图
ggplot(top40_data, aes(x = wind_direction_mean, y = wind_direction_sd, group = STATION_NAME)) +
  geom_point(size = 3, color = "red") + # 红色点
  coord_polar(start = 0) + #起始方位
  scale_x_continuous(limits = c(0, 360), breaks = seq(0, 360, by = 45),
                     labels = c("北", "东北", "东", "东南", "南", "西南", "西", "西北", "")) +
  scale_y_continuous(limits = c(0, 180), breaks = seq(0, 180, by = 180),
                     labels = c("", "")) +
  labs(title = "风向雷达图", x = "风向平均值", y = "风向标准差") +
  theme(plot.title = element_text(hjust = 0.5),
        axis.text = element_text(size = 12),
        axis.title = element_text(size = 14),
        axis.line = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "gray", size = 0.5)) +
  theme(plot.margin = unit(c(1, 1, 0, 1), "cm"))+
  geom_text(aes(label = STATION_NAME, x = wind_direction_mean * 1.15, y = wind_direction_sd * 1.15),
            size = 3, color = "#999999", alpha = 0.5, fontface = "bold") 

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年风向雷达图.png", year), plot = last_plot(), width = 10, height = 6, dpi = 300)


# 关闭连接
dbDisconnect(con)

