# =====================================================
# 递归遍历目录，解压所有gzip文件
# =====================================================
import os
import gzip
import shutil

def extract_gzip_file(gzip_file):
    """
    解压gzip文件，如果对应的文件已经存在，则跳过解压缩。
    """
    file_path = gzip_file[:-3] # 去掉.gz后缀
    if os.path.exists(file_path):
        print(f'{file_path} 已经存在，跳过解压缩。')
        return

    print(f'正在解压缩 {gzip_file}...')
    try:
        with gzip.open(gzip_file, 'rb') as f_in:
            with open(file_path, 'wb') as f_out:
                shutil.copyfileobj(f_in, f_out)
        print(f'解压缩 {gzip_file} 完成。')
    except EOFError as e:
        print(f'压缩文件 {gzip_file} 有错误: {e}')
        ## 这些极少数是最早用ftplib下载过程中网络出错没下完的，
        #xml_content = '''
        #<File>
        #    <LocalFile>{file_path}.gz</LocalFile>
        #    <RemoteFile>{file_path}.gz</RemoteFile>
        #    <RemotePath>1 0 3 pub 4 data 4 noaa 8 isd-lite 4 2023</RemotePath>
        #    <Download>1</Download>
        #    <Size>0</Size>
        #    <DataType>1</DataType>
        #</File>
        #'''.format(file_path=file_path)

        #with open("重新下载列表.xml", 'w') as f:
        #    f.write(xml_content)



        

def extract_gzip_files(root_dir):
    """
    递归遍历目录，解压所有gzip文件。
    """
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.gz'):
                gzip_file = os.path.join(root, file)
                extract_gzip_file(gzip_file)

if __name__ == '__main__':
    root_dir = 'D:\\Lzm-Src\\空气数据集'
    extract_gzip_files(root_dir)