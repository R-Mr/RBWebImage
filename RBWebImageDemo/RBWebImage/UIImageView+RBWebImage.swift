//
//  UIImageView+RBWebImage.swift
//  RBWebImageDemo
//
//  Created by RanBin on 2021/9/5.
//

import UIKit

let isShowRBWebImageLog = true



extension UIImageView: RBWebImageProtocol {
    
    
    /// 设置网络图片
    /// - Parameters:
    ///   - url: url
    ///   - defaultImage: 占位图
    ///   - isKeepOriginal: 在原来有图片时，是否保持原有的图片（true：不替换占位图，false：每次都替换占位图）
    ///   - completion: 完成后回调
    func rbSetImage(url: URL?, defaultImage: UIImage?, isKeepOriginal: Bool = false, completion: ((UIImage?) -> Void)? = nil) {
        showLog("开始设置网络图片：\(url?.absoluteString ?? "")")
        if !isKeepOriginal {
            self.image = nil
        }
        let originImage = self.image
        if originImage == nil && defaultImage != nil {
            self.image = defaultImage!
        }
        if url == nil {
            completion?(nil)
            showLog("设置失败：url空")
            return
        }
        
        // 从缓存中获取图片加载
        if let cacheImage = RBWebImageCach.getCacheImage(urlStr: url!.absoluteString) {
            // 在主线程更新图片
            DispatchQueue.main.async {[weak self] in
                self?.image = cacheImage
            }
            self.showLog("设置成功：\(url!.absoluteString)")
            return
        }
        showLog("缓存中获取图片失败：\(url!.absoluteString)")
        
        // 缓存中没有时通过网络请求图片数据
        showLog("开始通过网络请求图片数据：\(url!.absoluteString)")
        getData(url: url!) {[weak self] (data) in
            if data == nil {
                completion?(nil)
                self?.showLog("设置失败：网络请求到的数据为空-\(url!.absoluteString)")
            }else {
                if let ima = UIImage(data: data!) {
                    // 在主线程更新图片
                    DispatchQueue.main.async {[weak self] in
                        self?.image = ima
                    }
                    // 缓存图片data
                    RBWebImageCach.saveImageData(data: data!, urlStr: (url!.absoluteString))
                    
                    self?.showLog("设置成功：\(url!.absoluteString)")
                    completion?(ima)
                }else {
                    self?.showLog("设置失败：网络请求到的数据转图片失败-\(url!.absoluteString)")
                    completion?(nil)
                }
            }
        }
    }
    
    
    /// 设置网络图片
    /// - Parameters:
    ///   - urlStr: url字符串
    ///   - defaultImageName: 占位图名称
    func rbSetImage(urlStr: String, defaultImageName: String?) {
        var defauleImage: UIImage? = nil
        if defaultImageName != nil {
            defauleImage = UIImage(named: defaultImageName!)
        }
        var url: URL? = nil
        if let us = urlStr.urlString() {
            url = URL(string: us)
        }
        rbSetImage(url: url, defaultImage: defauleImage, isKeepOriginal: false, completion: nil)
        
    }
    
    
    /// 打印日志
    /// - Parameter msg: msg 日志信息
    private func showLog(_ msg: String) {
        if isShowRBWebImageLog {
            print(msg)
        }
    }
    
    
}


extension String {
    
    /// 格式化url
    /// - Returns: 格式化url字符串
    func urlString() -> String? {
        if self.count == 0 {
            return nil
        }
        let urlStr = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, self as CFString, "!$&'()*+,-./:;=?@_~%#[]" as CFString) as String?
        if urlStr == nil || urlStr?.count == 0 {
            return nil
        }
        return urlStr
    }
}
