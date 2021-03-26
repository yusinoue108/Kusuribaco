//
//  BookMarkTableViewCell.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/02/12.
//

import UIKit
import RealmSwift

class BookMarkTableViewCell: UITableViewCell {
    
    @IBOutlet weak var drugNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var addDateLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true
        backgroundColor = .systemGray6
        
        // 市販薬名
        drugNameLabel.setTextAndKaigyo(text: "", fontSize: 22.0, boldFont: true, allowKaigyo: true)

        // 製造販売元
        detailLabel.setTextAndKaigyo(text: "", fontSize: 14.0, boldFont: false, allowKaigyo: true)
        detailLabel.textColor = .gray
        detailLabel.adjustsFontSizeToFitWidth = true
        
        // 追加日
        addDateLabel.setTextAndKaigyo(text: "", fontSize: 12.0, boldFont: false, allowKaigyo: true)
        addDateLabel.numberOfLines = 1
        addDateLabel.textColor = .gray
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    // セルをセットする
    func setCell(bookmark: Results<Bookmark>!, index: Int) {
        
        // 市販薬名
        drugNameLabel.text = bookmark[index].drugName
        
        // 追加日
        let date = convertDate(date: bookmark[index].addDate)
        addDateLabel.text  = "追加日：\(date)"
        
        // 販売会社
        detailLabel.text = String(bookmark[index].detail.components(separatedBy: "医薬品区分")[0].dropLast())
        
    }
    
    // 日付変換用
    func convertDate(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        let dateString = dateFormatter.string(from: date)
        
        return dateString
    }

}
