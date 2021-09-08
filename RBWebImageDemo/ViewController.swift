//
//  ViewController.swift
//  RBWebImageDemo
//
//  Created by RanBin on 2021/9/5.
//

import UIKit

class ViewController: UIViewController {
    var imageView = UIImageView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "RBWebImageDemo"
        self.view.backgroundColor = .white
        imageView = UIImageView(frame: CGRect(x: 0, y: 88, width: self.view.bounds.width, height: self.view.bounds.height - 88 - 180))
        imageView.backgroundColor = .lightGray
        self.view.addSubview(imageView)
        
        let label = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height + 88 + 20, width: self.view.bounds.width, height: 40))
        label.text = "点击更换图片"
        label.textAlignment = .center
        self.view.addSubview(label)
        
        
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("点击屏幕")
        
        let urlStrAry = [
            "https://img0.baidu.com/it/u=2837725246,940991864&fm=15&fmt=auto&gp=0.jpg",
            "https://img-blog.csdnimg.cn/20210109174527717.jpeg?x-oss-process=image/resize,m_fixed,h_224,w_224",
            "https://profile.csdnimg.cn/B/A/D/1_qq_29305413",
            "https://blog.csdn.net/Morris_/article/details/107382069",
            "ssfefwda"
        ]
        let ranNum = Int(arc4random())
        
        
        let urlStr = urlStrAry[ranNum % urlStrAry.count]
        
        imageView.rbSetImage(urlStr: urlStr, defaultImageName: nil)
        print("缓存数据：\(RBWebImageCach.getCacheSize())")
        
        
        if ranNum % 8 == 0 {
            print("删除缓存：\(urlStr)")
            RBWebImageCach.deleteCacheData(urlStr: urlStr)
            print("缓存数据：\(RBWebImageCach.getCacheSize())")
        }
        if ranNum % 9 == 0 {
            print("删除所有缓存")
            RBWebImageCach.deleteAllCacheData()
            print("缓存数据：\(RBWebImageCach.getCacheSize())")
        }
        
    }

    
}

