//
//  DropBoxModel.swift
//  Book2
//
//  Created by 相場智也 on 2022/05/15.
//

import Foundation
import SwiftyDropbox

class  DropBoxModel {
    
    //シングルトン
    static let shared = DropBoxModel()
    
    weak var vc: ViewController!
   
    //セマフォ　認証結果を待つ
    let authSemaphore = DispatchSemaphore(value: 0)
    //認証結果
    var authState = false
    
    //セマフォ
    let downloadSemaphore = DispatchSemaphore(value: 0)
    var downloadState = ""
    
    //認証表示
    func authentication(){
        //認証を行う
        //認証結果はSceneDelegate.swiftに返され，stateに格納
        // OAuth 2 code flow with PKCE that grants a short-lived token with scopes, and performs refreshes of the token automatically.
        let scopeRequest = ScopeRequest(scopeType: .user, scopes: ["account_info.read", "files.metadata.write", "files.metadata.read", "files.content.write", "files.content.read"], includeGrantedScopes: false)
        DropboxClientsManager.authorizeFromControllerV2(
            UIApplication.shared,
            controller: vc,
            loadingStatusDelegate: nil,
            openURL: { (url: URL) -> Void in UIApplication.shared.open(url, options: [:], completionHandler: nil) },
            scopeRequest: scopeRequest
        )
    }
    
    
    func download() {
    
        
        //bookdata.jsonのみならず，history.jsonをし，場合によってimage.jpegもダウンロードする
        guard let client = DropboxClientsManager.authorizedClient else {
            downloadState = "認証をしてください"
            return
        }
        
        // Download to Data
        client.files.download(path: "/test/aaa.jpeg")
            .response { response, error in
                if let response = response {
                    
                    let responseMetadata = response.0
                    print(responseMetadata)
                    
                    let fileContents = response.1
                    //print( String(data: fileContents, encoding: .utf8)!)
                    
                    let image = UIImage(data: fileContents)
                    //画像保存
                    guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                        self.downloadState = "フォルダURL取得エラー"
                        return
                    }
                    let fileURL = dirURL.appendingPathComponent(response.0.name)
                    do {
                        try image?.jpegData(compressionQuality: 0.8)?.write(to: fileURL)
                    }catch{
                    }
                    print("YESSS")
                    self.downloadState = "success"
                    self.downloadSemaphore.signal()
                } else if let error = error {
                    print("NOOOO")
                    print(error)
                    self.downloadState = "ダウンロード失敗"
                    self.downloadSemaphore.signal()
                }
            }
            .progress { progressData in
                print(progressData)
            }
 
    }
        
    func DownloadUser() -> String{
        return ""
    }
    
    
}
