//
//  Network.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/02/02.
//

import Foundation
import Reachability

// MARK: -  Reachability
class network {
    
    // 通信状態を確認する
    class func checkReachability(reachability: Reachability, view: UIView, alart: Bool) -> Bool {
        
        // デフォルトでTRUEを返す
        var bool = true
        
        // 通信不可の場合FALSEを返す
        if  reachability.connection == .unavailable {
            
            bool = false
            
            if alart {
                let width = view.frame.size.width * 0.9
                let height = view.frame.size.height * 0.1
                float.show(message: "インターネット接続がありません", width: width, height: height)
            }
        }
        return bool
    }
}

