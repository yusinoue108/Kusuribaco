//
//  NoteViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import WebKit
import PDFKit

class NoteViewController: UIViewController {

    @IBOutlet weak var drugNameLabel: UILabel!
    @IBOutlet weak var kubunLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var sgmlView: UIView!
    @IBOutlet weak var drugDetailSubView: UIView!
    @IBOutlet weak var drugNameSubView: UIView!
    @IBOutlet weak var horizontalScrollView: UIScrollView!
    @IBOutlet weak var horizontalContainerSubView: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    var drugNameString: String = ""
    var kubunString: String = ""
    var detailString: String = ""
    var noteString: String = ""
    var sgmlURLString: String = ""
    var pdfURLString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .myGray()
        drugNameSubView.setShadow()
        drugDetailSubView.setShadow()
        horizontalContainerSubView.setShadow()
        horizontalScrollView.layer.cornerRadius = 10.0
        
        // 医薬品名ラベル
        drugNameLabel.setTextAndKaigyo(text: drugNameString,fontSize: 30.0, boldFont: true,  allowKaigyo: true)
        
        // 区分ラベル
        kubunLabel.setTextAndKaigyo(text: kubunString,fontSize: 22.0, boldFont: false, allowKaigyo: true)
        
        // 詳細ラベル
        detailLabel.setTextAndKaigyo(text: String(detailString.dropLast()),fontSize: 22.0, boldFont: false, allowKaigyo: true)
        
        // TextView
        noteTextView.setBackColorAndCornerAndPadding(backgroundColor: .myGray(), cornerRadius: 10.0, padding: 15.0)
        noteTextView.setTextAndPlaceholder(text: noteString, placeholder: "メモを書く...", fontSize: 15, editable: false, scrollable: true)
        
        // WebViewを設定する
        let webView =   WKWebView()
        webView.frame = CGRect(x: 0, y: 0, width: self.sgmlView.frame.size.width, height: self.sgmlView.frame.size.height)
        webView.allowsLinkPreview = false
        webView.layer.cornerRadius = 10.0
        sgmlView.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.centerXAnchor.constraint(equalTo: self.sgmlView.centerXAnchor).isActive = true
        webView.centerYAnchor.constraint(equalTo: self.sgmlView.centerYAnchor).isActive = true
        webView.widthAnchor.constraint(equalTo: self.sgmlView.widthAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: self.sgmlView.heightAnchor).isActive = true

        let sgmlURL = URL(string: sgmlURLString)
        let request = URLRequest(url:sgmlURL!)
        webView.load(request)
        
        // PDFViewを設定する
        let pdfView = PDFView()
        pdfView.frame = self.pdfView.frame
        pdfView.layer.cornerRadius = 10.0
        pdfView.backgroundColor = .white
        self.pdfView.addSubview(pdfView)
        
        // AutoLayoutを設定する
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.centerXAnchor.constraint(equalTo: self.pdfView.centerXAnchor).isActive = true
        pdfView.centerYAnchor.constraint(equalTo: self.pdfView.centerYAnchor).isActive = true
        pdfView.widthAnchor.constraint(equalTo: self.pdfView.widthAnchor).isActive = true
        pdfView.heightAnchor.constraint(equalTo: self.pdfView.heightAnchor).isActive = true
        
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        let pdfURL = URL(string: pdfURLString)
        pdfView.document = PDFDocument(url: pdfURL!)
        
        // 編集ボタンを設定する
        let editImage = UIImage(named: "EditIcon")!.resized(width: 30)
        editImage?.withTintColor(.white)
        editButton.setImage(editImage, for: .normal)
    }
    
    @IBAction func doEditing(_ sender: Any) {
        performSegue(withIdentifier: "NoteEditVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let noteEditVC: NoteEditViewController = segue.destination as! NoteEditViewController
        noteEditVC.drugNameString = drugNameString
        noteEditVC.noteString = noteTextView.text
        noteEditVC.delegate = self
    }
}

// MARK: - noteProtocol
extension NoteViewController: noteProtocol {
    
    func setTextViewContent(noteText: String) {
        noteTextView.text = noteText
    }
}
