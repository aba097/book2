//
//  SearchPickerModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import Foundation

class SearchPickerModel {
    
    private let searchpickerlist: [String]
    private var searchpickertarget: String
    
    init(){
        searchpickerlist = ["全て", "タイトル", "著者", "出版社", "コメント", "貸出中"]
        searchpickertarget = "全て"
    }
    
    func getElement(_ index: Int) -> String{
        return searchpickerlist[index]
    }
    
    func getSize() -> Int{
        return searchpickerlist.count
    }
    
    func getTarget() -> String{
        return searchpickertarget
    }
    
    func setTarget(_ target: String){
        searchpickertarget = target
    }
    
}
