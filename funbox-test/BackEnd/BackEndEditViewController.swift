//
//  BackEndEditViewController.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 05.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

class BackEndEditViewController: BaseController {
    
    let actionManager = ActionManager.shared
    let dataBase = DataBaseManager.shared
    var goods = Goods()
    
    @IBOutlet weak var viewLoader: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPrice: UITextField!
    @IBOutlet weak var textFieldQuantity: UITextField!
    
    override func setupView() {
        buttonSave.layer.cornerRadius = 5.0
        buttonSave.layer.borderWidth = 1.0
        buttonSave.clipsToBounds = true
        buttonCancel.layer.cornerRadius = 5.0
        buttonCancel.layer.borderWidth = 1.0
        buttonCancel.clipsToBounds = true
        
        reloadGoods()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadGoods), name: Notification.Name(String(goods.id)), object: nil)
    }
    
    @objc func reloadGoods() {
        goods = dataBase.loadGoods(id: goods.id) ?? Goods()
        textFieldName.text = goods.name
        textFieldPrice.text = String(goods.price)
        textFieldQuantity.text = String(goods.quantity)
        let goodsIsBusy = actionManager.getGoodsStatus(goodsId: goods.id) != .free
        showLoader(show: goodsIsBusy)
    }
    
    func showLoader(show: Bool) {
        viewLoader.isHidden = !show
    }
    
    @IBAction func buttonSaveTap(_ sender: Any) {
        if dataBase.loadGoods(id: goods.id) == nil {
            NotificationCenter.default.removeObserver(self, name: Notification.Name(String(goods.id)), object: nil)
            goods.id = dataBase.generateIdForNewGoods()
            NotificationCenter.default.addObserver(self, selector: #selector(reloadGoods), name: Notification.Name(String(goods.id)), object: nil)
        }
        goods.name = textFieldName.text ?? ""
        goods.price = Double(textFieldPrice.text ?? "0") ?? 0
        goods.quantity = Int(textFieldQuantity.text ?? "0") ?? 0
        showLoader(show: true)
        actionManager.addSaveGoodsAction(goods: goods)
    }
    
    @IBAction func buttonCancelTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
