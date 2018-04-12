//
//  ActionManager.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 09.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//

import Foundation

enum GoodsStatusNames {
    case savingChanges
    case buying
    case free
}

struct GoodsStatus {
    var status = GoodsStatusNames.free
    var message = ""
}

final class ActionManager {
    private var operations = [Int:OperationQueue]()
    private var statusOfGoods = [Int:GoodsStatus]()
    
    let dataBase = DataBaseManager.shared
    let appRouter = AppRouter.shared
    
    let DELAY_FOR_BUY_ACTION: UInt32 = 3
    let DELAY_FOR_SAVING_GOODS_ACTION: UInt32 = 5
    
    private init() {}
    
    static let shared = ActionManager()
    
    func getGoodsStatus(goodsId: Int) -> GoodsStatusNames {
        if let status = statusOfGoods[goodsId]?.status {
            return status
        } else {
            return .free
        }
    }
    
    func addBuyAction(goods: Goods) {
        if operations[goods.id] == nil {
            operations[goods.id] = OperationQueue()
            operations[goods.id]?.maxConcurrentOperationCount = 1
        }
        if statusOfGoods[goods.id] == nil {
           statusOfGoods[goods.id] = GoodsStatus()
        }
        operations[goods.id]?.addOperation {
            self.statusOfGoods[goods.id]?.status = .buying
            sleep(self.DELAY_FOR_BUY_ACTION)
            var message = ""
            if let refreshGoods = self.dataBase.loadGoods(id: goods.id) {
                if refreshGoods.quantity > 0 {
                    var newGoods = refreshGoods
                    newGoods.quantity = newGoods.quantity - 1
                    self.dataBase.saveGoods(goods: newGoods)
                    message = "Товар \(goods.name) успешно куплен"
                } else {
                    message = "Покупка товара \(goods.name) отменена, товар закончился на складе"
                }
            } else {
                message = "Товар \(goods.name) был удален из базы данных"
            }
            self.statusOfGoods[goods.id]?.message = message
            self.statusOfGoods[goods.id]?.status = .free
            if self.operations[goods.id]?.operations.count == 1 {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(String(goods.id)), object: nil)
                    self.appRouter.showAlert(tab: .storeFront, message: message)
                    NotificationCenter.default.post(name: Notification.Name("BackEndViewController-ReloadTable"), object: nil)
                }
            }
        }
        
    }
    
    func addSaveGoodsAction(goods: Goods) {
        if operations[goods.id] == nil {
            operations[goods.id] = OperationQueue()
            operations[goods.id]?.maxConcurrentOperationCount = 1
        }
        if statusOfGoods[goods.id] == nil {
            statusOfGoods[goods.id] = GoodsStatus()
        }
        
        let buyingInProgress = self.operations[goods.id]!.operations.count != 0 && self.statusOfGoods[goods.id]!.status == .buying
        operations[goods.id]?.addOperation {
            self.statusOfGoods[goods.id]?.status = .savingChanges
            sleep(self.DELAY_FOR_SAVING_GOODS_ACTION)
            var message = ""
            if buyingInProgress  {
                if goods.quantity > 0 {
                    var newGoods = goods
                    newGoods.quantity = newGoods.quantity - 1
                    self.dataBase.saveGoods(goods: newGoods)
                    message = "Товар \(goods.name) успешно изменен, кол-во изменено с учетом покупки"
                    DispatchQueue.main.async {
                        self.appRouter.showAlert(tab: .storeFront, message: "Товар \(goods.name) успешно куплен")
                    }
                } else {
                    self.dataBase.saveGoods(goods: goods)
                    message = "Товар \(goods.name) успешно изменен, товар закончился, текущая покупка отменена"
                    DispatchQueue.main.async {
                        self.appRouter.showAlert(tab: .storeFront, message: "Покупка товара \(goods.name) отменена, товар закончился на складе")
                    }
                }
            } else {
                self.dataBase.saveGoods(goods: goods)
                message = "Товар \(goods.name) успешно сохранен"
            }
            self.statusOfGoods[goods.id]?.message = message
            self.statusOfGoods[goods.id]?.status = .free
            if self.operations[goods.id]?.operations.count == 1 {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name(String(goods.id)), object: nil)
                    self.appRouter.showAlert(tab: .backEnd, message: message)
                    NotificationCenter.default.post(name: Notification.Name("BackEndViewController-ReloadTable"), object: nil)
                }
            }
        }
    }
}
