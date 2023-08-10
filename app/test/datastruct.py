import io
import json


def test():
    a = {127: {0, 1, 2}, 3: {0, 1}}
    for k in a.keys():
        a[k] = list(a[k])
    print(a)


def toJson(path, data):
    # 写入 json 文件 到同目录
    f = io.open(path, 'w', encoding='utf-8')
    json.dump(data, f, ensure_ascii=False)
    f.close()

def readJson(path):
    f = io.open(path, 'r', encoding='utf-8')
    j_str = f.readline()
    f.close()
    return json.loads(j_str)

if __name__ == '__main__':
    test()


