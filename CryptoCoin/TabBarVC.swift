//
//  TabBarVC.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [createHomePageVC(), createPortfolioVC()]
    }
    
    func createPortfolioVC() -> UIViewController {
        guard let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "PortfolioViewController") as? PortfolioViewController else {
            return UIViewController()
        }
        vc.tabBarItem.image = UIImage(systemName: "dollarsign.circle.fill")
        vc.title = "Portfolio"
        return UINavigationController(rootViewController: vc)
    }
    
    func createHomePageVC() -> UINavigationController {
        
        let homePageVC = HomeViewController()
        
        homePageVC.title = "Crypto Coin"
        homePageVC.tabBarItem.image = UIImage(systemName: "bitcoinsign.square.fill")
        return UINavigationController(rootViewController: homePageVC)
    }
}
