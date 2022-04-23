//
//  SortPickerModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import Foundation

class SortCategoryPickerModel {
    
    private let sortcategorypickerlist: [String]
    private var sortcategorypickertarget: String
    
    init(){
        sortcategorypickerlist = ["タイトル", "著者", "出版社"]
        sortcategorypickertarget = "タイトル"
    }
    
    func getElement(_ index: Int) -> String{
        return sortcategorypickerlist[index]
    }
    
    func getSize() -> Int{
        return sortcategorypickerlist.count
    }
    
    func getCategoryTarget() -> String{
        return sortcategorypickertarget
    }
    
    func setCategoryTarget(_ target: String){
        sortcategorypickertarget = target
    }

    
}
