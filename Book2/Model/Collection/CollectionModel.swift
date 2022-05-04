//
//  CollectionModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import Foundation
import UIKit

class CollectionModel{

    weak var CollectionView: UICollectionView!
    weak var vc: ViewController!
    
    var bookdata = BookDataModel()
    
    //貸し借り状態を変える用
    var cells:[CollectionViewCell] = []
    var cellselected = 0 //選択したcell
    
    let refreshcontrol = UIRefreshControl()
    
    func setup() -> String{
        
        //refresh　下に引っ張ったときの動作を設定
        CollectionView.refreshControl = refreshcontrol
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        let result = refresh()
        if result != "success" {
            return result
        }
        return "success"
    }
    
    //ファイル読み込み
    func load() -> String {
        //データ読み込み
        var result = bookdata.bookLoad()
        if result != "success" {
            return result
        }
    
        result = bookdata.jsonParse()
        if result != "success" {
            return result
        }
        
        result = bookdata.userLoad()
        if result != "success" {
            return result
        }

        return "success"
    }
    
    //本の貸し借り変更
    func borrowreturnAction(_ action: String, _ user: String, _ idx: Int) -> String {
        //json読み込み
        var result = bookdata.bookLoad()
        if result != "success" {
            return result
        }
        
        //json変更
        result = bookdata.borrowreturnAction(action, user, idx)
        if result != "success" {
            return result
        }
        
        //ファイル読み込み
        result = refresh()
        if result != "success" {
            return result
        }
        
        return "success"
    }
    
    @objc func refresh() -> String{
        
        //ファイル読み込み
        let result = load()
        if result != "success" {
            return result
        }
        
        bookdata.setDiplayData(searchtext: vc.SearchBar.text, searchtarget: vc.searchpicker.getTarget(), sortcategorytarget: vc.sortcategorypicker.getCategoryTarget(), sortordertarget: vc.sortorderpicker.getOrderTarget())
    
        CollectionView.reloadData()
        CollectionView.refreshControl?.endRefreshing()
        
        return "success"
    }
    
}
