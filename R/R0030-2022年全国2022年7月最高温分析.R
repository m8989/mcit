# 2022年全国2022年7月最高温度分析

# 包含文件-常用包安装和加载
source("R0001常用包安装和加载.R")


# 设置工作目录
setwd("D:\\Lzm-Src\\空气数据集\\R")

# 设置数字显示格式,不用科学计数法
options(scipen = 999)

# 设置变量
year <- 2022
month <- 7
day <- 20

# 连接到 MySQL 数据库
source("inc_mysql.R")
# ============================看7月最高温========================================
# 查询全国某天的气温数据
query <- sprintf("SELECT -- y.usaf, y.`year`, y.`month`, y.`day`, y.`hour`, 
                        y.temperature, y.dew_point,
                       province
                  FROM airdata_%s AS y INNER JOIN site ON y.usaf = site.USAF
                  WHERE month = %s", year, month)

data <- dbGetQuery(con, query)

# 按省分组并计算平均温度
max_temp <- data %>%
  group_by(province) %>%
  summarize(max_temperature = max(temperature, na.rm = TRUE))

# 查看结果
head(max_temp)

# 将选择的数据保存到新的 xlsx 文件,方便美化加工
write.xlsx(data, sprintf("保存-%d年%d月全国的高温.xlsx", year, month), rowNames = FALSE)

# 获取中国地图数据
china_admin1 <- ne_states(country = "China", returnclass = "sf")

# 将平均温度数据与地图数据合并,使用省份连接
china_max_temp <- left_join(china_admin1, max_temp, by = c("name" = "province"))

# 绘制热力图
ggplot() +
  geom_sf(data = china_max_temp, aes(fill = max_temperature), color = "gray") +
  scale_fill_gradient(low = "green", high = "red") +
  geom_sf_label(data = china_max_temp, aes(label = round(max_temperature, 1)), size = 2, fill = "white") +
  ggtitle(sprintf("全国%d年%d月最高温度热力图", year, month)) +
  theme(plot.title = element_text(hjust = 0.5))

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年%d月最高温度热力图.png", year, month), plot = last_plot(), width = 10, height = 6, dpi = 300)


#===============================查询全国某天的气温================================
# 查询全国某天的气温数据
query <- sprintf("SELECT -- y.usaf, y.`year`, y.`month`, y.`day`, y.`hour`, 
                        y.temperature, y.dew_point,
                       province
                  FROM airdata_%s AS y INNER JOIN site ON y.usaf = site.USAF
                  WHERE month = %s AND day = %s", year, month, day)

data <- dbGetQuery(con, query)


# 查看数据的格式和前几行
str(data)
head(data)

# 获取中国地图数据
china_admin1 <- ne_states(country = "China", returnclass = "sf")

# 按站点分组并计算平均温度
avg_temp <- data %>%
  group_by(province) %>%
  summarize(avg_temperature = mean(temperature, na.rm = TRUE))

# 查看结果
head(avg_temp)

# 将选择的数据保存到新的 xlsx 文件,方便美化加工
write.xlsx(data, sprintf("保存-%d年%d月%d日全国的平均温度.xlsx", year, month, day), rowNames = FALSE)


# 将平均温度数据与地图数据合并
china_avg_temp <- left_join(china_admin1, avg_temp, by = c("name" = "province"))

# 绘制热力图
ggplot() +
  geom_sf(data = china_avg_temp, aes(fill = avg_temperature), color = "gray") +
  scale_fill_gradient(low = "green", high = "red") +
  geom_sf_label(data = china_avg_temp, aes(label = round(avg_temperature, 1)), size = 2, fill = "white") +
  ggtitle(sprintf("全国%d年%d月%d日平均温度热力图", year, month, day)) +
  theme(plot.title = element_text(hjust = 0.5))

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年%d月%d日平均温度热力图.png", year, month, day), plot = last_plot(), width = 10, height = 6, dpi = 300)


# ============================看最高温========================================
# 按省分组并计算平均温度
max_temp <- data %>%
  group_by(province) %>%
  summarize(max_temperature = max(temperature, na.rm = TRUE))

# 查看结果
head(max_temp)

# 将选择的数据保存到新的 xlsx 文件,方便美化加工
write.xlsx(data, sprintf("保存-%d年%d月%d日全国的高温.xlsx", year, month, day), rowNames = FALSE)


# 将平均温度数据与地图数据合并
china_max_temp <- left_join(china_admin1, max_temp, by = c("name" = "province"))

# 绘制热力图
ggplot() +
  geom_sf(data = china_max_temp, aes(fill = max_temperature), color = "gray") +
  scale_fill_gradient(low = "green", high = "red") +
  geom_sf_label(data = china_max_temp, aes(label = round(max_temperature, 1)), size = 2, fill = "white") +
  ggtitle(sprintf("全国%d年%d月%d日最高温度热力图", year, month, day)) +
  theme(plot.title = element_text(hjust = 0.5))

# 保存为 PNG 图片
ggsave(sprintf("保存-全国%d年%d月%d日最高温度热力图.png", year, month, day), plot = last_plot(), width = 10, height = 6, dpi = 300)



# 关闭连接
dbDisconnect(con)