//
//  Bookmark.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import Foundation
import RealmSwift

class Bookmark: Object {
    
    // 医薬品名
    @objc dynamic var drugName: String = ""
    // URL(SGML)
    @objc dynamic var sgmlURL: String  = ""
    // 区分(医療用、要指導、第一類)
    @objc dynamic var kubun: String = ""
    // 詳細情報(製造販売元、医薬日品区分)
    @objc dynamic var detail: String = ""
    // 追加日(システム日付)
    @objc dynamic var addDate: Date = Date()
    // メモ
    @objc dynamic var memo: String = ""
    // 医療用フラグ
    @objc dynamic var medicalFlg: Bool = false
    
    override class func primaryKey() -> String? {
        return "drugName"
    }
}

extension Bookmark {
    
    // INSERT処理
    class func insert(drugName: String, sgmlURL: String, kubun: String, detail: String, medicalFlg: Bool) {

        let bookmark = Bookmark()
        bookmark.drugName = drugName
        bookmark.sgmlURL = sgmlURL
        bookmark.kubun = kubun
        bookmark.detail = detail
        bookmark.medicalFlg = medicalFlg
        
        let realm = try! Realm()
        try! realm.write{
            realm.add(bookmark, update: .all)
        }
    }

    // DELETE処理
    class func delete(drugName: String, sgmlURL: String) {
        
        let realm = try! Realm()
        try! realm.write{
            let delete = realm.objects(Bookmark.self).filter("drugName = '\(drugName)' AND sgmlURL = '\(sgmlURL)'")
            realm.delete(delete)
        }
    }

    // レコード抽出(全件)
    // SELECT * FROM Bookmark
    // ORDER BY addDate DESC
    class func selectAll() -> Results<Bookmark> {

        let realm = try! Realm()
        let select = realm.objects(Bookmark.self).sorted(byKeyPath: "addDate", ascending: false)
        return select
    }
    
    // レコード抽出(キー：医薬品名、処方薬フラグ)
    // SELECT * FROM Bookmark
    // WHERE drugName = /(drugName) AND medicalFlg = medicalFlg
    // ORDER BY addDate DESC
    class func selectByName(drugName: String, medicalFlg: Bool) -> Results<Bookmark> {
        
        // 囲い文字のエスケープ
        var escapedString = drugName
        escapedString = escapedString.replacingOccurrences(of: "\\", with: "\\\\")
        escapedString = escapedString.replacingOccurrences(of: "'", with: "\\'")
        
        // 抽出する
        let realm = try! Realm()
        let select = realm.objects(Bookmark.self).filter("drugName = '\(escapedString)' AND medicalFlg = \(medicalFlg)").sorted(byKeyPath: "addDate", ascending: false)
        return select
    }
    
    // レコード抽出(キー：医薬品名、URL)
    // SELECT * FROM Bookmark
    // WHERE drugName = /(drugName) AND sgmlURL = \(sgmlURL)
    // ORDER BY addDate DESC
    class func selectByNameAndUrl(drugName: String, sgmlURL: String) -> Results<Bookmark> {
        
        // 囲い文字のエスケープ
        var escapedString1 = drugName
        escapedString1 = escapedString1.replacingOccurrences(of: "\\", with: "\\\\")
        escapedString1 = escapedString1.replacingOccurrences(of: "'", with: "\\'")
        
        // 囲い文字のエスケープ
        var escapedString2 = sgmlURL
        escapedString2 = escapedString2.replacingOccurrences(of: "\\", with: "\\\\")
        escapedString2 = escapedString2.replacingOccurrences(of: "'", with: "\\'")
        
        // 抽出する
        let realm = try! Realm()
        let select = realm.objects(Bookmark.self).filter("drugName = '\(escapedString1)' AND sgmlURL = '\(escapedString2)'").sorted(byKeyPath: "addDate", ascending: false)
        return select
    }
    
    // レコード抽出(部分一致)(キー：医薬品名)
    // SELECT * FROM Bookmark
    // WHERE drugName LIKE \(drugName)
    
    class func selectLikeByName(drugName: String) -> Results<Bookmark> {
        
        // 囲い文字のエスケープ
        var escapedString = drugName
        escapedString = escapedString.replacingOccurrences(of: "\\", with: "\\\\")
        escapedString = escapedString.replacingOccurrences(of: "'", with: "\\'")
        
        // 抽出する
        let realm = try! Realm()
        let select = realm.objects(Bookmark.self).filter("drugName CONTAINS '\(escapedString)'").sorted(byKeyPath: "addDate", ascending: false)
        return select
    }
}
