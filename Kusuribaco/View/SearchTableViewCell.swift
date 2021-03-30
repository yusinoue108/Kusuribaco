//
//  SearchTableViewCell.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/25.
//

import UIKit

protocol SearchCellDelegete {
    func reloadCell(index: IndexPath)
}

class SearchTableViewCell: UITableViewCell {

   // @IBOutlet weak var shadowLayer: ShadowView!
    
    @IBOutlet weak var drugNameLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    var index: IndexPath!
    
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
        
        // ブックマークボタン
        let buttomImage = UIImage(named: "BookmarkButton")?.withRenderingMode(.alwaysTemplate)
        bookmarkButton.setImage(buttomImage, for: .normal)
        bookmarkButton.imageView?.contentMode = .scaleAspectFit
        bookmarkButton.contentHorizontalAlignment = .fill
        bookmarkButton.contentVerticalAlignment = .fill
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // セルをセットする
    func setCell(resultData: ResultData ,index: Int) {
        
        // 市販薬名
        drugNameLabel.text = resultData.drugArray[index]
        
        // 販売会社
        let detailString: String = resultData.detailArray[index]
        if detailString.contains("\n医薬品区分") {
            detailLabel.text = detailString.components(separatedBy: "\n医薬品区分")[0]
        } else {
            detailLabel.text = detailString
        }
        
        // ブックマークの状態設定
        if resultData.bookmarkArray[index] == "1" {
            bookmarkButton.tintColor = .systemYellow
        } else {
            bookmarkButton.tintColor = .lightGray
        }
    }
    
}
