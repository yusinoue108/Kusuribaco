//
//  Extentions.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/02/16.
//

import Foundation
import UIKit


// MARK: - UIView
extension UIView {
    
    func setShadow() {
        
        backgroundColor = .white
        layer.cornerRadius = 10.0
        layer.shadowColor = UIColor.black.cgColor              // 影の色
        layer.shadowOpacity = 0.25                             // 影の濃さ
        layer.shadowRadius = 4                                 // 影のぼかし
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)   // 影の方向
    }

}

// MARK: - UISearchBar
extension UISearchBar {
    
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return searchTextField
        } else {
            return value(forKey: "_searchField") as? UITextField
        }
    }
}

// MARK: - UILabel
extension UILabel {
    
    // テキスト、フォント、改行の設定をする
    func setTextAndKaigyo(text textString: String, fontSize: CGFloat, boldFont: Bool, allowKaigyo: Bool) {
        
        text = textString
        
        if boldFont {
            font = .boldSystemFont(ofSize: fontSize)
        } else {
            font = .systemFont(ofSize: fontSize)
        }
    
        if allowKaigyo {
            numberOfLines = 0
            sizeToFit()
            lineBreakMode = NSLineBreakMode.byCharWrapping
        }
    }
}

// MARK: - UIImage
extension UIImage {
    
    // Imageを横幅に合わせてリサイズする
    func resized(width: CGFloat) -> UIImage? {
        
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let inRect: CGRect = CGRect(origin: .zero, size: canvasSize)
        draw(in: inRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

// MARK: - UITextView
import UITextView_Placeholder
extension UITextView {
    
    // 背景色と角丸と余白をセットする
    func setBackColorAndCornerAndPadding(backgroundColor color: UIColor, cornerRadius: CGFloat, padding: CGFloat) {
        
        backgroundColor = color
        layer.cornerRadius = cornerRadius
        textContainer.lineFragmentPadding = padding
    }
    
    
    // textとplaceholderをセットする
    func setTextAndPlaceholder(text textString: String, placeholder placeholderString: String, fontSize: CGFloat, editable: Bool, scrollable: Bool) {
        
        text = textString
        font = .systemFont(ofSize: fontSize)
        placeholder = placeholderString
        placeholderColor = .lightGray
        isScrollEnabled = scrollable
        isEditable = editable
    }
    
    // 枠線をセットする
    func setBorder() {
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // textViewの編集を開始する
    func startEditig() {
        
        isEditable = true
        isSelectable = true
        becomeFirstResponder()
    }
    
    // textViewの編集を終了する
    func endEditig() {
        
        isEditable = false
        isSelectable = false
        resignFirstResponder()
    }
}

// MARK: - UIColor
extension UIColor {
    
    // 背景色で使うグレー
    class func myGray() -> UIColor {
        let myGray = UIColor.init(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1)
        return myGray
    }
    
}

// MARK: - UIButton
extension UIButton {

    // 背景色と角丸をセットする
    func setBackColorAndCorner(backgroundColor color: UIColor, cornerRadius: CGFloat) {
        
        backgroundColor = color
        layer.cornerRadius = cornerRadius
    }

    // タイトルをセットする
    func setText(text textString: String, color: UIColor, size: CGFloat, boldFont: Bool) {
        
        setTitle(textString, for: .normal)
        setTitleColor(color, for: .normal)
        
        if boldFont {
            titleLabel?.font = UIFont.boldSystemFont(ofSize: size)
        } else {
            titleLabel?.font = UIFont.systemFont(ofSize: size)
        }
    }
    
    // 枠線をセットする
    func setBorder() {
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.lightGray.cgColor
    }
}

// MARK: - UIViewController
extension UIViewController {
    
    // アラートを表示する
    func showAlart(title: String, message: String, completion: @escaping (Bool) -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKの場合、TRUEを返す
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            completion(true)
        }
        
        // キャンセルの場合、FALSEを返す
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            completion(false)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - URL
extension URL {
    
    // URLが有効か確認する
    func isReachable(completion: @escaping (Bool) -> ()) {
        
        var request = URLRequest(url: self)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
}
