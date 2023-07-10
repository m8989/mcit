import ftplib
import os
import csv

# 创建本地缓存目录
cache_dir = 'D:\\Lzm-Src\\空气数据集'
if not os.path.exists(cache_dir):
    os.makedirs(cache_dir)

# 检查本地缓存文件是否存在
file_path = os.path.join(cache_dir, 'isd-history.csv')
if not os.path.exists(file_path):
    # 如果本地缓存文件不存在，则连接FTP服务器并下载文件
    print('正在连接到FTP服务器...')
    try:
        ftp = ftplib.FTP('ftp.ncdc.noaa.gov')
        ftp.login()
    except ftplib.all_errors as e:
        print(f'FTP连接错误: {e}')
        exit()

    print('正在切换到数据存放目录...')
    try:
        ftp.cwd('/pub/data/noaa/')
    except ftplib.all_errors as e:
        print(f'FTP错误: {e}')
        ftp.quit()
        exit()

    print('正在下载isd-history.csv文件...')
    try:
        with open(file_path, 'wb') as f:
            ftp.retrbinary('RETR isd-history.csv', f.write)
    except ftplib.all_errors as e:
        print(f'FTP错误: {e}')
        ftp.quit()
        exit()

    print('下载完成。')
    ftp.quit()

# 查找中国的站点
with open(file_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    headers = next(reader)
    rows = list(reader)

chinese_stations = []
for row in rows:
    if row[3] == 'CH':
        chinese_stations.append(row)

# 将结果保存到isd-history-cn.csv文件
with open(os.path.join(cache_dir, 'isd-history-cn.csv'), 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(headers)
    writer.writerows(chinese_stations)

# 输出结果
print(f'已找到{len(chinese_stations)}个中国站点，结果已保存到isd-history-cn.csv文件中。')