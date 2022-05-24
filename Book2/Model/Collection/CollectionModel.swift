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
    
    //貸し借りを変更する本のid
    var targetBookIdx = 0
    
    let refreshcontrol = UIRefreshControl()
    
    func setup(){
        
        //refresh　下に引っ張ったときの動作を設定
        CollectionView.refreshControl = refreshcontrol
        refreshcontrol.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    }
 
    @objc func refresh(){
        
        vc.loadBook()
        
        CollectionView.refreshControl?.endRefreshing()
        
        
    
    }
    
}
