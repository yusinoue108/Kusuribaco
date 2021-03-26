//
//  NoteEditViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/02/23.
//

import UIKit
import PKHUD

protocol noteProtocol {
    func setTextViewContent(noteText: String)
}

enum textViewState {
    case editing
    case saved
}

class NoteEditViewController: UIViewController {

    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var drugNameString: String = ""
    var noteString: String = ""
    var delegate: noteProtocol?
    var textViewState: textViewState?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景色
        view.backgroundColor = .myGray()
        subView.backgroundColor = .clear
        
        // textView
        textView.setBackColorAndCornerAndPadding(backgroundColor: .myGray(), cornerRadius: 10, padding: 15)
        textView.setTextAndPlaceholder(text: noteString, placeholder: "メモを書く...", fontSize: 18, editable: true, scrollable: true)
        textView.setShadow()
        textView.startEditig()
        
        // 編集状態
        textViewState = .editing
        
        // 編集・保存ボタン
        editButton.setText(text: "保存", color: .white, size: 20.0, boldFont: true)
        editButton.setBackColorAndCorner(backgroundColor: .systemTeal, cornerRadius: 15.0)
        
        // 戻るボタン
        backButton.setText(text: "戻る", color: .systemTeal, size: 20.0, boldFont: true)
        backButton.setBackColorAndCorner(backgroundColor: .clear, cornerRadius: 15.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DetailViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    @IBAction func doEditing(_ sender: Any) {
        
        switch textViewState {
        case .editing:
            
            // DBを更新する
            if let note = textView.text {
                Note.insert(drugName: drugNameString, note: note)
                HUD.flash(.labeledSuccess(title: "", subtitle: "保存しました"), delay: 0.5)
                delegate?.setTextViewContent(noteText: note)
            }
            
            textViewState = .saved
            textView.endEditig()
            editButton.setTitle("編集", for: .normal)
            
        case .saved:
            
            textViewState = .editing
            textView.startEditig()
            editButton.setTitle("保存", for: .normal)
            
        case .none:
            return
        }
    }
    
    @IBAction func back(_ sender: Any) {
        
        switch textViewState {
        
        case .editing:
            showAlart(title: "編集中の内容があります。", message: "(編集中の内容は保存されません)") { (bool) in

                if bool {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    return
                }
            }
            
        case .saved:
            dismiss(animated: true, completion: nil)
            
        case .none:
            return
            
        }
    
    }
    
    // キーボードが表示された時
    @objc func keyboardWillShow(_ notification: NSNotification){
        
        // キーボードの高さを取得する
        let keyboardHeight: CGFloat = ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        // Bottomの制約に反映する
        bottomConstraint.constant = keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    // キーボードが非表示になった時
    @objc func keyboardWillHide(_ notification: NSNotification){
        
        // Bottomの制約に反映する
        bottomConstraint.constant = 10
        self.view.layoutIfNeeded()

    }
    
}
