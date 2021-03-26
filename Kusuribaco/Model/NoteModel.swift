//
//  Note.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import Foundation
import RealmSwift

class Note: Object{

    // 医薬品名
    @objc dynamic var drugName: String = ""
    // メモ
    @objc dynamic var note: String = ""
    // 更新日
    @objc dynamic var updDate: Date = Date()
    
    override class func primaryKey() -> String? {
        return "drugName"
    }
}

extension Note {
    
    // INSERT/UPDATE処理
    class func insert(drugName: String, note noteString: String){

        let note = Note()
        note.drugName = drugName
        note.note = noteString
        note.updDate = Date()

        let realm = try! Realm()
        try! realm.write{
            realm.add(note, update: .all)
        }
    }

    // DELETE処理
    class func delete(drugName: String, tergetOld: Bool){

        let realm = try! Realm()
        try! realm.write{
            let delete = realm.objects(Note.self).filter("drugName = '\(drugName)'")
            if tergetOld {
                realm.delete(delete)
            } else {
                realm.delete(delete[0])
            }
            
        }
    }
    
    // レコード件数チェック
    // SELECT count(*) FROM Note
    // WHERE drugName = \(drugName)
    class func countByName(drugName: String) -> Int {

        let realm = try! Realm()
        let count = realm.objects(Note.self).filter("drugName = '\(drugName)'").count
        return count
    }

    // メモの内容を抽出する
    // SELECT note FROM Note
    // WHERE drugName = \(drugName)
    class func selectNoteByName(drugName: String) -> String {

        let realm = try! Realm()
        let select = realm.objects(Note.self).filter("drugName = '\(drugName)'")
        return select.first!.note
    }
}
