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
    
    @IBOutlet weak var ActivityIndicatorView: UIActivityIndicatorView!
    
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
        collectionmodel.setup()
    }
    
    func setDelegate(){
        SearchPickerView.delegate = self
        SortCategoryPickerView.delegate = self
        SortOrderPickerView.delegate = self
        
        SearchBar.delegate = self
        
        CollectionView.delegate = self
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
        
        return CGSize(width: self.view.bounds.width, height: 308)
    }
    
    //セルの内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? CollectionViewCell else{
            fatalError("Dequeue failed: AnimalTableViewCell.")
        }
        
        let bookdata = collectionmodel.bookdata
    
        //title
        cell.TitleTextView.text = bookdata.titles[bookdata.currentids[indexPath.row]]
       
        //writer
        cell.AuthorTextView.text = bookdata.authors[bookdata.currentids[indexPath.row]]
        
        //publisher
        cell.PublisherTextView.text = bookdata.publishers[bookdata.currentids[indexPath.row]]
    
        //comment
        cell.CommentTextView.text = bookdata.comments[bookdata.currentids[indexPath.row]]
        
        //借りている場合といない場合で背景色を変化させる, buttonの表示名を変更する
        if bookdata.state[bookdata.currentids[indexPath.row]] != "" {
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 5
            cell.Button.setTitle(bookdata.state[bookdata.currentids[indexPath.row]], for: .normal)
        }else{
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 5
            cell.Button.setTitle("Borrow", for: .normal)
        }

        cell.vc = self
        cell.Button.tag = bookdata.currentids[indexPath.row]
        
        return cell
    }
    
    //cell上のボタンを押したとき，貸し借りを変更する
    func stateAction(_ sender: UIButton) {
        
        let idx = sender.tag as Int
        //idxは本id
        //借りる
        if collectionmodel.bookdata.state[idx] == "" {
            
            
            //ユーザ一覧を再読み込みする
            loadUser(idx)
        
        }else{
            //返す
            let alert: UIAlertController = UIAlertController(title: "本を返します", message: collectionmodel.bookdata.state[idx], preferredStyle:  UIAlertController.Style.alert)
            
            let yesaction: UIAlertAction = UIAlertAction(title: "Yes", style: .default, handler:{
                (action: UIAlertAction!) -> Void in
                self.state("return", self.collectionmodel.bookdata.state[idx], idx)
            })
            
            alert.addAction(yesaction)
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                
            self.present(alert, animated: true, completion: nil)
            
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
    
    //認証ボタン
    @IBAction func AuthenticationAction(_ sender: Any) {
        //認証する
        //セマフォはサブスレッドに適用する. Main Threadに適用すると認証が止まってしまう
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
     
    }
    
    func loadUser(_ idx: Int){
        //グルグル表示
        ActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ファイルが存在するか確認
                self.collectionmodel.bookdata.userExist()
            }
            
            self.collectionmodel.bookdata.existSemaphore.wait()
            
            if self.collectionmodel.bookdata.existState == "doDownload" {
                DispatchQueue.main.async {
                    //ダウンロードし，bookdataに格納
                    self.collectionmodel.bookdata.userDownload()
                }
                //ダウンロード終了後
                self.collectionmodel.bookdata.downloadSemaphore.wait()
                
                if self.collectionmodel.bookdata.downloadState != "success" { //error
                    DispatchQueue.main.sync {
                        self.ActivityIndicatorView.stopAnimating()
            
                        let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.downloadState, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{
                    DispatchQueue.main.sync {
                        self.ActivityIndicatorView.stopAnimating()
                        //ユーザ一覧表示
                        self.presentAlert(idx)
                    }
                    
                }
            }else if self.collectionmodel.bookdata.existState == "notExist" {
                //defaultuserを用意する
                self.collectionmodel.bookdata.users = ["user0", "user1", "user2", "user3", "user4", "use5", "user6", "user7", "user8", "user9", "user10", "user11", "user12", "user13", "user14", "user15"]
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    //ユーザ一覧表示
                    self.presentAlert(idx)
                }
            }else { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
           
    }
    
    func presentAlert(_ idx: Int){
        let alert: UIAlertController = UIAlertController(title: "ユーザを選択してください", message:  "", preferredStyle:  UIAlertController.Style.alert)
        
        let user0: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[0], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[0], idx)
        })
        let user1: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[1], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[1], idx)
        })
        let user2: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[2], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[2], idx)
        })
        let user3: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[3], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[3], idx)
        })
        let user4: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[4], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[4], idx)
        })
        let user5: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[5], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[5], idx)
        })
        let user6: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[6], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[6], idx)
        })
        let user7: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[7], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[7], idx)
        })
        let user8: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[8], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[8], idx)
        })
        let user9: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[9], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[9], idx)
        })
        let user10: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[10], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[10], idx)
        })
        let user11: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[11], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[11], idx)
        })
        let user12: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[12], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[12], idx)
        })
        let user13: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[13], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[13], idx)
        })
        let user14: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[14], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[14], idx)
        })
        let user15: UIAlertAction = UIAlertAction(title: collectionmodel.bookdata.users[15], style: .default, handler:{
            (action: UIAlertAction!) -> Void in
            self.state("borrow", self.collectionmodel.bookdata.users[15], idx)
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

    }
    
    //本の貸し借りを変更する
    func state(_ action: String, _ user: String, _ idx: Int){
        //グルグル表示
        ActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
            //ダウンロードし，bookjsonに格納
            self.collectionmodel.bookdata.bookDownload()
            }
            //ダウンロード終了後
            self.collectionmodel.bookdata.downloadSemaphore.wait()
            
            if self.collectionmodel.bookdata.downloadState != "success" { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
        
                    let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            //本の貸し借りを変更する
            let result = self.collectionmodel.bookdata.borrowreturnAction(action, user, idx)
            if result != "success" { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    let alert = UIAlertController(title: "error", message: result, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }else{ //貸し借り正常に変更
                DispatchQueue.main.async {
                    //bookjsonをアップロード
                    self.collectionmodel.bookdata.bookUpload()
                }
                self.collectionmodel.bookdata.uploadSemaphore.wait()
                
                //アラートの表示はメインスレッドで行う
                DispatchQueue.main.sync {
                    //グルグル非表示
                    self.ActivityIndicatorView.stopAnimating()
                    
                    if self.collectionmodel.bookdata.uploadState !=  "success" { //error
                        let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.uploadState, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        //アップロード成功
                        let alert = UIAlertController(title: "success", message: "", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                        //再読み込み
                        self.loadBook()
                    }
                }
            }
        }
    }
    
    func loadBook(){
        //グルグル表示
        ActivityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async {
                //ファイルが存在するか確認
                self.collectionmodel.bookdata.bookExist()
            }
            self.collectionmodel.bookdata.existSemaphore.wait()
            
            if self.collectionmodel.bookdata.existState == "doDownload" {
                DispatchQueue.main.async {
                    //ダウンロードし，bookjsonに格納
                    self.collectionmodel.bookdata.bookDownload()
                }
                //ダウンロード終了後
                self.collectionmodel.bookdata.downloadSemaphore.wait()
                
                if self.collectionmodel.bookdata.downloadState != "success" { //error
                    DispatchQueue.main.sync {
                        self.ActivityIndicatorView.stopAnimating()
            
                        let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.downloadState, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true, completion: nil)
                    }
                }else{ //ダウンロード成功
                    DispatchQueue.main.sync {
                        self.collectionmodel.bookdata.setDiplayData(searchtext: self.SearchBar.text, searchtarget: self.searchpicker.getTarget(), sortcategorytarget: self.sortcategorypicker.getCategoryTarget(), sortordertarget: self.sortorderpicker.getOrderTarget())
                        self.collectionmodel.CollectionView.reloadData()
                        self.ActivityIndicatorView.stopAnimating()
                    }
                }
            }else if self.collectionmodel.bookdata.existState == "notExist" {
                //空のbookjsonを用意する
                self.collectionmodel.bookdata.bookjson = []
                
                DispatchQueue.main.sync {
                    self.collectionmodel.bookdata.setDiplayData(searchtext: self.SearchBar.text, searchtarget: self.searchpicker.getTarget(), sortcategorytarget: self.sortcategorypicker.getCategoryTarget(), sortordertarget: self.sortorderpicker.getOrderTarget())
                    self.collectionmodel.CollectionView.reloadData()
                    self.ActivityIndicatorView.stopAnimating()
                }
                
            }else { //error
                DispatchQueue.main.sync {
                    self.ActivityIndicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "error", message: self.collectionmodel.bookdata.downloadState, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}

