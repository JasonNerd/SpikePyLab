---
title: "SpikePyLab日志-0729"
date: 2023-07-29T09:15:28+08:00
draft: false
tags: ["Spike Analysis"]
categories: ["SpikePyLab"]
twemoji: true
lightgallery: true
---

`2023-07-29 09:15:59`: start working @ yq

`2023-07-29 09:17:06`: prepare to learn more about tab

`2023-07-29 09:48:56`: add a new tab and add widget in it
```py
# 创建 tab 组件, 设为 central
self.tabs = QTabWidget()
self.tabs.setDocumentMode(True)
self.tabs.tabBarDoubleClicked.connect(self.tab_open_doubleclick)
self.tabs.currentChanged.connect(self.current_tab_changed)
self.tabs.setTabsClosable(True)
self.tabs.tabCloseRequested.connect(self.close_current_tab)
self.setCentralWidget(self.tabs)

def add_new_tab(self, qUrl, label="Blank"):
    # 为 tabs 添加了一个 widget
    if qUrl is None:
        qUrl = QUrl('')
    browser = QWebEngineView()
    browser.setUrl(qUrl)
    i = self.tabs.addTab(browser)
    self.tabs.setCurrentIndex(i)
    # 为当前 widget 添加触发器
    browser.urlChanged.connect(lambda qUrl, browser: self.update_urlbar(qUrl, browser))
    browser.loadFinished.connect(lambda i, browser: self.tabs.setTabText(i, browser.page().title()))
```

`2023-07-29 09:50:36`: tab_open_doubleclick
```py
# if no tab under the click, then add a new one
def tab_open_doubleclick(self, i):
    if i == -1:
        self.add_new_tab()
```

`2023-07-29 09:52:11`: current_tab_changed
```py
# if current tab changed, the nav-bar and window title should change
qUrl = self.tabs.currentWidget().url()
self.update_urlbar(qUrl, self.tabs.currentWidget())
self.update_title(self.tabs.currentWidget())
# only care about the url line edit
self.urlEdit.setText(q.toString())
self.urlEdit.setCursorPosition(0)
# set title
title = self.tabs.currentWidget().page().title()
self.setWindowTitle("%s - Mozarella Ashbadger" % title)
```

`2023-07-29 10:01:34`: close_current_tab
```py
def close_current_tab(self, i):
    if self.tabs.count() < 2:
        return
    self.tabs.removeTab(i)
```

`2023-07-29 11:13:32`: finish learning tab

`2023-07-29 13:25:15`: in app crypto, a figure plot example is given
货币汇率跟踪器，数据来自 fixer.io 默认设置显示前180天的货币数据, 左边是一个曲线图, 右边是一个表格
module `pyqtgraph` is introduced
`requests_cache` is used to store a cache file
`self define signals` are used in it

`2023-07-29 13:38:09`:
`pyqtgraph`
```py
pg.setConfigOption('background', 'w')
pg.setConfigOption('foreground', 'k')
```

`2023-07-29 14:11:59`:
`QTableView`
```py
# create
self.listView = QTableView()
self.model = QStandardItemModel()
self.model.setHorizontalHeaderLabels(["Currency", "Rate"])
self.listView.setModel(self.model)
self.listView.horizontalHeader().setSectionResizeMode(QHeaderView.ResizeMode.Stretch)
# add row
def add_data_row(self, currency):
    citem = QStandardItem()
    citem.setText(currency)
    citem.setForeground(QBrush(QColor(
        self.get_currency_color(currency)
    )))
    citem.setCheckable(True)
    if currency in DEFAULT_DISPLAY_CURRENCIES:
        citem.setCheckState(Qt.Checked)
    vitem = QStandardItem()

    self.model.appendRow([citem, vitem])
    self.model.sort(0)
    return citem, vitem
# update row
def update_data_row(self, currency, data):
    citem, vitem = self.get_or_create_data_row(currency)
    vitem.setText("%.4f" % data['close'])
```


`2023-07-29 14:34:23`: the common use of pyqtgraph mabe a little difficult, see the next one. 
how to use `pyqtSignal`


`2023-07-29 14:50:35`: in `mediaplayer` app, it demostrate how ui-design split from action excute
```py
class MainWindow(QMainWindow, Ui_MainWindow):
    def __init__(self, *args, **kwargs):
        super(MainWindow, self).__init__(*args, **kwargs)
        self.setupUi(self)
```

`2023-07-29 15:17:20`: 15 munitues app 还是太复杂了, 但提供了一些可以探索和参考的角度, 接下来需要看的分别是:
1. 自由的布局, 三栏四栏, 底层栏, Layout
2. 流畅的绘图, pyqtgraph
3. 自定义信号, pyqtSignal