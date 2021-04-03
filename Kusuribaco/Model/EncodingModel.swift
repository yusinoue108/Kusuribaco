//
//  URLEncoding.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import Foundation

class URLEncoding {
   
    // URLエンコードをする(eucjp)
    func eucjpPercentEncoding(URLString: String) -> String {

        let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let eucjp = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_JP.rawValue)))
        
        // Dataに変換する
        let stringData = URLString.data(using: eucjp, allowLossyConversion: true) ?? Data()

        // URLエンコードしていく
        let percentEscaped = stringData.map { byte -> String in

            if allowedCharacters.contains(UnicodeScalar(byte)) {
                
                return String(UnicodeScalar(byte))
            } else if byte == UInt8(ascii: " ") {
                // 半角スペースの場合は + を返す
                
                return "+"
            } else {
                
                return String(format: "%%%02X", byte)
            }
            
        }.joined()
        
        return percentEscaped
    }

    // URLエンコードをする(utf8)
    func utf8PercentEncoding(URLString: String) -> String {
        
        let allowedCharacters = NSCharacterSet.alphanumerics.union(.init(charactersIn: "-._~"))
        return URLString.addingPercentEncoding(withAllowedCharacters: allowedCharacters)!
    }
}
