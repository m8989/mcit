# =====================================================
# 到考虑到实际ftplib单线程下载太慢，还不能设代理服务器
# 改成生成一个下载队列，导入FileZilla后多线程下载+国外代理加速
# =====================================================
import os
import csv
import xml.etree.ElementTree as ET

# 创建本地缓存目录
cache_dir = 'D:\\Lzm-Src\\空气数据集'
if not os.path.exists(cache_dir):
    os.makedirs(cache_dir)

# 读取isd-history-cn.csv文件中的站点信息
history_file = os.path.join(cache_dir, 'isd-history-cn.csv')
if not os.path.exists(history_file):
    print(f'{history_file}文件不存在，请先下载该文件。')
    exit()

# 读取上次下载到的站点号，因为之前下载不顺，已经完成一部份了
last_station_file = os.path.join(cache_dir, 'last_station.txt')
if os.path.exists(last_station_file):
    with open(last_station_file, 'r') as f:
        last_station = f.read().strip()
else:
    last_station = '0'

# 创建一个变量缓存站点
chinese_stations = []
# 从文件中读取
with open(history_file, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    # 单独把标题行读出来
    headers = next(reader)
    for row in reader:
        if row[3] == 'CH':
            if(last_station==row[0]):
                print(f'历史记录发现相符的站点，从这里开始{row[2]}。')
                chinese_stations=[]  # 将前面的站点都跳过,因为站点太多了。不容易一次采集完
            # 有效的中国站点加到待处理列表中
            chinese_stations.append(row)

# 生成FileZilla队列XML文件
queue_file = os.path.join(cache_dir, 'filezilla_queue-2010-2023.xml')
# xml格式根结点
root = ET.Element("FileZilla3")
queue = ET.SubElement(root, "Queue")
server = ET.SubElement(queue, "Server")

for station in chinese_stations:
    usaf = station[0]
    wban = station[1]
    name = station[2]
    print(f'正在生成{usaf}-{wban}-{name}的下载列表...')

    for year in range(2010, 2023):
        remote_file_path = f'/pub/data/noaa/isd-lite/{year}/{usaf}-{wban}-{year}.gz'
        local_file_path = os.path.join(cache_dir, str(year), f'{usaf}-{wban}-{year}.gz')

        # 记录该站点本次下载到的站点号,断点继续
        with open(last_station_file, 'w') as f:
            f.write(str(usaf))

        # 检查本地缓存文件是否存在，如果存在则跳过下载
        #if os.path.exists(local_file_path):
        #    print(f'{year}年的数据已存在，跳过下载。')
        #    continue

        # 添加一个<File>元素到XML队列中
        file_elem = ET.SubElement(server, "File")
        local_file_elem = ET.SubElement(file_elem, "LocalFile")
        local_file_elem.text = local_file_path
        remote_file_elem = ET.SubElement(file_elem, "RemoteFile")
        remote_file_elem.text = os.path.basename(remote_file_path)
        remote_path_elem = ET.SubElement(file_elem, "RemotePath")
        #remote_path_elem.text = os.path.dirname(remote_file_path)
        remote_path_elem.text = f'1 0 3 pub 4 data 4 noaa 8 isd-lite 4 {year}'
        download_elem = ET.SubElement(file_elem, "Download")
        download_elem.text = "1"
        size_elem = ET.SubElement(file_elem, "Size")
        size_elem.text = "0"
        data_type_elem = ET.SubElement(file_elem, "DataType")
        data_type_elem.text = "1"

print(f'正在将下载队列保存到{queue_file}...')
tree = ET.ElementTree(root)
tree.write(queue_file, encoding="utf-8", xml_declaration=True)

print('下载队列生成完成。还建议手工替换文件头部分内容。')


"""
<?xml version="1.0" encoding="UTF-8"?>
<FileZilla3 version="3.44.2" platform="windows">
	<Queue>
		<Server>
			<Host>ftp.ncdc.noaa.gov</Host>
			<Port>21</Port>
			<Protocol>0</Protocol>
			<Type>0</Type>
			<Logontype>0</Logontype>
			<TimezoneOffset>0</TimezoneOffset>
			<PasvMode>MODE_DEFAULT</PasvMode>
			<MaximumMultipleConnections>0</MaximumMultipleConnections>
			<EncodingType>Auto</EncodingType>
			<BypassProxy>0</BypassProxy>
			<Name>自NCDC的公开FTP服务器</Name>
			<File>
"""