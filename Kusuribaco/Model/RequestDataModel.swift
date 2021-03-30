//
//  RequestDataModel
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/03/06.
//

import Foundation

// PDFリンク取得用のリクエスト情報を格納する
class PdfRequestData {

    // URL
    var url: String = ""
    
    // HEADER
    var userAgent: String  = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
}

// 医療用医薬品検索用のリクエスト情報を格納する
class MedicalRequestData {
    
    // URL
    var url: String  = "https://www.info.pmda.go.jp/psearch/PackinsSearch"
    
    // BODY
    var body: String  = "SHORIFLG=0&count=1000&dragname="
    
    // HEADER
    var contentType: String  = "application/x-www-form-urlencoded"
    var accept: String  = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
    
    // 検索ワード
    var searchText: String = ""
}

// 一般用医薬品検索用のリクエスト情報を格納する
class OtcRequestData {
    
    // URL
    var url: String  = "https://www.info.pmda.go.jp/osearch/PackinsSearch"
    
    // BODY
    var body: String  = "SHORIFLG=0&cboDisCnt=20&txtSaleName="
    
    // HEADER
    var contentType: String  = "application/x-www-form-urlencoded"
    var accept: String  = "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9"
    var userAgent: String = "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1"
       
    // 検索ワード
    var searchText: String = ""
}
