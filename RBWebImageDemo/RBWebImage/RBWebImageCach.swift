//
//  RBWebImageCach.swift
//  RBWebImageDemo
//
//  Created by RanBin on 2021/9/5.
//

import Foundation
import UIKit


fileprivate func showLog(_ msg: String) {
    if isShowRBWebImageLog {
        print(msg)
    }
}

class RBWebImageCach {
    
    /// 从缓存中获取图片
    /// - Parameter urlStr: 图片url
    /// - Returns: 缓存中的图片
    class func getCacheImage(urlStr: String) -> UIImage? {
        let key = getKeyString(urlStr: urlStr)
        // 从内存中获取图片
        showLog("将去内存中获取缓存：\(urlStr)")
        if let cacheImage = RBWebImageMemoryManager.shared.getImage(key: key) {
            showLog("内存中找到图片：\(urlStr)")
            return cacheImage
        }
        showLog("内存中没有找到，将去磁盘中获取缓存：\(urlStr)")
        // 内存中没有时，从磁盘中获取图片数据
        if let data = RBWebImageDiskManager.shared.getData(key: key) {
            if let cacheImage = UIImage(data: data) {
                showLog("磁盘中找到图片：\(urlStr)")
                return cacheImage
            }
            
        }
        
        return nil
    }
    
    /// 保存图片数据
    /// - Parameters:
    ///   - data: 图片数据
    ///   - urlStr: 图片url
    class func saveImageData(data: Data, urlStr: String) {
        let key = getKeyString(urlStr: urlStr)
        
        if let image = UIImage(data: data) {
            // 缓存到内存中
            showLog("存储到内存中：\(urlStr)")
            RBWebImageMemoryManager.shared.saveImage(image: image, key: key)
            // 缓存到磁盘中
            showLog("存储到磁盘中：\(urlStr)")
            RBWebImageDiskManager.shared.saveImage(data: data, key: key)
            
        }else {
            showLog("无效数据：\(urlStr)")
        }
        
        
        
    }
    
    /// 删除所有缓存数据
    class func deleteAllCacheData() {
        // 删除内存中的所有缓存数据
        RBWebImageMemoryManager.shared.deleteAllImage()
        // 删除磁盘中所有缓存数据
        RBWebImageDiskManager.shared.deleteAllCacheData()
        
    }
    class func deleteCacheData(urlStr: String) {
        let key = getKeyString(urlStr: urlStr)
        // 删除内存中的缓存数据
        RBWebImageMemoryManager.shared.deleteImage(key: key)
        
        // 删除磁盘中的缓存数据
        RBWebImageDiskManager.shared.deleteCacheData(key: key)
        
    }
    
    /// 获取缓存图片数据的大小
    /// - Returns: 图片数据的大小
    class func getCacheSize() -> Double {
        return RBWebImageDiskManager.shared.getCacheSize()
    }
    
    /// 根据url字符串获取缓存用的key
    /// - Parameter urlStr: url字符串
    /// - Returns: key
    private class func getKeyString(urlStr: String) -> String {
        var key = urlStr
        for s in ":/\\." {
            key = key.replacingOccurrences(of: String(s), with: "_")
        }
        
        return key
    }
    
    
}


/// 内存缓存管理类
class RBWebImageMemoryManager {
    static let shared = RBWebImageMemoryManager()
    private init() {}
    
    private let cache = NSCache<NSString, UIImage>()
    private var keys = Array<NSString>()
    
    
    /// 保存图片到内存中
    /// - Parameters:
    ///   - image: 图片
    ///   - key: key
    func saveImage(image: UIImage, key: String) {
        let nKey = key as NSString
        if !keys.contains(nKey) {
            keys.append(nKey)
        }
        cache.setObject(image, forKey: nKey)
    }
    
    /// 通过key获取内存中的图片
    /// - Parameter key: key
    /// - Returns: 内存中的图片
    func getImage(key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    /// 删除内存中的所有图片
    func deleteAllImage() {
        cache.removeAllObjects()
        keys.removeAll()
    }
    
    /// 删除key对应的图片
    /// - Parameter key: key
    func deleteImage(key: String) {
        let nKey = key as NSString
        cache.removeObject(forKey: nKey)
    }
    
    
    
}

/// 磁盘缓存管理类
class RBWebImageDiskManager {
    static let shared = RBWebImageDiskManager()
    private init() {}
    
    private let cachePath = "\(NSHomeDirectory())/Library/Caches/BGWebImageCache"// 缓存路径
    
    
    
    /// 保存数据到磁盘中
    /// - Parameters:
    ///   - data: 数据
    ///   - key: key
    func saveImage(data: Data, key: String) {
        let path: String = getFullCachePath(key: key)
        if FileManager.default.createFile(atPath: path, contents: data, attributes: nil) {
            showLog("保存成功")
        }else {
            showLog("保存失败")
            
        }
    }
    
    /// 通过key获取磁盘中的图片数据
    /// - Parameter key: key
    /// - Returns: 磁盘中的图片数据
    func getData(key: String) -> Data? {
        var data:Data?
        let path: String = getFullCachePath(key: key)
        if FileManager.default.fileExists(atPath: path) {
            data = FileManager.default.contents(atPath: path)
        }
        return data
    }
    
    /// 删除磁盘中的所有图片数据
    func deleteAllCacheData() {
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: cachePath) {
            
            do {
                try fileManager.removeItem(atPath: cachePath)
            } catch  {
               showLog("删除磁盘缓存异常")
            }
            
        }
    }
    
    /// 删除key对应的图片数据
    /// - Parameter key: key
    func deleteCacheData(key: String) {
        let path = getFullCachePath(key: key)
        
        let fileManager: FileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch  {
                showLog("删除磁盘缓存异常")
                
            }
            
        }
    }
    
    /// 获取磁盘中图片的总大小
    /// - Returns: size
    func getCacheSize() -> Double {
        let manage = FileManager.default
        if !manage.fileExists(atPath: cachePath) {
            return 0
        }
        let childFilePath = manage.subpaths(atPath: cachePath)
        var size:Double = 0
        for path in childFilePath! {
            let fileAbsoluePath = cachePath+"/"+path
            size += getFileSize(filePath: fileAbsoluePath)
        }
        return size
    }
    
    
    /// 通过key获取完整的缓存路径
    /// - Parameter key: key
    /// - Returns: 完整缓存路径
    private func getFullCachePath(key: String) -> String {
        let path = "\(cachePath)/\(key)"
        let fileManager: FileManager = FileManager.default
        if !(fileManager.fileExists(atPath: cachePath)) {
            do {
                try fileManager.createDirectory(atPath: cachePath, withIntermediateDirectories: true, attributes: nil)
                return path
            }catch {
                showLog("缓存完整路径设置失败")
                return ""
            }
        }
        return path
    }
    
    /// 获取文件大小
    /// - Parameter filePath: 文件路径
    /// - Returns: 文件大小
    private func getFileSize(filePath: String) -> Double {
        let manager = FileManager.default
        var fileSize:Double = 0
        do {
            let attr = try manager.attributesOfItem(atPath: filePath)
//            fileSize = Double(attr[FileAttributeKey.size] as! UInt64)
            let dict = attr as NSDictionary
            fileSize = Double(dict.fileSize())
        } catch {
            showLog("\(error)")
        }
        return fileSize
    }
    
}
