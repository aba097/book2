//
//  BookDataModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/26.
//

import Foundation
import UIKit

class BookDataModel {
    
    let bookfilename = "bookdata.json"
    let bookfilepath = NSHomeDirectory() + "/Documents/" + "bookdata.json"
    
    let userfilename = "user.txt"
    let userfilepath = NSHomeDirectory() + "/Documents/" + "user.txt"
    
    //JSON struct
    struct Bookdata: Codable {
        var id: Int        //本のID
        var title: String  //本のタイトル
        var author: String //本の著者
        var publisher: String //本の出版社
        var comment: String //本のコメント
        var image: String //本のURL
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
    var images:[String] = [] //image list "":notexist url:exist 
    var comments:[String] = []
    var users:[String] = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
    
    /*==================user====================*/
    //user読み込み
    func userLoad() -> String {
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        //user.txtファイルがない場合は，usersを書き込み作成
        if !FileManager.default.fileExists(atPath: userfilepath){
            let fileURL = dirURL.appendingPathComponent(userfilename)
            
            FileManager.default.createFile(atPath: userfilepath, contents: nil, attributes: nil)
    
            var writetxt = users[0]
            for i in 1 ..< users.count {
                writetxt += "\n" + users[i]
            }
            do {
                try writetxt.write(to: fileURL, atomically: false, encoding: .utf8)
            } catch {
                return "ファイル書き込みエラー"
            }
            
        }else{
        //user.txtが存在する場合はusersに読み込み
            let fileURL = dirURL.appendingPathComponent(userfilename)

            do {
                let text = try String(contentsOf: fileURL)
                users = text.components(separatedBy: "\n").filter{!$0.isEmpty}
                
            }catch {
                return "ファイル読み込みエラー"
            }
        }
        
        return "success"

    }
    
    /*==================book===================*/
    //json読み込み
    func bookLoad() -> String {
        
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        //ファイルが存在しない場合はsuccessを返す
        if !FileManager.default.fileExists(atPath: bookfilepath){
            return "success"
        }
        
        let fileURL = dirURL.appendingPathComponent(bookfilename)

        guard let data = try? Data(contentsOf: fileURL) else {
            return "JSON読み込みエラー"
        }
         
        let decoder = JSONDecoder()
        guard let bookdata = try? decoder.decode([Bookdata].self, from: data) else {
            return "JSONデコードエラー"
        }
        
        bookjson = bookdata
        
        return "success"
        
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
        
        //パース
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }
        
        titles = []
        authors = []
        publishers = []
        comments = []
        state = []
        images = []
        
        for _ in 0 ..< ids[ids.count - 1] + 1 {
            titles.append("")
            authors.append("")
            publishers.append("")
            comments.append("")
            state.append("")
            images.append("")
        }
        
        for book in bookjson {
            titles[book.id] = book.title
            authors[book.id] = book.author
            publishers[book.id] = book.publisher
            comments[book.id] = book.comment
            state[book.id] = book.state
            
            let fileURL = dirURL.appendingPathComponent(book.image)
            //ファイルが存在する場合はpathを代入
            if UIImage(contentsOfFile: fileURL.path) != nil {
                images[book.id] = fileURL.path
            }
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
        
        //json書き込み
        let result = save()
        
        if result != "success" {
            return result
        }
        
        return "success"
    }
    
    //jsonファイル書き込み
    func save() -> String {
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return "フォルダURL取得エラー"
        }

        let fileURL = dirURL.appendingPathComponent(bookfilename)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonValue = try? encoder.encode(bookjson) else {
            return "JSONエンコードエラー"
        }
         
        do {
            try jsonValue.write(to: fileURL)
        } catch {
            return "JSON書き込みエラー"
        }
        
        return "success"
    }

}
