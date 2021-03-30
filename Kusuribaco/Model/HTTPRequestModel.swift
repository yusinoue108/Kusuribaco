//
//  HTTPRequest.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import Foundation
import Kanna

// セルの要素を格納する
class ResultData{
    
    var drugArray: [String] = [String]()
    var URLArray: [String] = [String]()
    var kubunArray: [String] = [String]()
    var detailArray: [String] = [String]()
    var bookmarkArray: [String] = [String]()
}

class HTTPRequest{
    
    // POSTリクエストを投げて、処方薬の検索結果を取得する
    class func searchMedicalDrug(postRequestData: MedicalRequestData, completion: @escaping (ResultData) -> Void) {

        let resultData: ResultData = ResultData()

        // URL
        let url: URL = URL(string: postRequestData.url)!
        var request: URLRequest = URLRequest(url: url)

        // METHOD
        request.httpMethod = "POST"

        // BODY
        let bodyString: String = postRequestData.body + postRequestData.searchText
        request.httpBody = bodyString.data(using: .utf8)

        // HEADER
        request.addValue(postRequestData.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(postRequestData.accept, forHTTPHeaderField: "Accept")
        request.addValue(postRequestData.userAgent, forHTTPHeaderField: "User-Agent")

        // HTTPリクエストをする
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            // HTML解析をしていく
            if (error == nil) {
                if let result = String(data: data!, encoding: .utf8) {
                    
                    if let doc = try? Kanna.HTML(html: result, encoding: String.Encoding.utf8) {
                        
                        // 名前、リンクを取得する
                        for node in doc.xpath("//a[contains(@href, '/go/pack')]") {
                            // 名称
                            var drugString = HTTPRequest.removeTokusyuMoji(RawString: String(node.innerHTML!))
                            drugString = drugString.replacingOccurrences(of: " ", with: "")
                            resultData.drugArray.append(drugString)

                            // リンク
                            var linkString = String(node["href"]!)
                            linkString = "https://www.info.pmda.go.jp" + linkString
                            resultData.URLArray.append(linkString)
                            
                            // ブックマークフラグ
                            if Bookmark.selectByName(drugName: drugString, medicalFlg: true).count > 0 {
                                // ブックマーク済みだったら "1"
                                resultData.bookmarkArray.append("1")
                            } else {
                                // ブックマークされていなかったら "0"
                                resultData.bookmarkArray.append("0")
                            }
                        }

                        // 分類を取得する
                        for node in doc.xpath("//tr[@bgcolor='lightblue']//font[@size='-1']") {
                            let kubunString = String(node.innerHTML!)
                            let range = kubunString.range(of: "更新日")
                            
                            if range == nil {
                                resultData.kubunArray.append(kubunString)
                            }
                            
                        }

                        // 詳細情報を取得する
                        for node in doc.xpath("//tr[@bgcolor='lightblue']") {

                            if let doc2 = try? Kanna.HTML(html: String(node.toHTML!), encoding: String.Encoding.utf8){

                                var detailString = String()     //初期化する

                                // 詳細を取得していく
                                for node in doc2.xpath("//dd") {

                                    var _detailString = String(node.innerHTML!.components(separatedBy: "\r\n")[0])    //最初の１行だけ取得する
                                    _detailString = _detailString.components(separatedBy: "\n\n")[0]                  //<dd>タグ以降は削除する

                                    //累積していく
                                    if detailString == ""{
                                        detailString = _detailString
                                    }else{
                                        detailString =  detailString + "\n" + _detailString
                                    }
                                }

                                detailString = detailString.components(separatedBy: "\n\n")[0]                        //更新日以降は不要なので削除する
                                detailString = detailString.replacingOccurrences(of: "*", with: "")
                                resultData.detailArray.append(detailString)
                            } else {
                                return
                            }
                        }
                        completion(resultData)
                    } else {
                        return
                    }
                } else {
                    return
                }
            } else {
                return
            }
        }
        task.resume()
    }
    
    // POSTリクエストを投げて、市販薬の検索結果を取得する
    class func searchOtcDrug(postRequestData: OtcRequestData, completion: @escaping (ResultData) -> Void) {

        let resultData: ResultData = ResultData()

        // URL
        let url: URL = URL(string: postRequestData.url)!
        var request: URLRequest = URLRequest(url: url)

        // METHOD
        request.httpMethod = "POST"

        // BODY
        let bodyString: String = postRequestData.body + postRequestData.searchText
        request.httpBody = bodyString.data(using: .japaneseEUC)

        // HEADER
        request.addValue(postRequestData.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue(postRequestData.accept, forHTTPHeaderField: "Accept")
        request.addValue(postRequestData.userAgent, forHTTPHeaderField: "User-Agent")

        // HTTPリクエストをする
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            // HTML解析をしていく
            if (error == nil) {
                if let result = String(data: data!, encoding: .japaneseEUC) {
                    if let doc = try? Kanna.HTML(html: result, encoding: String.Encoding.utf8) {
                        // 名前、リンクを取得する
                        for node in doc.xpath("//td[@colspan='3']/a[contains(@href, '/ogo/')]") {
                            // 名称
                            let drugString = HTTPRequest.removeTokusyuMoji(RawString: String(node.innerHTML!))
                            resultData.drugArray.append(drugString)

                            // リンク
                            var linkString = String(node["href"]!)
                            linkString = "https://www.info.pmda.go.jp" + linkString
                            resultData.URLArray.append(linkString)
                            
                            // ブックマークフラグ
                            if Bookmark.selectByName(drugName: drugString, medicalFlg: false).count > 0 {
                                // ブックマーク済みだったら "1"
                                resultData.bookmarkArray.append("1")
                            } else {
                                // ブックマークされていなかったら "0"
                                resultData.bookmarkArray.append("0")
                            }
                        }

                        // 分類を取得する
                        for node in doc.xpath("//td[@colspan='3']/font[@size='-1']") {

                            let kubunString = String(node.innerHTML!)
                            resultData.kubunArray.append(kubunString)
                        }

                        // 詳細情報を取得する
                        for node in doc.xpath("//tr[@bgcolor='lightgreen']") {

                            if let doc2 = try? Kanna.HTML(html: String(node.toHTML!), encoding: String.Encoding.utf8){

                                var detailString = String()     //初期化する

                                //詳細を取得していく
                                for node in doc2.xpath("//dd") {

                                    var _detailString = String(node.innerHTML!.components(separatedBy: "\r\n")[0])    //最初の１行だけ取得する
                                    _detailString = _detailString.components(separatedBy: "<dd>")[0]    //<dd>タグ以降は削除する

                                    //累積していく
                                    if detailString == ""{
                                        detailString = _detailString
                                    }else{
                                        detailString =  detailString + "\n" + _detailString
                                    }
                                }

                                detailString = detailString.components(separatedBy: "更新日")[0]   //更新日は不要なので削除する
                                resultData.detailArray.append(detailString)
                            } else {
                                return
                            }
                        }
                        completion(resultData)
                    } else {
                        return
                    }
                } else {
                    return
                }
            } else {
                return
            }
        }
        task.resume()
    }

    // GETリクエストを投げて、PDFへのリンクを取得する
    class func getPdfURL(requestData: PdfRequestData, kubun: searchKubun, completion: @escaping (String) -> Void){

        var pdfString: String = ""
        var urlString = requestData.url
        
        // 新様式SGMLの場合(医療用医薬品)は別指定
        if urlString.contains("/?view=frame&style=XML&lang=ja") {
            
            urlString = urlString.replacingOccurrences(of: "https://www.info.pmda.go.jp/go/pack", with: "")
            urlString = urlString.replacingOccurrences(of: "/?view=frame&style=XML&lang=ja", with: "")
            urlString = "https://www.info.pmda.go.jp/go/pack\(urlString)\(urlString)?view=foot"
        }
        
        let url: URL = URL(string: urlString)!
        var request: URLRequest = URLRequest(url: url)

        // METHOD
        request.httpMethod = "GET"

        // HEADER
        request.addValue(requestData.userAgent, forHTTPHeaderField: "User-Agent")
        
        // 新様式SGMLの場合(医療用医薬品)は別指定
        if urlString.contains("/?view=frame&style=XML&lang=ja") {
            
            request.addValue(requestData.url, forHTTPHeaderField: "Referer")
        }
        
        // HTTPリクエストをしてHTMLを取得する
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in

            if (error == nil) {
                // HTML解析して添付文書へのリンクを取得する
                
                switch kubun {
                case .medical:
                    
                    let result = String(data: data!, encoding: .utf8)
                    if let doc = try? Kanna.HTML(html: result!, encoding: String.Encoding.utf8){
                        
                        for node in doc.xpath("//a[contains(text(), 'PDFファイル')]") {
                            pdfString = "https://www.info.pmda.go.jp" + String(node["href"]!)
                        }
                        completion(pdfString)
                    }
                case .otc:
                
                    let result = String(data: data!, encoding: .japaneseEUC)
                    if let doc = try? Kanna.HTML(html: result!, encoding: String.Encoding.utf8){
                        
                        for node in doc.xpath("//a[contains(text(), '添付文書')]") {
                            pdfString = "https://www.info.pmda.go.jp" + String(node["href"]!)
                        }
                        completion(pdfString)
                    }
                }
            } else {
                return
            }
        }
        task.resume()
    }
    
    // HTML特殊文字を削除する
    class func removeTokusyuMoji(RawString: String) -> String {
        RawString.replacingOccurrences(of: "<.{1,8}>", with: "", options: .regularExpression)
    }
}
