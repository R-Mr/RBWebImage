# RBWebImage
## 造轮子系列
swift简化版SDWebImage
1.设置网络图片
2.通过url在缓存中获取图片（先在内存中找，内存中没有找到就到次盘中找）
3.在缓存中找到后就直接设置
4.在缓存中没有找到就通过网络请求异步请求图片
5.请求到图片后回到主线程设置图片
