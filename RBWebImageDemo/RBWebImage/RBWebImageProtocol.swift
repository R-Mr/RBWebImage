//
//  RBWebImageProtocol.swift
//  RBWebImageDemo
//
//  Created by RanBin on 2021/9/7.
//

import Foundation
import UIKit

protocol RBWebImageProtocol {
    /// 通过url获取data
    /// - Parameters:
    ///   - url: url
    ///   - completion: 完成后的回调
    func getData(url: URL, completion: ((Data?) -> Void)?)
    
    
}

extension RBWebImageProtocol {
    /// 通过url获取data
    /// - Parameters:
    ///   - url: url
    ///   - completion: 完成后的回调
    func getData(url: URL, completion: ((Data?) -> Void)? = nil) {
        // 创建并行队列异步执行
        DispatchQueue(label: "com.RBWebImage.concurrentQueue",attributes:.concurrent).async {
            do {
                let data: Data = try Data(contentsOf: url)
                if data.count > 0 {
                    completion?(data)
                }else {
                    completion?(nil)
                }
                
            } catch _ {
                completion?(nil)
            }
        }
    }

    

}
