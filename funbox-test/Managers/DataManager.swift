//
//  DataManager.swift
//  funbox-test
//
//  Created by Alexey Kuznetsov on 04.04.2018.
//  Copyright © 2018 Alexey Kuznetsov. All rights reserved.
//
import UIKit

struct Goods {
    var id = -1
    var name = ""
    var quantity = 0
    var price = 0.0
}

protocol DataBase {
    func loadData() -> [Goods]
    func saveData()
}

final class DataBaseManager: DataBase {
    
    private var adaptee = CSVDataBase()
    private var currentIndex = 0
    private var goods = [Goods]()
    
    private init() {
        self.goods = loadData()
    }
    
    static let shared = DataBaseManager()
    
    func loadData() -> [Goods] {
        return adaptee.loadData()
    }
    
    func saveData() {
        adaptee.saveData(goods: self.goods)
    }
    
    func loadGoods(id: Int) -> Goods? {
        guard id >= 0, id <= self.goods.count - 1 else {
            return nil
        }
        return self.goods[id]
    }
    
    func saveGoods(goods: Goods) {
        if goods.id >= 0, goods.id <= self.goods.count - 1 {
            self.goods[goods.id] = goods
        } else {
            let newId = generateIdForNewGoods()
            self.goods[newId] = goods
        }
        
        adaptee.saveData(goods: self.goods)
    }
    
    func generateIdForNewGoods() -> Int {
        var newGoods = Goods()
        newGoods.id = self.goods.count
        self.goods.append(newGoods)
        return newGoods.id
    }
    
    func getCurrentExistingGoods() -> Goods? {
        guard goods.count != 0, currentIndex <= goods.count - 1, currentIndex >= 0 else {
            currentIndex = 0
            return nil
        }
        
        if self.goods[currentIndex].quantity == 0 {
            if let currentGoods = getNextExistingGoods() {
                return currentGoods
            } else {
                return getPrevExistingGoods()
            }
        } else {
            return self.goods[currentIndex]
        }
    }
    
    func getNextExistingGoods() -> Goods? {
        guard goods.count != 0, currentIndex < goods.count - 1 else {
            return nil
        }
        
        for index in currentIndex + 1 ..< goods.count {
            if goods[index].quantity != 0 {
                currentIndex = index
                return goods[currentIndex]
            }
        }
        return nil
    }
    
    func getPrevExistingGoods() -> Goods? {
        guard goods.count != 0, currentIndex > 0 else {
            return nil
        }
        
        for index in (0 ... currentIndex - 1).reversed() {
            if goods[index].quantity != 0 {
                currentIndex = index
                return goods[currentIndex]
            }
        }
        return nil
    }
    
    func getAllGoods() -> [Goods] {
        return self.goods
    }
}

class CSVDataBase {
    
    let filename = "data"
    let filetype = "csv"
    
    func loadData() -> [Goods] {
        var data = readDataFromCSV(fileName: filename, fileType: filetype)
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        var goods = [Goods]()
        var id = 0
        for element in csvRows {
            goods.append(.init(id: id, name: element[0], quantity: Int(element[2]) ?? 0, price: Double(element[1]) ?? 0))
            id = id + 1
        }
        return goods
    }
    
    func saveData(goods: [Goods]) {
        var text = ""
        for g in goods {
            text.append("\"\(g.name)\", \"\(g.price)\", \"\(g.quantity)\"\n")
        }
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(filename)
            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
            }
            catch {
                print("failed to save data")
            }
        }
    }
    
    func readDataFromCSV(fileName: String, fileType: String) -> String! {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            var contents = try String(contentsOfFile: filepath, encoding: .utf8)
            contents = cleanRows(file: contents)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ", ")
            result.append(columns)
        }
        return result
    }
    
    func cleanRows(file: String) -> String {
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\"", with: "")
        return cleanFile
    }
}


