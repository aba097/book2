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
    
}
