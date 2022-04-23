//
//  BookDataModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/26.
//

import Foundation

class BookDataModel {
    
    //検索結果をもとに表示するものを格納
    var currentids:[Int] = []
    
    var ids:[Int] = [] //id list
    var titles:[String] = []
    var authors:[String] = []
    var publishers:[String] = []
    var borrowreturns:[Int] = [] //-1:return usernum:borrow
    var images:[String] = [] //image list "":notexist url:exist 
    var comments:[String] = []
    var users:[String] = []
    
    var fileoperations = FileOperationsModel()
    
    //本の表示画面の更新
    func setDiplayData(searchtext: String?, searchtarget: String, sortcategorytarget: String, sortordertarget: String){
        
        currentids = []
        
        //検索入力ない
        if searchtext == nil || searchtext! == "" {
            currentids = ids
        }else{
            
            var idx = Array(repeating: false, count: ids[ids.count - 1] + 1)
            
            if searchtarget == "全て" || searchtarget == "タイトル" {
                for i in 0 ..< titles.count {
                    if ids.firstIndex(of: i) != nil && titles[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            
            if searchtarget == "全て" || searchtarget == "著者" {
                for i in 0 ..< authors.count {
                    if ids.firstIndex(of: i) != nil && authors[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            
            if searchtarget == "全て" || searchtarget == "出版社" {
                for i in 0 ..< publishers.count {
                    if ids.firstIndex(of: i) != nil && publishers[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            
            if searchtarget == "全て" || searchtarget == "コメント" {
                for i in 0 ..< comments.count {
                    if ids.firstIndex(of: i) != nil && comments[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            
            if searchtarget == "貸出中" {
                for i in 0 ..< borrowreturns.count {
                    if ids.firstIndex(of: i) != nil && borrowreturns[i] != -1 {
                        idx[i] = true
                    }
                }
            }
            
            for i in 0 ..< idx.count{
                if idx[i] {
                    currentids.append(i)
                }
            }
        }
    
        
        //sort element
        var tmp:[String]
        
        switch (sortcategorytarget, sortordertarget) {
        case ("タイトル", "昇順"):
            tmp = titles.sorted{ $0.localizedStandardCompare($1) == .orderedAscending}
        case ("タイトル", "降順"):
            tmp = titles.sorted{ $0.localizedStandardCompare($1) == .orderedDescending}
        case ("著者", "昇順"):
            tmp = authors.sorted{ $0.localizedStandardCompare($1) == .orderedAscending}
        case ("著者", "降順"):
            tmp = authors.sorted{ $0.localizedStandardCompare($1) == .orderedDescending}
        case ("出版社", "昇順"):
            tmp = publishers.sorted{ $0.localizedStandardCompare($1) == .orderedAscending}
        case ("出版社", "降順"):
            tmp = publishers.sorted{ $0.localizedStandardCompare($1) == .orderedDescending}
        default :
            print("error")
            tmp = titles.sorted{ $0.localizedStandardCompare($1) == .orderedAscending}
        }
        
        var tmpids:[Int] = []
        
        //sort index
        switch (sortcategorytarget) {
        case ("タイトル"):
            //title
            for i in 0 ..< tmp.count {
                for j in 0 ..< titles.count {
                    if tmp[i] == titles[j] && tmpids.firstIndex(of: j) == nil && currentids.firstIndex(of: j) != nil {
                        tmpids.append(j)
                    }
                }
            }
        case ("著者"):
            //writer
            for i in 0 ..< tmp.count {
                for j in 0 ..< authors.count{
                    if tmp[i] == authors[j] && tmpids.firstIndex(of: j) == nil && currentids.firstIndex(of: j) != nil {
                        tmpids.append(j)
                    }
                }
            }
            
        case ("出版社"):
            //publisher
            for i in 0 ..< tmp.count {
                for j in 0 ..< publishers.count {
                    if tmp[i] == publishers[j] && tmpids.firstIndex(of: j) == nil && currentids.firstIndex(of: j) != nil {
                        tmpids.append(j)
                    }
                }
            }
    
        default : break
        }
        
        currentids = tmpids
        
    }
    
    //貸し借りボタンを押されたので変更
    func borrowreturnAction(_ action: String, user: Int, _ idx: Int) -> String {
        //ファイルが削除されていないか確認，削除されていれいたらその旨をアラート adminを見て
        //borrowreturnファイル読み込み　貸し借りが変更されていないか改めて確認　アラート
        //borrowreturnファイル書き込み
        
        //ファイルが削除されていないか確認
        var admin:[Int] = []
        var result = fileoperations.fileloadAdmin(&admin)
        
        //Adminファイルを読み込み失敗
        if result != "fileloadAdminsuccess" {
            return "readErrorAdmin"
        }

        //本と対応するIDが存在しない
        if admin.firstIndex(of: idx) == nil {
            return "bookNotFound"
        }
        
        //貸し借りが変更されていないか確認
        var checktarget : Int = 0
        result = fileoperations.fileloadBorrowreturn(idx, &checktarget, borrowreturns.count)

        //Borrowreturnファイルの読み込み失敗
        if result != "fileloadBorrowreturnsuccess"{
            return "readErrorBorrowreturn"
        }
        
        //貸し借りがすでに変更されている
        if checktarget != borrowreturns[idx] {
            return "alreadyChanged"
        }
        
        switch action {
        case "borrow":
            borrowreturns[idx] = user
        case "return":
            borrowreturns[idx] = -1
        default: break
        }
        
        result  =  fileoperations.filesaveBorrowreturn(&borrowreturns, &ids)
        
        //Borrowreturnファイルの書き込み失敗
        if result != "filesaveBorrowretrunsucess" {
            return "writeErrorBorrowreturn"
        }
        
        //貸し借り成功
        return action
        
    }

}
