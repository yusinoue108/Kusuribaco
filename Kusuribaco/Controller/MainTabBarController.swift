//
//  MainTabBarController.swift
//  Kusuribaco
//
//  Created by Yusuke Inoue on 2021/01/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var viewControllers: [UIViewController] = []
        
        let otcSearchVC = storyboard?.instantiateViewController(withIdentifier: "OtcSearchVC") as! OtcSearchViewController
        let bookmarkVC = storyboard?.instantiateViewController(withIdentifier: "BookMarkVC") as! BookmarkViewController

        
        otcSearchVC.tabBarItem.title = "検索"
        let searchImage: UIImage = (UIImage(named: "SearchIcon")?.resized(width: 30))!
        otcSearchVC.tabBarItem.image = searchImage
        viewControllers.append(otcSearchVC)
        
        bookmarkVC.tabBarItem.title = "ブックマーク"
        let bookmarkImage: UIImage = (UIImage(named: "BookmarkIcon")?.resized(width: 30))!
        bookmarkVC.tabBarItem.image = bookmarkImage
        viewControllers.append(bookmarkVC)
        
        viewControllers = viewControllers.map{UINavigationController(rootViewController: $0)}
        self.setViewControllers(viewControllers, animated: false)
    }
    
}
