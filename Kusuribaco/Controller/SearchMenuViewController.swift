//
//  MenuViewController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/03/27.
//

import UIKit

class SearchMenuViewController: UIViewController {


    @IBOutlet weak var medicalSearchButton: UIButton!
    @IBOutlet weak var OtcSearchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Viewの背景色
        view.backgroundColor = .myGray()

        medicalSearchButton.backgroundColor = .clear
        medicalSearchButton.layer.shadowOpacity = 0.25
        medicalSearchButton.layer.shadowRadius = 5
        medicalSearchButton.layer.shadowOffset = CGSize(width: 5.0, height: 7.0)
        
        OtcSearchButton.backgroundColor = .clear
        OtcSearchButton.layer.shadowOpacity = 0.25
        OtcSearchButton.layer.shadowRadius = 5
        OtcSearchButton.layer.shadowOffset = CGSize(width: 5.0, height: 7.0)
        
        // Titleの設定
        self.navigationItem.title = "薬の検索"
        self.navigationController?.navigationBar.barTintColor = .systemTeal
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    @IBAction func moveMedicalSearchVC(_ sender: Any) {
       
        // 画面遷移する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        searchVC.searchKubun = .medical
        
        self.navigationController?.pushViewController(searchVC, animated: true)
    }

    @IBAction func moveOtcSearchVC(_ sender: Any) {
        // 画面遷移する
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let searchVC = storyboard.instantiateViewController(withIdentifier: "SearchVC") as! SearchViewController
        searchVC.searchKubun = .otc
        
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
}
