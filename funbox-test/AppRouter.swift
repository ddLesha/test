//
//  AppRouter.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 03.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

final class AppRouter {
    enum AppTabs: Int {
        case storeFront = 0
        case backEnd = 1
    }
    
    static let shared = AppRouter()
    var window: UIWindow?
    weak var storeFrontNavController: UINavigationController?
    weak var backEndNavController: UINavigationController?
    fileprivate init() {}
    private var containerView: ContainerViewController?
    
    func showAlert(tab: AppTabs, message: String) {
        guard self.containerView?.selectedIndex == tab.rawValue else {
            return
        }
        
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(.init(title: "OK", style: .default, handler: nil))
        if tab == .backEnd {
            if backEndNavController?.visibleViewController?.isKind(of: BackEndEditViewController.self) ?? false {
                backEndNavController?.present(alertController, animated: true, completion: nil)
            }
        } else if tab == .storeFront {
            storeFrontNavController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentContainerModule() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Bold", size: 20)!], for: .normal)
        
        let storeFrontView = StoreFrontViewController(nibName: "StoreFrontViewController", bundle: nil)
        if storeFrontView.view != nil {} //toggle view loading
        let storeFrontNav = UINavigationController(rootViewController: storeFrontView)
        storeFrontNav.navigationBar.isTranslucent = false
        storeFrontNav.navigationBar.isHidden = true
        self.storeFrontNavController = storeFrontNav
        
        let backEndView = BackEndViewController(nibName: "BackEndViewController", bundle: nil)
        if backEndView.view != nil {}
        let backEndNav = UINavigationController(rootViewController: backEndView)
        backEndNav.navigationBar.isTranslucent = false
        backEndNav.navigationBar.isHidden = true
        self.backEndNavController = backEndNav
        
        let containerView = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        containerView.setViewControllers([
            storeFrontNav,
            backEndNav
            ], animated: true)
        containerView.tabBar.isTranslucent = false

        window?.rootViewController = containerView
        window?.makeKeyAndVisible()
        
        storeFrontNav.tabBarItem = UITabBarItem(title: "Store-Front", image: nil, tag: 0)
        storeFrontNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -10)
        backEndNav.tabBarItem = UITabBarItem(title: "Back-End", image: nil, tag: 1)
        backEndNav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -10)
        
        self.containerView = containerView
    }
    
}
