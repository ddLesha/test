//
//  StoreFrontViewController.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 04.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

class StoreFrontViewController: BaseController {
    
    let dataBase = DataBaseManager.shared
    let actionManager = ActionManager.shared
    var goods = Goods()
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelQuantity: UILabel!
    @IBOutlet weak var buttonBuy: UIButton!
    
    override func setupView() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        buttonBuy.layer.cornerRadius = 5.0
        buttonBuy.layer.borderWidth = 2.0
        buttonBuy.clipsToBounds = true
        
        reloadGoods()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGoods), name: Notification.Name(String(goods.id)), object: nil)
    }
    
    @objc func reloadGoods() {
        if let currentGoods = dataBase.getCurrentExistingGoods() {
            if currentGoods.id != self.goods.id {
                NotificationCenter.default.removeObserver(self, name: Notification.Name(String(self.goods.id)), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(reloadGoods), name: Notification.Name(String(currentGoods.id)), object: nil)
            }
            self.goods = currentGoods
            labelName.text = goods.name
            labelPrice.text = String(format: "%.02f", goods.price) + " руб."
            labelQuantity.text = "\(goods.quantity) шт."
        } else {
            labelName.text = "Товаров нет."
            labelPrice.text = ""
            labelQuantity.text = ""
        }
        let goodsIsBusy = actionManager.getGoodsStatus(goodsId: goods.id) != .free
        showLoader(show: goodsIsBusy)
    }
    
    func showLoader(show: Bool) {
        labelQuantity.text = show ? "" : String(goods.quantity)
        viewLoader.isHidden = !show
    }
    
    @IBAction func buttonBuyTap(_ sender: Any) {
        if goods.quantity > 0 {
            showLoader(show: true)
            actionManager.addBuyAction(goods: goods)
        }
    }
    
    func goToNextGoods() {
        if let prevGoods = dataBase.getPrevExistingGoods() {
            let prevVC = StoreFrontViewController(nibName: "StoreFrontViewController", bundle: nil)
            if prevVC.view != nil {} //toggle view loading
            prevVC.goods = prevGoods
            navigationController?.viewControllers = [prevVC, self]
            navigationController?.popViewController(animated: true)
        }
    }
    
    func goToPrevGoods() {
        if let nextGoods = dataBase.getNextExistingGoods() {
            let nextVC = StoreFrontViewController(nibName: "StoreFrontViewController", bundle: nil)
            if nextVC.view != nil {} //toggle view loading
            nextVC.goods = nextGoods
            navigationController?.pushViewController(nextVC, animated: true)
            navigationController?.viewControllers = [self, nextVC]
        }
    }
    
    @objc func swipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            goToNextGoods()
        } else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            goToPrevGoods()
        }
    }
}
