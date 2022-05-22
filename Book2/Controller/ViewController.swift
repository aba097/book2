//
//  ViewController.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import UIKit
import SwiftyDropbox

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
    let dropboxmodel = DropBoxModel.shared

    private let collectionmodel = CollectionModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setDelegate()
        
        collectionmodel.vc = self
        collectionmodel.CollectionView = self.CollectionView
        dropboxmodel.vc = self
        fileLoadAlert(collectionmodel.setup())
    }
    
    func setDelegate(){
        SearchPickerView.delegate = self
        SortCategoryPickerView.delegate = self
        SortOrderPickerView.delegate = self
        
        SearchBar.delegate = self
        
        CollectionView.delegate = self
    }
    
    //ファイル読み込み時のエラーをAlertする
    func fileLoadAlert(_ msg: String){
        
        if msg != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: msg, preferredStyle: .alert)
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
        fileLoadAlert(collectionmodel.refresh())
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
        
        //借りている場合といない場合で背景色を変化させる
        if bookdata.state[bookdata.currentids[indexPath.row]] != "" {
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
    
        return cell
    }
    
    //cell Long Press イベント 本の貸し借り
    @objc func longPress(_ sender: UILongPressGestureRecognizer){
      
        //長押し時
        if sender.state == .began {
            
            let idx = sender.view!.tag as Int
            //idxは本id
            //借りる
            if collectionmodel.bookdata.state[idx] == "" {
                
                //ユーザ一覧を再読み込みする
                let msg = collectionmodel.bookdata.userLoad()
                if msg != "success" {
                    //alert
                    let alert = UIAlertController(title: "error", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                //アラート生成
                let alert: UIAlertController = UIAlertController(title: "ユーザを選択してください", message:  "", preferredStyle:  UIAlertController.Style.alert)
                
                let user0: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[0], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[0], idx))
                })
                let user1: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[1], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[1], idx))
                })
                let user2: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[2], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[2], idx))
                })
                let user3: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[3], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[3], idx))
                })
                let user4: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[4], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[4], idx))
                })
                let user5: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[5], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[5], idx))
                })
                let user6: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[6], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[6], idx))
                })
                let user7: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[7], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[7], idx))
                })
                let user8: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[8], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[8], idx))
                })
                let user9: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[9], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[9], idx))
                })
                let user10: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[10], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[10], idx))
                })
                let user11: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[11], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[11], idx))
                })
                let user12: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[12], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[12], idx))
                })
                let user13: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[13], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[13], idx))
                })
                let user14: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[14], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[14], idx))
                })
                let user15: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[15], style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.borrowreturnAction("borrow", self.collectionmodel.bookdata.users[15], idx))
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
                let alert: UIAlertController = UIAlertController(title: "本を返します", message: collectionmodel.bookdata.state[idx], preferredStyle:  UIAlertController.Style.alert)
                
                let yesaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                    (action: UIAlertAction!) -> Void in
                    self.borrowreturnAlert(self.collectionmodel.bookdata.borrowreturnAction("return", self.collectionmodel.bookdata.state[idx], idx))
                })
                
                alert.addAction(yesaction)
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                    
                self.present(alert, animated: true, completion: nil)
                
            }
            
        }
        
    }
    
    func borrowreturnAlert(_ msg: String) {
        if msg != "success" {
            //alert
            let alert = UIAlertController(title: "error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "success", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func Download(){
        //bookdata.jsonとhistory.jsonをダウンロードする
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ダウンロード
                // 認証をセマフォでデットロックしてしまうためMain Threadで実行する
                self.dropboxmodel.download()
            }
            //sginalはダウンロードが終了後行われる
            self.dropboxmodel.downloadSemaphore.wait()
            //アラートの表示はメインスレッドで行う
            DispatchQueue.main.sync {
                if self.dropboxmodel.downloadState != "success" {
                    let alert = UIAlertController(title: "error", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: self.dropboxmodel.downloadState, style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
        
    //認証ボタン
    @IBAction func AuthenticationAction(_ sender: Any) {
        //認証を確認する
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
        //未ログイン
      //  if DropboxClientsManager.authorizedClient == nil {
            DispatchQueue.global(qos: .default).async {
                DispatchQueue.main.async {
                    //認証
                    // 認証をセマフォでデットロックしてしまうためMain Threadで実行する
                    self.dropboxmodel.authentication()
                }
                //sginalは認証が終了後SceneDelegate.swiftで行われる
                self.dropboxmodel.authSemaphore.wait()
                //アラートの表示はメインスレッドで行う
                DispatchQueue.main.sync {
                    if self.dropboxmodel.authState {
                        let alert = UIAlertController(title: "success", message: "認証成功", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = UIAlertController(title: "error", message: "認証失敗", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        //ログイン済み
       // }else{
       //     let alert = UIAlertController(title: "success", message: "認証済み", preferredStyle: .alert)
       //     alert.addAction(UIAlertAction(title: "OK", style: .default))
       //     self.present(alert, animated: true, completion: nil)
      // }
    }
    
}

