# 浙江萧山2011年来气温折线图

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


# 查询浙江萧山12年来的气温数据
# 考虑到昼夜温差大，平均数会掩盖细节，所以重点取当日最高温来分析
query <- ""
for (i in 2012:2023) {
  query <- paste0( query, sprintf("
  UNION 
  SELECT CONCAT(y.`year`, '-', y.`month`, '-', y.`day`) AS date,
  MAX(y.temperature) AS temperature, MIN(y.temperature) AS min_temperature
  FROM airdata_%s AS y INNER JOIN site ON y.usaf = site.USAF
  WHERE site.province = 'Zhejiang' AND `STATION NAME` ='XIAOSHAN'
  GROUP BY y.`year`, y.`month`, y.`day`
                   ", i),collapse = "")
}  
# 去掉前 10 个字符
query <- substr(query, 11, nchar(query))
print(query);

data <- dbGetQuery(con, query)



# 查看数据的格式和前几行
str(data)
head(data)


# ========================数据分析===================================
# (在数据入库时和查询条件中已经清理过了)
# data是十二年的每天温度数据，看看有没有缺失值
sum(is.na(data))

# # 用平均值填充缺失值
# data$temperature[is.na(data$temperature)] <- mean(data$temperature, na.rm = TRUE)
# #data$dew_point[is.na(data$dew_point)] <- mean(data$dew_point, na.rm = TRUE)
# 
# # 再次查找缺失值（确保已经填充完毕）
# sum(is.na(data))

# 绘制折线图 
ggplot(data, aes(x = as.Date(date), y = temperature)) +
  geom_line(aes(color = "最高"), linewidth = 0.4) +
  geom_line(aes(y = min_temperature, color = "最低"), linewidth = 0.6) +
  #geom_ribbon(aes(ymin = min_temperature, ymax = temperature, fill = min_temperature), alpha = 0.3) +
  labs(title = "萧山几年来高低气温折线图", x = "日期", y = "温度", color = "图例") +
  theme(axis.text.x = element_text(angle = 45, hjust = 0.5),plot.title = element_text(hjust = 0.5)) +
  scale_x_date(date_breaks = "6 months", date_labels = "%Y-%m") +
  scale_color_manual(values = c("最高" = "red", "最低" = "blue")) +
  scale_fill_gradient(low = "blue", high = "red")

# 保存为 PNG 图片
ggsave(sprintf("保存-萧山%s几年来高低气温折线图.png", year), plot = last_plot(), width = 10, height = 6, dpi = 300)

# 关闭连接
dbDisconnect(con)
