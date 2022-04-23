//
//  ViewController.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
 
    

    @IBOutlet weak var SearchBar: UISearchBar!

    @IBOutlet weak var SearchPickerView: UIPickerView!
    
    @IBOutlet weak var SortCategoryPickerView: UIPickerView!
    
    @IBOutlet weak var SortOrderPickerView: UIPickerView!
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    //インスタンス化
    let searchpicker = SearchPickerModel()
    let sortcategorypicker = SortCategoryPickerModel()
    let sortorderpicker = SortOrderPickerModel()

    private let collectionmodel = CollectionModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setDelegate()
        
        collectionmodel.vc = self
        collectionmodel.CollectionView = self.CollectionView
        fileloadAlert(collectionmodel.setup())
        
        //共有フォルダを表示させるだけの関数
        //testsave()
    }
    
    //共有フォルダを表示させるだけの関数
    func testsave(){
        //file
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileUrl = dir.appendingPathComponent("test.txt")
        
        let originaltext = "aaa"
    
    
        do {
            try originaltext.write(to: fileUrl, atomically: false, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func setDelegate(){
        SearchPickerView.delegate = self
        SortCategoryPickerView.delegate = self
        SortOrderPickerView.delegate = self
        
        SearchBar.delegate = self
        
        CollectionView.delegate = self
    }
    
    //ファイル読み込み時のエラーをAlertする
    func fileloadAlert(_ msg: String){
        var alertMsg = ""
        
        switch msg {
        case "readErrorId" :
            alertMsg = "Adminファイルが読み込めませんでした"
        case "datanum0" :
            alertMsg = "Adminファイルのデータ数が0件です"
        case "readErrorTitle" :
            alertMsg = "Titleファイルが読み込めませんでした"
        case "readErrorAuthor" :
            alertMsg = "Authorファイルが読み込めませんでした"
        case "readErrorPublisher" :
            alertMsg = "Publisherファイルが読み込めませんでした"
        case "readErrorBorrowreturn" :
            alertMsg = "Borrowreturnファイルが読み込めませんでした"
        case "readErrorUser" :
            alertMsg = "userファイルが読み込めませんでした"
        default: break
        }
        
        if msg != "fileloadsuccess" {
            //alert
            let alert = UIAlertController(title: "error", message: alertMsg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
    }
  
    
    /*-------------------UIPicker-----------------------------------*/
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //UIPickerViewの項目数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 0:
            return searchpicker.getSize()
        case 1:
            return sortcategorypicker.getSize()
        case 2:
            return sortorderpicker.getSize()
        default:
            return 1
        }
    }
    
    //UIPickerViewの内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        
        switch pickerView.tag {
        case 0:
            return searchpicker.getElement(row)
        case 1:
            return sortcategorypicker.getElement(row)
        case 2:
            return sortorderpicker.getElement(row)
        default:
            return "error"
        }
    }
    
    //UIPickerViewで現在選択しているもの
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        switch pickerView.tag {
        case 0:
            searchpicker.setTarget(searchpicker.getElement(row))
        case 1:
            sortcategorypicker.setCategoryTarget(sortcategorypicker.getElement(row))
        case 2:
            sortorderpicker.setOrderTarget(sortorderpicker.getElement(row))
        default: break
            
        }
        
        
    }
    
    /*-------------------UISearchBar-----------------------------------*/
    //uisearchbar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        view.endEditing(true)
        
        collectionmodel.refresh()
    }
    

    /*-------------------UICollectionView-----------------------------------*/
    //表示するセルの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionmodel.bookdata.currentids.count // 表示するセルの数
    }
    
    //layout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.bounds.width, height: 263)
    }
    
    //セルの内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        
        
        let bookdata = collectionmodel.bookdata
      
        //image
        if bookdata.images[bookdata.currentids[indexPath.row]] != "" {
            cell.ImageView.image = UIImage(contentsOfFile: bookdata.images[bookdata.currentids[indexPath.row]])
        }else{
            cell.ImageView.image = nil
        }
        
        //title
        cell.TitleTextView.text = bookdata.titles[bookdata.currentids[indexPath.row]]
       
        //writer
        cell.AuthorTextView.text = bookdata.authors[bookdata.currentids[indexPath.row]]
        
        //publisher
        cell.PublisherTextView.text = bookdata.publishers[bookdata.currentids[indexPath.row]]
    
        //comment
        cell.CommentTextView.text = bookdata.comments[bookdata.currentids[indexPath.row]]
        
        if bookdata.borrowreturns[bookdata.currentids[indexPath.row]] != -1 {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 5
        }else{
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 5
        }

        cell.tag = bookdata.currentids[indexPath.row]
        
    
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPressGesture.delegate = self
        cell.addGestureRecognizer(longPressGesture)
        
        
        
        collectionmodel.cells.append(cell)
    
        return cell
    }
    
    //cell Long Press イベント 本の貸し借り
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
      
        //長押し時
        if sender.state == .began {
            
            let idx = sender.view!.tag as Int
            
            //借りる
            if collectionmodel.bookdata.borrowreturns[idx] == -1 {
                //アラート生成
                let alert: UIAlertController = UIAlertController(title: "ユーザを選択してください", message:  "", preferredStyle:  UIAlertController.Style.alert)
                
                let user0: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[0], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 0, idx))
                })
                let user1: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[1], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 1, idx))
                })
                let user2: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[2], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 2, idx))
                })
                let user3: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[3], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 3, idx))
                })
                let user4: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[4], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 4, idx))
                })
                let user5: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[5], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 5, idx))
                })
                let user6: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[6], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 6, idx))
                })
                let user7: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[7], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 7, idx))
                })
                let user8: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[8], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 8, idx))
                })
                let user9: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[9], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 9, idx))
                })
                let user10: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[10], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 10, idx))
                })
                let user11: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[11], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 11, idx))
                })
                let user12: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[12], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 12, idx))
                })
                let user13: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[13], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 13, idx))
                })
                let user14: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[14], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 14, idx))
                })
                let user15: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[15], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("borrow", user: 15, idx))
                })
                
                alert.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
                alert.addAction(user0)
                alert.addAction(user1)
                alert.addAction(user2)
                alert.addAction(user3)
                alert.addAction(user4)
                alert.addAction(user5)
                alert.addAction(user6)
                alert.addAction(user7)
                alert.addAction(user8)
                alert.addAction(user9)
                alert.addAction(user10)
                alert.addAction(user11)
                alert.addAction(user12)
                alert.addAction(user13)
                alert.addAction(user14)
                alert.addAction(user15)
                
                present(alert, animated: true, completion: nil)
                
            
            }else{
                //返す
                let alert: UIAlertController = UIAlertController(title: String(collectionmodel.bookdata.users[collectionmodel.bookdata.borrowreturns[idx]]) + "本を返します", message:  "", preferredStyle:  UIAlertController.Style.alert)
                
                let yesaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("return", user: self.collectionmodel.bookdata.borrowreturns[idx], idx))
                })
                
                alert.addAction(yesaction)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func borrowreturnAlert(_ msg: String) {
        var alertTitle = "error"
        var alertMsg = ""
        
        switch msg {
        case "readErrorAdmin" :
            alertMsg = "Adminファイルが読み込めませんでした"
        case "bookNotFound" :
            alertMsg = "本ファイルが存在しません"
        case "readErrorBorrowreturn" :
            alertMsg = "貸し借り管理ファイルが読み込めませんでした"
        case "alreadyChanged" :
            alertMsg = "本の貸し借り状況がすでに変更されています"
        case "writeErrorBorrowreturn" :
            alertMsg = "貸し借り管理ファイルの書き込みに失敗しました"
        case "borrow" :
            alertTitle = "sucess"
            alertMsg = "借りました"
        case "return" :
            alertTitle = "sucess"
            alertMsg = "返しました"
        default:
            alertMsg = "未対応のエラー"
        }
       
        //alert
        let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
        
    }
        
    //同期ボタン
    @IBAction func updateAction(_ sender: Any) {
        let result = collectionmodel.bookdata.fileoperations.fileload(&collectionmodel.bookdata)
        print(result)
        collectionmodel.refresh()
    }
    
}

