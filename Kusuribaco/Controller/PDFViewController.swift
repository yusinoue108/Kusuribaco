//
//  PDFViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import XLPagerTabStrip
import PDFKit

class PDFViewController: UIViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "PDF"
    var URLString: String = ""
    var pdfView: PDFView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pdfView.frame = view.frame
        view.addSubview(pdfView)

        // AutoLayoutを設定する
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pdfView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pdfView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pdfView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        // PDFViewの設定をする
        pdfView.backgroundColor = .myGray()
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        
        // PDFを表示する
        let url = URL(string: URLString)
        pdfView.document = PDFDocument(url: url!)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
}
