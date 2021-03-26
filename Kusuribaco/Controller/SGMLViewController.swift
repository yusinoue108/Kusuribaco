//
//  SGMLViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import WebKit
import PKHUD
import Reachability
import XLPagerTabStrip

class SGMLViewController: UIViewController, IndicatorInfoProvider {

    var itemInfo: IndicatorInfo = "SGML"
    var URLString: String = ""
    var webView: WKWebView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.frame
        view.addSubview(webView)
        
        // AutoLayoutを設定する
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        webView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        webView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        // WebViewの設定をする
        webView.backgroundColor = .myGray()
        webView.allowsLinkPreview = false
        view.addSubview(webView)
        
        // ページを表示する
        let reachability = try! Reachability()
        if network.checkReachability(reachability: reachability, view: view, alart: true) {
            
            let url = URL(string: URLString)
            let request = URLRequest(url:url!)
            webView.load(request)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
}

// MARK: - WKNavigationDelegate
extension SGMLViewController: WKNavigationDelegate {

    // ロード開始
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // インジゲーターを表示する
        HUD.show(.progress)
    }

    // ロード完了
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // インジケーターを終了する
        HUD.hide()
    }

}
