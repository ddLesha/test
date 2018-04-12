//
//  BackEndViewController.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 04.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import UIKit

class BackEndViewController: BaseController {
    
    var goods = [Goods]()
    let dataBase = DataBaseManager.shared
    
    @IBOutlet weak var tableView: UITableView!
    
    override func setupView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable), name: Notification.Name("BackEndViewController-ReloadTable"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadTable()
    }
    
    @IBAction func buttonAddGoodsTap(_ sender: Any) {
        showBackEndEditViewController()
    }
    
    func showBackEndEditViewController(goods: Goods = Goods()) {
        let backEndEditViewController = BackEndEditViewController(nibName: "BackEndEditViewController", bundle: nil)
        backEndEditViewController.goods = goods
        if backEndEditViewController.view != nil {} //toggle view loading
        navigationController?.pushViewController(backEndEditViewController, animated: true)
    }
    
    @objc func reloadTable() {
        goods = dataBase.getAllGoods()
        tableView.reloadData()
    }
}

//tableview
extension BackEndViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier:"backEndTableViewCell") as? BackEndTableViewCell
        if cell == nil {
            tableView.register(UINib.init(nibName: "BackEndTableViewCell", bundle: nil), forCellReuseIdentifier: "backEndTableViewCell")
            cell = Bundle.main.loadNibNamed("BackEndTableViewCell",owner: self, options: nil)!.first as? BackEndTableViewCell
        }
        
        cell?.setupCell(name: goods[indexPath.row].name, quantity: "\(goods[indexPath.row].quantity)")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showBackEndEditViewController(goods: goods[indexPath.row])
    }
}
