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
      
        //データ読み込み
        let result = bookdata.fileoperations.fileload(&bookdata)
        
        if result != "fileloadsuccess" {
            return result
        }
        
        refresh()
        
        return "fileloadsuccess"
    }
    
    //ここにfileloadしてもいいかも
    @objc func refresh(){
        
        bookdata.setDiplayData(searchtext: vc.SearchBar.text, searchtarget: vc.searchpicker.getTarget(), sortcategorytarget: vc.sortcategorypicker.getCategoryTarget(), sortordertarget: vc.sortorderpicker.getOrderTarget())
                
        cells = []
        CollectionView.reloadData()
        
        CollectionView.refreshControl?.endRefreshing()
    }
}
