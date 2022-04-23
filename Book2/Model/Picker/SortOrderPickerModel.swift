//
//  SortOrderPickerModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import Foundation

class SortOrderPickerModel {
    
    private let sortorderpickerlist: [String]
    private var sortorderpickertarget: String
    
    init(){
        sortorderpickerlist = ["昇順", "降順"]
        sortorderpickertarget = "昇順"
    }
    
    func getElement(_ index: Int) -> String{
        return sortorderpickerlist[index]
    }
    
    func getSize() -> Int{
        return sortorderpickerlist.count
    }
    
    func getOrderTarget() -> String{
        return sortorderpickertarget
    }
    
    func setOrderTarget(_ target: String){
        sortorderpickertarget = target
    }
}
