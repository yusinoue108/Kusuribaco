//
//  DetailViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import XLPagerTabStrip
import PKHUD

class DetailViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonHeightConstraint: NSLayoutConstraint!
    
    var drugNameString: String = ""
    var kubunString: String = ""
    var detailString: String = ""
    var addDate: Date = Date()
    var sgmlURLString: String = ""
    var pdfURLString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 背景色
        view.backgroundColor = .myGray()
        subView.backgroundColor = .white
    
        // TextView
        textView.backgroundColor = .myGray()
        textView.setBackColorAndCornerAndPadding(backgroundColor: .myGray(), cornerRadius: 10.0, padding: 15)
        textView.setTextAndPlaceholder(text: "", placeholder: "メモをする", fontSize: 16.0, editable: true, scrollable: true)
        textView.setBorder()
        textViewHeightConstraint.constant = getTextViewHeight(width: textView.frame.size.width, text: "")
        textView.delegate = self

        // textViewの初期値を設定する
        if Note.countByName(drugName: drugNameString) > 0 {
            let note = Note.selectNoteByName(drugName: drugNameString)
            textView.text = note
        }
        
        // 保存ボタン
        saveButton.setBackColorAndCorner(backgroundColor: .orange, cornerRadius: 7.0)
        saveButton.setText(text: "保存", color: .white, size: 16.0, boldFont: false)
        saveButton.setBorder()
        saveButtonHeightConstraint.constant = textViewHeightConstraint.constant
        
        // キーボード設定
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // saveButtonクリック時
        saveButton.addTarget(self, action: #selector(DetailViewController.saveNote(sender: )), for: .touchUpInside)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        
        // キーボードの高さを取得する
        let keyboardHeight: CGFloat = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        // タブバーの高さを取得する
        let tabBarHeight = (tabBarController?.tabBar.frame.size.height)!
        
        // Bottomの制約に反映する
        bottomConstraint.constant = keyboardHeight - tabBarHeight

        // 最小のtextViewの高さ
        let minTextViewHeight:CGFloat = getTextViewHeight(width: textView.frame.size.width, text: "")
        
        // 最大のtextView高さ(フォントサイズ16ptの場合の4行分)
        let maxTextViewHeight: CGFloat = 93
        
        // リサイズ後のtextViewの高さ
        let resizedTextViewHeight = getTextViewHeight(width: textView.frame.size.width, text: textView.text)
        
        // textVIewの高さを反映する
        if resizedTextViewHeight > minTextViewHeight && resizedTextViewHeight <= maxTextViewHeight {
            // 最小〜最大の時
            textViewHeightConstraint.constant = resizedTextViewHeight
        } else if resizedTextViewHeight > maxTextViewHeight {
            // 最大の以上の時
            textViewHeightConstraint.constant = maxTextViewHeight
            textView.isScrollEnabled = true
        }

        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
                
        // デフォルトのtextViewの高さに戻す
        textViewHeightConstraint.constant = getTextViewHeight(width: textView.frame.size.width, text: "")
        
        // スクロールさせる
        textView.isScrollEnabled = true
        
        // Bottomの制約に反映する
        bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
        
    }
    
    @objc func saveNote(sender: Any) {
        
        // ブックマークに登録されていなかったら追加する
        if Bookmark.selectByNameAndUrl(drugName: drugNameString, sgmlURL: sgmlURLString).count == 0 {
            
            let drugName = drugNameString
            let sgmlURL = sgmlURLString
            let kubun = kubunString
            let detail = detailString
            Bookmark.insert(drugName: drugName, sgmlURL: sgmlURL, kubun: kubun, detail: detail, medicalFlg: false)
        }
        
        // Noteを追加する
        let note: String = textView.text
        Note.insert(drugName: drugNameString, note: note)
        
        HUD.flash(.labeledSuccess(title: "", subtitle: "保存しました"), delay: 0.5)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
      
        settings.style.buttonBarBackgroundColor = UIColor.lightGray
        settings.style.buttonBarItemBackgroundColor = UIColor.lightGray
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 15)
        settings.style.selectedBarBackgroundColor = .orange
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let pdfVC = storyboard.instantiateViewController(withIdentifier: "PDFViewController") as! PDFViewController
        pdfVC.URLString = pdfURLString
        
        let sgmlVC = storyboard.instantiateViewController(withIdentifier: "SGMLViewController") as! SGMLViewController
        sgmlVC.URLString = sgmlURLString
        
        let childViewControllers:[UIViewController] = [pdfVC, sgmlVC]
        return childViewControllers
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - UITextViewDelegate

extension DetailViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
   
        // 最大のtextView高さ
        let maxTextViewHeight: CGFloat = 93
        let resizedTextViewHeight:CGFloat = getTextViewHeight(width: textView.frame.size.width, text: textView.text)
        
        // 高さに変更がない場合
        if resizedTextViewHeight == textViewHeightConstraint.constant {
            return
        }
    
        if resizedTextViewHeight > maxTextViewHeight {
            
            textViewHeightConstraint.constant = maxTextViewHeight
            textView.isScrollEnabled = true
        } else {
            
            textViewHeightConstraint.constant = resizedTextViewHeight
            textView.isScrollEnabled = false
        }
        
         self.view.layoutIfNeeded()
    }
    
    // 入力内容に応じたtextViewの高さを返す
    func getTextViewHeight(width : CGFloat, text: String) -> CGFloat {
        
        var textViewHeight: CGFloat = 0
        
        let _textView = UITextView()
        _textView.setTextAndPlaceholder(text: text, placeholder: "メモを書く", fontSize: 16.0, editable: false, scrollable: false)
        _textView.sizeToFit()
        textViewHeight = _textView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height
        
        return textViewHeight
    }
}

