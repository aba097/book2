//
//  BookDataModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/26.
//

import Foundation
import UIKit
import SwiftyDropbox

class BookDataModel {
    
    let bookfilename = "bookdata.json"
    let bookfilepath = "/test/path/"
    
    let userfilename = "user.txt"
    let userfilepath = "/test/path/"
    
    //upload
    let uploadSemaphore = DispatchSemaphore(value: 0)
    var uploadState = ""
    
    //download
    let downloadSemaphore = DispatchSemaphore(value: 0)
    var downloadState = ""
    
    //exist
    let existSemaphore = DispatchSemaphore(value: 0)
    var existState = ""
    
    //JSON struct
    struct Bookdata: Codable {
        var id: Int        //本のID
        var title: String  //本のタイトル
        var author: String //本の著者
        var publisher: String //本の出版社
        var comment: String //本のコメント
        var state : String //本の貸し借り状態
    }
    
    //json読み込みデータ
    var bookjson:[Bookdata] = []
    
    //検索結果をもとに表示するものを格納
    var currentids:[Int] = []
    
    var ids:[Int] = [] //id list
    var titles:[String] = []
    var authors:[String] = []
    var publishers:[String] = []
    var state:[String] = [] //"":return username:borrow
    var comments:[String] = []
    var users:[String] = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
    
    /*==================user====================*/
    //user.txtが存在するか確認
    func userExist(){
        if DropboxClientsManager.authorizedClient == nil {
            existState = "認証してください"
            existSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        //ファイル一覧を取得
        client.files.listFolder(path: userfilepath).response { response, error in
            if let response = response {
                var flag = false
                for entry in response.entries {
                    //print(entry.name) ファイル一覧
                    if entry.name == self.userfilename {
                        self.existState = "doDownload"
                        flag = true
                    }
                }
                if !flag { //user.txtが存在しない
                    self.existState = "notExist"
                }
                self.existSemaphore.signal()
            } else if let error = error {
                print(error)
                self.existState = "ファイル一覧取得失敗"
                self.existSemaphore.signal()
            }
        }
    }
    
    //dropboxからダウンロード
    func userDownload(){
        if DropboxClientsManager.authorizedClient == nil {
            downloadState = "認証してください"
            downloadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        
        // Download to Data
        client.files.download(path: userfilepath + userfilename)
            .response { response, error in
                if let response = response {
                    
                    let fileContents = response.1
                    let text = String(data: fileContents, encoding: .utf8)
                    
                    //usersに追加
                    self.users = text!.components(separatedBy: "\n").filter{!$0.isEmpty}
                                        
                    self.downloadState = "success"
                    self.downloadSemaphore.signal()
                } else if let error = error {
                    print(error)
                    self.downloadState = "ダウンロード失敗"
                    self.downloadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    
    /*==================book===================*/
    //bookdata.jsonが存在するか確認
    func bookExist(){
        if DropboxClientsManager.authorizedClient == nil {
            existState = "認証してください"
            existSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        //ファイル一覧を取得
        client.files.listFolder(path: bookfilepath).response { response, error in
            if let response = response {
                var flag = false
                for entry in response.entries {
                    //print(entry.name) ファイル一覧
                    if entry.name == self.bookfilename {
                        self.existState = "doDownload"
                        flag = true
                    }
                }
                if !flag { //bookdata.jsonが存在しない
                    self.existState = "notExist"
                }
                self.existSemaphore.signal()
            } else if let error = error {
                print(error)
                self.existState = "ファイル一覧取得失敗"
                self.existSemaphore.signal()
            }
        }
    }
    
    //dropboxからダウンロード
    func bookDownload(){
        if DropboxClientsManager.authorizedClient == nil {
            downloadState = "認証してください"
            downloadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        
        // Download to Data
        client.files.download(path: bookfilepath + bookfilename)
            .response { response, error in
                if let response = response {
                    
                    let fileContents = response.1
                    guard let tmpbookdata = try? JSONDecoder().decode([Bookdata].self, from: fileContents) else {
                        self.downloadState = "JSONデコードエラー"
                        self.downloadSemaphore.signal()
                        return
                    }
                    //ダウンロード成功後 bookdataに追加
                    self.bookjson = tmpbookdata
                    
                    //それぞれの配列に分割
                    self.downloadState = self.jsonParse()
                    self.downloadSemaphore.signal()
                } else if let error = error {
                    print(error)
                    self.downloadState = "ダウンロード失敗"
                    self.downloadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }
    
    //DropBoxにアップロード
    func bookUpload() {
        
        if DropboxClientsManager.authorizedClient == nil {
            uploadState = "認証してください"
            uploadSemaphore.signal()
            return
        }
        
        let client = DropboxClientsManager.authorizedClient!
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(bookjson) else {
            uploadState = "JSONエンコードエラー"
            uploadSemaphore.signal()
            return
        }
        
        client.files.upload(path: bookfilepath + bookfilename, mode: .overwrite, input: data)
            .response { response, error in
                if let response = response {
                    //print(response)
                    self.uploadState = "success"
                    self.uploadSemaphore.signal()
                } else if let error = error {
                    print(error)
                    self.uploadState = "アップロード失敗"
                    self.uploadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
    }

    //datajsonを分割する
    func jsonParse()->String{
        
        ids = []
        //idを代入
        for book in bookjson {
            ids.append(book.id)
        }
        
        //本が存在しない
        if ids.count == 0 {
            return "success"
        }

        titles = []
        authors = []
        publishers = []
        comments = []
        state = []
        
        for _ in 0 ..< ids[ids.count - 1] + 1 {
            titles.append("")
            authors.append("")
            publishers.append("")
            comments.append("")
            state.append("")
        }
        
        for book in bookjson {
            titles[book.id] = book.title
            authors[book.id] = book.author
            publishers[book.id] = book.publisher
            comments[book.id] = book.comment
            state[book.id] = book.state
        }
        
        return "success"
    }
    
    //本の表示画面の更新
    func setDiplayData(searchtext: String?, searchtarget: String, sortcategorytarget: String, sortordertarget: String){
    
        currentids = []
        
        //本が存在しない
        if ids.count == 0 {
            return
        }
        //検索入力ない
        if searchtext == nil || searchtext! == "" {
            currentids = ids
        }else{
            //表示するidxをtrueする
            var idx = Array(repeating: false, count: ids[ids.count - 1] + 1)

            //タイトル名
            if searchtarget == "全て" || searchtarget == "タイトル" {
                for i in 0 ..< titles.count {
                    //存在するi(=id)でタイトルとsearchtextを全て小文字にして比較し，部分一致するものはtrue
                    if ids.firstIndex(of: i) != nil && titles[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            //著者
            if searchtarget == "全て" || searchtarget == "著者" {
                for i in 0 ..< authors.count {
                    if ids.firstIndex(of: i) != nil && authors[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            //出版社
            if searchtarget == "全て" || searchtarget == "出版社" {
                for i in 0 ..< publishers.count {
                    if ids.firstIndex(of: i) != nil && publishers[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            //コメント
            if searchtarget == "全て" || searchtarget == "コメント" {
                for i in 0 ..< comments.count {
                    if ids.firstIndex(of: i) != nil && comments[i].lowercased().contains(searchtext!.lowercased()) {
                        idx[i] = true
                    }
                }
            }
            //tureのidのみ表示用としてcurrentidsに追加
            for i in 0 ..< idx.count{
                if idx[i] {
                    currentids.append(i)
                }
            }
        }
        
        //貸出し中の本のみ
        if searchtarget == "貸出中" {
            currentids = []
            for i in 0 ..< state.count {
                //存在するi(=id)で借りられている
                if ids.firstIndex(of: i) != nil && state[i] != "" {
                    currentids.append(i)
                }
            }
        }
    
        
        //sort element
        var tmp:[String]
        
        switch (sortcategorytarget, sortordertarget) {
        case ("タイトル", "昇順"):
            //タイトルでソート
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
                    //title順にソートされたtmpとソートされていないtitleを比較して，同一のものでなおかつ，まだ追加していないかつ，currentidsに追加されているものを追加
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
        
        //ソートされたidsをcurrentidsに追加
        currentids = tmpids
    }
    
    //貸し借りボタンを押されたので変更
    func borrowreturnAction(_ action: String, _ user: String, _ idx: Int) -> String {
        //idxは本id
        
        var existFlag = false
        for i in 0 ..< bookjson.count {
            if bookjson[i].id == idx {
                existFlag = true
                //貸し借り状態が変化していない
                if bookjson[i].state == state[idx] {
                    //貸し借り状態を変更
                    switch action {
                    case "borrow":
                        bookjson[i].state = user
                    case "return":
                        bookjson[i].state = ""
                    default: break
                    }
                }else{
                    return "貸し借り状態がすでに変更されています"
                }
            }
        }
        if !existFlag{
            return "この本は削除されています"
        }
    
        return "success"
    }

}
