//
//  SearchViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import PKHUD
import Reachability
import DZNEmptyDataSet

enum searchKubun {
    case medical
    case otc
}

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var resultData = ResultData()
    let reachability = try! Reachability()
    var searchFlg = Int()
    var searchKubun: searchKubun?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの背景色
        view.backgroundColor = .myGray()

        // Titleの設定
        switch searchKubun {
        case .medical: self.navigationItem.title = "医療用医薬品の検索"
        case .otc: self.navigationItem.title = "一般用医薬品の検索"
        case .none: self.navigationItem.title = ""
        }
        self.navigationController?.navigationBar.barTintColor = .systemTeal
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        // SearchBarの設定
        searchBar.placeholder = "薬の名前で検索する"
        searchBar.delegate = self
        
        // TableViewの設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate  = self
        tableView.emptyDataSetSource = self
        
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        
        //行の高さを可変に設定
        tableView.rowHeight = UITableView.automaticDimension
        //見積もりの高さ
        tableView.estimatedRowHeight = 75
        
        // TapGestureRecognizerの設定
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGR)
        
        // 通信状態の監視
        try? reachability.startNotifier()
        
        // EmptyState設定
        searchFlg = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if resultData.drugArray.count == 0 {
            return
        }
        
        for index in 0...(resultData.drugArray.count - 1) {
            
            // ブックマークフラグを振り直す
            let drugName = resultData.drugArray[index]
            
            switch searchKubun {
            case .medical:
                if Bookmark.selectByName(drugName: drugName, medicalFlg: true).count > 0 {
                    resultData.bookmarkArray[index] = "1"
                } else {
                    resultData.bookmarkArray[index] = "0"
                }
            case .otc:
                if Bookmark.selectByName(drugName: drugName, medicalFlg: false).count > 0 {
                    resultData.bookmarkArray[index] = "1"
                } else {
                    resultData.bookmarkArray[index] = "0"
                }
            case .none:
                return
            }
            
            // 再読み込みする
            tableView.reloadData()
        }
        
    }
    
    // タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    // タッチでキーボードを閉じる
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    
    // 検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        var drugNameString = String()
        var encodedString = String()
        let urlEncoding = URLEncoding()
        
        // 初期化
        resultData = ResultData()
        
        // インジゲーターを表示する
        HUD.show(.progress)
        
        // 通信状態チェック
        if !network.checkReachability(reachability: reachability, view: view, alart: false) {
            searchBar.resignFirstResponder()
            searchFlg = 2
            HUD.hide()
            tableView.reloadData()
            return
        }
        
        // 検索ワード
        drugNameString = searchBar.text!
        
        // 検索結果を取得し、セルを構築していく
        switch searchKubun {
        // 処方薬検索の場合
        case .medical:
            
            // 検索用語をURLエンコーディングする
            encodedString = urlEncoding.utf8PercentEncoding(URLString: drugNameString)
            
            // 検索用語を更新する
            let medicalRequestData = MedicalRequestData()
            medicalRequestData.searchText = encodedString
            
            // 検索結果を取得する
            HTTPRequest.searchMedicalDrug(postRequestData: medicalRequestData) { (result) in
                
                self.resultData = result
                
                // 検索結果の件数を確認する
                if self.resultData.drugArray.count == 0 {
                    self.tableView.separatorStyle = .none
                    self.searchFlg = 3
                }
                
                DispatchQueue.main.async {
                    // セルを構築していく
                    self.tableView.reloadData()
                    // インジケーターを終了する
                    HUD.hide()
                    // キーボードを閉じる
                    self.searchBar.resignFirstResponder()
                }
            }
            return
        // 市販薬検索の場合
        case .otc:
            
            // 検索用語をURLエンコーディングする
            encodedString = urlEncoding.eucjpPercentEncoding(URLString: drugNameString)
            
            // 検索用語を更新する
            let otcRequestData = OtcRequestData()
            otcRequestData.searchText = encodedString
            
            // 検索結果を取得する
            HTTPRequest.searchOtcDrug(postRequestData: otcRequestData) { (result) in
                
                self.resultData = result
                
                // 検索結果の件数を確認する
                if self.resultData.drugArray.count == 0 {
                    self.tableView.separatorStyle = .none
                    self.searchFlg = 3
                }
                
                DispatchQueue.main.async {
                    // セルを構築していく
                    self.tableView.reloadData()
                    // インジケーターを終了する
                    HUD.hide()
                    // キーボードを閉じる
                    self.searchBar.resignFirstResponder()
                }
            }
            return
            
        case .none:
            return
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // キーボードを閉じる
        searchBar.resignFirstResponder()
        
        // セルの選択を解除する
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 通信状態チェック
        if !network.checkReachability(reachability: reachability, view: view, alart: true) {
            return
        }
        
        // インジゲーターを表示する
        HUD.show(.progress)
        
        // リクエスト先のURLを更新する
        let pdfRequestData = PdfRequestData()
        pdfRequestData.url = resultData.URLArray[indexPath.row]
        
        // PDFのリンク先を取得して画面遷移する
        HTTPRequest.getPdfURL(requestData: pdfRequestData, kubun: searchKubun!, completion: { (result) in

            let drugNameString = self.resultData.drugArray[indexPath.row]
            let kubunString = self.resultData.kubunArray[indexPath.row]
            let detailString = self.resultData.detailArray[indexPath.row]
            let sgmlURLString = self.resultData.URLArray[indexPath.row]
            let pdfURLString = result
            
            DispatchQueue.main.async {
                // インジケーターを終了する
                HUD.hide()
                // 画面遷移する
                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                detailVC.drugNameString = drugNameString
                detailVC.kubunString = kubunString
                detailVC.detailString = detailString
                detailVC.sgmlURLString = sgmlURLString
                detailVC.pdfURLString = pdfURLString
                
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        })
    }
    // セクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultData.drugArray.count
    }
    
    // セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath ) as! SearchTableViewCell
                
        // ブックマークボタンクリック時の処理
        cell.bookmarkButton.addTarget(self, action: #selector(pushButton), for: .touchUpInside)
        cell.bookmarkButton.tag = indexPath.row

        // セルに値を格納していく
        if resultData.drugArray.count > 0 {
            cell.setCell(resultData: resultData, index: indexPath.row)
        }
        return cell
    }
    
    // Bookmarkボタンをクリックした時
    @objc private func pushButton(_ sender: UIButton) {
        
        let row = sender.tag
        let drugName = resultData.drugArray[row]
        let sgmlURL = resultData.URLArray[row]
        let kubun = resultData.kubunArray[row]
        let detail = resultData.detailArray[row]
        
        if resultData.bookmarkArray[row] == "1" {
            // ブックマークから削除
            sender.tintColor = .lightGray
            resultData.bookmarkArray[row] = "0"
            let drugName = resultData.drugArray[row]
            let sgmlURL = resultData.URLArray[row]
            Bookmark.delete(drugName: drugName, sgmlURL: sgmlURL)
            if Note.countByName(drugName: drugName) > 0 {
                Note.delete(drugName: drugName, tergetOld: false)
            }
            
        } else {
            // ブックマークに追加
            sender.tintColor = .systemYellow
            resultData.bookmarkArray[row] = "1"
            
            switch searchKubun {
            case .medical:
                Bookmark.insert(drugName: drugName, sgmlURL: sgmlURL, kubun: kubun, detail: detail, medicalFlg: true)
            case .otc:
                Bookmark.insert(drugName: drugName, sgmlURL: sgmlURL, kubun: kubun, detail: detail, medicalFlg: false)
            case .none:
                HUD.hide()
                return
            }
            
            HUD.flash(.labeledSuccess(title: "", subtitle: "保存しました"), delay: 0.5)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let marginView = UIView()
        marginView.backgroundColor = .clear
        return marginView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

// MARK: -  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension SearchViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        scrollView.bounds.origin.y = 0
    }
    // 背景色
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .myGray()
    }
    
    // タイトル
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var titleString = String()
        switch searchFlg {
        case 1:
            switch searchKubun {
            case .medical: titleString = "医療用医薬品を検索する"
            case .otc: titleString = "一般用医薬品を検索する"
            case .none: titleString = ""
            }
        case 2: titleString = "インターネット接続がありません"
        case 3: titleString = "検索結果が0件あるいは1000件以上でした"
        default: titleString = ""
        }
        
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 20)
        ]
        
        return NSAttributedString(string: titleString, attributes: stringAttributes)
    }
    
    // 説明
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        var descriptionString = String()
        switch searchFlg {
        case 1:
            switch searchKubun {
            case .medical: descriptionString = "病院やクリニックで処方される\n薬を検索します"
            case .otc: descriptionString = "薬局やドラッグストアで買える\n薬を検索します"
            case .none: descriptionString = ""
            }
        case 2: descriptionString = "良好な通信環境でもう一度お試しください"
        case 3: descriptionString = "検索ワードを変えてもう一度お試しください\n(例1) \"ろきそにん\" → \"ロキソニン\"\n(例2) \"ロ\" → \"ロキソ\""
        default: descriptionString = ""
        }

        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 15)
        ]
        return NSAttributedString(string: descriptionString, attributes: stringAttributes)
    }
 
    // 画像
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        var imageString = String()
        switch searchFlg {
        case 1: imageString = "SearchImage"
        case 2: imageString = "NetworkImage"
        case 3: imageString = "NoResultImage"
        default: imageString = "SearchImage"
        }
        return UIImage(named: imageString)?.resized(width: 60)
    }
    
    // 画像の色
    func imageTintColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .lightGray
    }
    
    // 画像の位置
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -80
    }
}
