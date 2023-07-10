# pip install mysql-connector-python 

import os
import mysql.connector

import logging
# 创建一个日志记录器并设置级别为 INFO
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# 创建一个控制台处理器并设置级别为 INFO
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)

# 创建一个文件处理器并设置级别为 INFO
file_handler = logging.FileHandler('my_sql_file.log')
file_handler.setLevel(logging.INFO)

# 创建一个格式化器，用于设置日志消息的格式
formatter = logging.Formatter('%(message)s')

# 将格式化器添加到处理器中
console_handler.setFormatter(formatter)
file_handler.setFormatter(formatter)

# 将处理器添加到日志记录器中
logger.addHandler(console_handler)
logger.addHandler(file_handler)

# MySQL 数据库连接设置
mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="Hiaming791127"
)


# 创建数据库
def create_db(year):
    mycursor = mydb.cursor()
    mycursor.execute("CREATE DATABASE IF NOT EXISTS airdata")
    mycursor.execute("USE airdata")

    # 创建数据表（如果不存在）
    mycursor.execute(f'''CREATE TABLE IF NOT EXISTS airdata_{year} (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `usaf` varchar(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL,
  `year` int(11) NULL DEFAULT NULL,
  `month` int(11) NULL DEFAULT NULL,
  `day` int(11) NULL DEFAULT NULL,
  `hour` int(11) NULL DEFAULT NULL,
  `temperature` float NULL DEFAULT NULL,
  `dew_point` float NULL DEFAULT NULL,
  `pressure` float NULL DEFAULT NULL,
  `wind_direction` float NULL DEFAULT NULL,
  `wind_speed` float NULL DEFAULT NULL,
  `sky_condition` int(11) NULL DEFAULT NULL,
  `precipitation_1h` float NULL DEFAULT NULL,
  `precipitation_6h` float NULL DEFAULT NULL,
  `ss` decimal(11, 1) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 0;
'''
                        )
    mydb.commit()
    print(f"创建表airdata_{year}")

# 导入数据
def add_file(file_path):
    try:
        mycursor = mydb.cursor()

        # 从文件名中提取 usaf、wban 和 year 值
        filename = os.path.basename(file_path)
        usaf, wban, year = filename.split("-")

        # 打开文件读取行
        with open(file_path, "r", encoding='utf-8') as f:
            for line in f:
                # 根据官方的格式说明提取字段
                year = int(line[0:4])
                month = int(line[5:7])
                day = int(line[8:10])
                hour = int(line[11:13])
                # 下面开始清理无效值 -9999   全部换成 null
                # 温度
                temperature = line[13:19].strip()
                if int(temperature) == -9999:
                    temperature = 'NULL'
                else:
                    temperature = float(temperature) / 10

                # 露点温度
                dew_point = line[19:25].strip()
                if int(dew_point) == -9999:
                    dew_point = 'NULL'
                else:
                    dew_point = float(dew_point) / 10

                # 压力
                pressure = line[25:31].strip()
                if int(pressure) == -9999:
                    pressure = 'NULL'
                else:
                    pressure = float(pressure) / 10

                # 风向
                wind_direction = int(line[31:37].strip())
                if wind_direction == -9999:
                    wind_direction = 'NULL'

                # 风速
                wind_speed = line[37:43].strip()
                if int(wind_speed) == -9999:
                    wind_speed = 'NULL'
                else:
                    wind_speed = float(wind_speed) / 10

                # 天空情况
                sky_condition = int(line[43:49].strip())
                if sky_condition == -9999:
                    sky_condition = 'NULL'

                # 1小时降水量
                precipitation_1h = line[49:55].strip()
                if int(precipitation_1h) == -9999:
                    precipitation_1h = 'NULL'
                else:
                    precipitation_1h = float(precipitation_1h) / 10

                # 6小时降水量
                precipitation_6h = line[55:61].strip()
                if int(precipitation_6h) == -9999:
                    precipitation_6h = 'NULL'
                else:
                    precipitation_6h = float(precipitation_6h) / 10

                # 创建SQL模板
                sql =f'''INSERT INTO airdata_{year} (usaf, year, month, day, hour, temperature, dew_point, pressure, wind_direction, wind_speed, sky_condition, 
    precipitation_1h, precipitation_6h) 
VALUES ({usaf}, {year}, {month}, {day}, {hour}, {temperature}, {dew_point}, {pressure}, {wind_direction}, {wind_speed}, {sky_condition}, 
    {precipitation_1h}, {precipitation_6h})
                '''

                # 打印 SQL 查询字符串
                logging.info(f"{sql};")

                # 使用 execute() 方法来执行 SQL 查询，并将变量作为参数传递
                mycursor.execute(sql)
            mydb.commit() #每一个文件提交一次，速度会快些

    except OSError as e:
        print(f'导入文件 {file_path} 有错误: {e}')


def read_files(year_dir):
    """
    递归遍历目录，解压所有gzip文件。
    """
    for root, dirs, files in os.walk(year_dir):
        for file in files:
            if  file.endswith(".gz"):  #跳过压缩包文件
                continue
            file = os.path.join(root, file)
            add_file(file)

if __name__ == '__main__':
    root_dir = 'D:\\Lzm-Src\\空气数据集'
    for year in range(2011, 2024):  #年份，注意是小于最后一个参数的
        create_db(year)
        year_dir = os.path.join(root_dir, str(year))
        read_files(year_dir)