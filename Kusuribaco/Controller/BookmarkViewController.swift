//
//  BookmarkViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit
import Reachability
import DZNEmptyDataSet
import RealmSwift
import DropDown
import PKHUD

class BookmarkViewController: UIViewController {
 
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var sortButton: UIBarButtonItem!
    
    let sortDropDown: DropDown = DropDown()
    var selectedIndex: Int = 0
    var bookmark: Results<Bookmark>!
    let reachability: Reachability = try! Reachability()
    var searchFlg: Int = 0
    var searchKubun: searchKubun = .medical
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Viewの背景色
        view.backgroundColor = .myGray()

        // Titleの設定
        self.navigationItem.title = "ブックマーク"
        self.navigationController?.navigationBar.barTintColor = .systemTeal
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        // SearchBarの設定
        searchBar.delegate = self
        searchBar.placeholder = "薬の名前で絞る"
        searchBar.searchTextField.enablesReturnKeyAutomatically = false
        
        // TableViewの設定
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetDelegate  = self
        tableView.emptyDataSetSource = self

        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UINib(nibName: "BookMarkTableViewCell", bundle: nil), forCellReuseIdentifier: "BookMarkTableViewCell")
        
        //行の高さを可変に設定
        tableView.rowHeight = UITableView.automaticDimension
        //見積もりの高さ
        tableView.estimatedRowHeight = 75

        // TapGestureRecognizerの設定
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGR.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGR)
        
        // RefreshControlの設定
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:  #selector(refreshTable(_:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        // DropDownの設定
        let sortImage = UIImage(named: "SortIcon")?.resized(width: 25)
        sortButton = UIBarButtonItem(image: sortImage, style: .done, target: self, action: #selector(sortButtonTapped(_:)))
        sortDropDown.anchorView = sortButton
        sortDropDown.dataSource = ["追加日(新しい順)", "追加日(古い順)", "名前(アイウエオ順)"]
        sortDropDown.backgroundColor = .white
        sortDropDown.direction = .bottom
        sortDropDown.textColor = .black
        sortDropDown.cornerRadius = 8.0
        sortDropDown.separatorColor = .black
        
        // ドロップダウン選択時
        sortDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            // インジケーターを表示する
            HUD.show(.progress)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // 選択内容を保持する
                selectedIndex = index
                
                // ソートする
                switch index {
                case 0:
                    // 追加日(新しい順)
                    bookmark = bookmark.sorted(byKeyPath: "addDate", ascending: false)
                case 1:
                    // 追加日(古い順)
                    bookmark = bookmark.sorted(byKeyPath: "addDate", ascending: true)
                case 2:
                    // 名前
                    bookmark = bookmark.sorted(byKeyPath: "drugName", ascending: true)
                default:
                    bookmark = bookmark.sorted(byKeyPath: "addDate", ascending: false)
                }
                
                if bookmark.count == 0 {
                    searchFlg = 1
                }
                
                // セルを構築する
                tableView.reloadData()
                
                // インジケーターを終了する
                HUD.hide()
                
                // キーボードを閉じる
                searchBar.resignFirstResponder()
            }
        }
        
        // 通信状態の監視
        try? reachability.startNotifier()
        
        self.navigationItem.rightBarButtonItems = [sortButton]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        // ブックマークを全件取得する
        bookmark = Bookmark.selectAll()
        
        if bookmark.count == 0 {
            searchFlg = 1
        }
        
        // ソートの選択状態を初期化する
        selectedIndex = 0
        
        // SearchBarを初期化する
        searchBar.text = ""
        
        // セルを構築する
        tableView.reloadData()
    }
    
    // タッチでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.endEditing(true)
    }
    
    // タッチでキーボードを閉じる
    @objc func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    // ソートアイコンをクリックした時
    @objc func sortButtonTapped(_ sender: UIBarButtonItem) {
        // ドロップダウンを表示する
        sortDropDown.selectRow(at: selectedIndex)
        sortDropDown.show()
    }
    
    @objc func refreshTable(_ sender: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // seaechBarを初期化する
            self.searchBar.text = ""
            
            // Tableのデータを初期化する
            self.bookmark = Bookmark.selectAll()
            
            if self.bookmark.count == 0 {
                self.searchFlg = 1
            }
            
            // ソートの状態を初期化する
            self.selectedIndex = 0
            
            self.tableView.reloadData()
            // インジケーターを終了する
            sender.endRefreshing()
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmark.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookMarkTableViewCell", for: indexPath ) as! BookMarkTableViewCell
        // セルに値を格納していく
        if bookmark.count > 0 {
            cell.setCell(bookmark: bookmark, index: indexPath.row)
        }
        return cell
    }
    
    // スワイプで削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let drugName = bookmark[indexPath.row].drugName
        let sgmlURL = bookmark[indexPath.row].sgmlURL
        
        // Bookmarkから削除する
        Bookmark.delete(drugName: drugName, sgmlURL: sgmlURL)
        
        // Noteから削除する
        if Note.countByName(drugName: drugName) > 0 {
            Note.delete(drugName: drugName, tergetOld: false)
        }
        
        // TableViewから削除する
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if bookmark.count == 0 {
            searchFlg = 1
        }
        
        tableView.reloadData()
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
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // セルの選択を解除する
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 通信状態チェック
        if !network.checkReachability(reachability: reachability, view: view, alart: true) {
            return
        }
        
        // インジゲーターを表示する
        HUD.show(.progress)
 
        let sgmlURL: URL = URL(string: bookmark[indexPath.row].sgmlURL)!
        let sgmlURLString = self.bookmark[indexPath.row].sgmlURL
        let drugNameString: String = self.bookmark[indexPath.row].drugName
        let pdfRequestData = PdfRequestData()
        pdfRequestData.url = sgmlURLString
        
        if self.bookmark[indexPath.row].medicalFlg {
            searchKubun = .medical
        } else {
            searchKubun = .otc
        }
        
        sgmlURL.isReachable { (success) in

            // URLが有効だった場合
            if success {
                
                // PDFへのリンクを取得して画面遷移する
                self.moveNoteViewController(pdfRequestData: pdfRequestData, bookmark: self.bookmark, index: indexPath.row)
                
            } else {
            // URLが無効だった場合
                
                switch self.searchKubun {
                case .medical:
                    
                    // エンコーディングする
                    let urlEncoding = URLEncoding()
                    var encodedString: String = ""
                    encodedString = urlEncoding.utf8PercentEncoding(URLString: drugNameString)
                    
                    // 検索用語を更新する
                    let medicalRequestData = MedicalRequestData()
                    medicalRequestData.searchText = encodedString
                    
                    // 検索結果を取得する
                    HTTPRequest.searchMedicalDrug(postRequestData: medicalRequestData) { (result) in
                        
                        // 医薬品名が完全一致するインデックスを取得
                        let index = result.drugArray.firstIndex(of: drugNameString)
                        if let index = index {
                            
                            // 完全一致のデータがあったら、DBを更新する
                            let drugName: String = result.drugArray[index]
                            let sgmlURL: String = result.URLArray[index]
                            let kubun:String = result.kubunArray[index]
                            let detail:String = result.detailArray[index]
                            Bookmark.insert(drugName: drugName, sgmlURL: sgmlURL, kubun: kubun, detail: detail, medicalFlg: true)
                            
                            // PDFへのリンクを取得して画面遷移する
                            self.moveNoteViewController(pdfRequestData: pdfRequestData, bookmark: self.bookmark, index: 0)
                            
                        } else {
                        // 完全一致のデータがなかったら、
                            
                            // Bookmarkから削除する
                            Bookmark.delete(drugName: drugNameString, sgmlURL: sgmlURLString)
                            
                            // Noteから削除する
                            if Note.countByName(drugName: drugNameString) > 0 {
                                Note.delete(drugName: drugNameString, tergetOld: false)
                            }
                            
                            DispatchQueue.main.async {
                                
                                // seaechBarを初期化する
                                self.searchBar.text = ""
                                
                                // 0件だったとき
                                if self.bookmark.count == 0 {
                                    self.searchFlg = 1
                                }
                                
                                // ソートの状態を初期化する
                                self.selectedIndex = 0
                                
                                // ブックマークを全件取得する
                                self.bookmark = Bookmark.selectAll()
                                
                                // セルを構築する
                                self.tableView.reloadData()
                                
                                // インジケーターを終了する
                                HUD.hide()
                                
                                // フロートを表示する
                                let width = self.view.frame.size.width * 0.9
                                let height = self.view.frame.size.height * 0.1
                                float.show(message: "URLが無効であるため削除しました。", width: width, height: height)
                            }
                        }
                    }
                    return
                    
                case .otc:
                    
                    // エンコーディングする
                    let urlEncoding = URLEncoding()
                    var encodedString: String = ""
                    encodedString = urlEncoding.eucjpPercentEncoding(URLString: drugNameString)
                   
                    // 検索用語を更新する
                    let otcRequestData = OtcRequestData()
                    otcRequestData.searchText = encodedString
                    
                    // 検索結果を取得する
                    HTTPRequest.searchOtcDrug(postRequestData: otcRequestData) { (result) in
                        
                        // 医薬品名が完全一致するインデックスを取得
                        let index = result.drugArray.firstIndex(of: drugNameString)
                        if let index = index {
                            
                            // 完全一致のデータがあったら、DBを更新する
                            let drugName: String = result.drugArray[index]
                            let sgmlURL: String = result.URLArray[index]
                            let kubun:String = result.kubunArray[index]
                            let detail:String = result.detailArray[index]
                            Bookmark.insert(drugName: drugName, sgmlURL: sgmlURL, kubun: kubun, detail: detail, medicalFlg: false)
                            
                            // PDFへのリンクを取得して画面遷移する
                            self.moveNoteViewController(pdfRequestData: pdfRequestData, bookmark: self.bookmark, index: 0)
                            
                        } else {
                        // 完全一致のデータがなかったら、
                            
                            // Bookmarkから削除する
                            Bookmark.delete(drugName: drugNameString, sgmlURL: sgmlURLString)
                            
                            // Noteから削除する
                            if Note.countByName(drugName: drugNameString) > 0 {
                                Note.delete(drugName: drugNameString, tergetOld: false)
                            }
                            
                            DispatchQueue.main.async {
                                
                                // seaechBarを初期化する
                                self.searchBar.text = ""
                                
                                // 0件だったとき
                                if self.bookmark.count == 0 {
                                    self.searchFlg = 1
                                }
                                
                                // ソートの状態を初期化する
                                self.selectedIndex = 0
                                
                                // ブックマークを全件取得する
                                self.bookmark = Bookmark.selectAll()
                                
                                // セルを構築する
                                self.tableView.reloadData()
                                
                                // インジケーターを終了する
                                HUD.hide()
                                
                                // フロートを表示する
                                let width = self.view.frame.size.width * 0.9
                                let height = self.view.frame.size.height * 0.1
                                float.show(message: "URLが無効であるため削除しました。", width: width, height: height)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // PDFのリンク先を取得して画面遷移する
    func moveNoteViewController(pdfRequestData: PdfRequestData, bookmark: Results<Bookmark>!, index: Int) {
        
        HTTPRequest.getPdfURL(requestData: pdfRequestData, kubun: searchKubun, completion: { (result) in
            
            DispatchQueue.main.async {
                
                let drugNameString = bookmark[index].drugName
                let kubunString = bookmark[index].kubun
                let detailString = self.bookmark[index].detail
                let pdfURLString = result
                let sgmlURLString = pdfRequestData.url
                let medicalFlg = self.bookmark[index].medicalFlg
                var noteString: String = ""
                
                if Note.countByName(drugName: drugNameString) > 0 {
                    noteString = Note.selectNoteByName(drugName: drugNameString)
                }
            
                // インジケーターを終了する
                HUD.hide()
                
                // 画面遷移する
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let noteVC = storyboard.instantiateViewController(withIdentifier: "NoteViewController") as! NoteViewController
                
                noteVC.drugNameString = drugNameString
                noteVC.kubunString = kubunString
                noteVC.detailString = detailString
                noteVC.sgmlURLString = sgmlURLString
                noteVC.pdfURLString = pdfURLString
                noteVC.noteString = noteString
                noteVC.medicalFlg = medicalFlg
                
                self.navigationController?.pushViewController(noteVC, animated: true)
            }
        })
    }
}

// MARK: - UISearchBarDelegate

extension BookmarkViewController: UISearchBarDelegate {
    
    // 検索ボタンをクリックした時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // インジケーターを表示する
        HUD.show(.progress)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let drugNameString = searchBar.text {
                // 入力がなかったら
                if drugNameString == "" {
                    // 全件取得する
                    self.bookmark = Bookmark.selectAll()
                // 検索ワードが入力されていたら
                } else {
                    // 部分検索する
                    self.bookmark = Bookmark.selectLikeByName(drugName: drugNameString)
                }
                
                searchBar.text = drugNameString
            }
            
            if self.bookmark.count == 0 {
                self.searchFlg = 2
            }
            
            // ソートの状態を初期化する
            self.selectedIndex = 0
            
            // セルを構築する
            self.tableView.reloadData()
            
            // インジケーターを削除する
            HUD.hide()
            
            // キーボードを閉じる
            self.searchBar.resignFirstResponder()
        }
    }
}

// MARK: -  DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
extension BookmarkViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        scrollView.bounds.origin.y = 0
    }
    // 背景色
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor(red: 235 / 255, green: 235 / 255, blue: 235 / 255, alpha: 1)
    }
    
    // タイトル
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        var titleString = String()
        switch searchFlg {
        case 1: titleString = "ブックマークはありません"
        case 2: titleString = "検索結果は0件でした"
        default: titleString = "ブックマークはありません"
        }
        
        let stringAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.lightGray,
            .font : UIFont.systemFont(ofSize: 20)
        ]
        return NSAttributedString(string: titleString, attributes: stringAttributes)
    }

    // 画像
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        
        var imageString = String()
        switch searchFlg {
        case 1: imageString = "NoBookmarkImage"
        case 2: imageString = "NoResultImage"
        default: imageString = "NoBookmarkImage"
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
