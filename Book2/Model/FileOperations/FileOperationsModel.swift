//
//  FileOperationsModel.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/26.
//

import Foundation
import UIKit

class FileOperationsModel{
    
    //FUTURE セマフォを追加する icloud時
    
    func fileload(_ data: inout BookDataModel) -> String{
        //file
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //admin idを管理
        var fileUrl = dir.appendingPathComponent("admin.txt")
        
        data.ids = []
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            for tmp in arr {
                data.ids.append(Int(tmp)!)
            }
        } catch {
            print("Error: \(error)")
            return "readErrorId"
        }
        
        if data.ids.count == 0 {
            //データが1件もない
            return "datanum0"
        }
        
        //title
        fileUrl = dir.appendingPathComponent("title.txt")
        
        data.titles = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 {
            data.titles.append("")
        }
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            
            for i in stride(from: 0, to: arr.count, by: 2) {
                data.titles[Int(arr[i])!] = arr[i + 1]
            }
        } catch {
            print("Error: \(error)")
            return "readErrorTitle"
        }
        
        //author
        fileUrl = dir.appendingPathComponent("author.txt")
        
        data.authors = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 {
            data.authors.append("")
        }
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            
            for i in stride(from: 0, to: arr.count, by: 2) {
                data.authors[Int(arr[i])!] = arr[i + 1]
            }
        } catch {
            print("Error: \(error)")
            return "readErrorAuthor"
        }
        
        //publisher
        fileUrl = dir.appendingPathComponent("publisher.txt")
        
        data.publishers = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 {
            data.publishers.append("")
        }
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            
            for i in stride(from: 0, to: arr.count, by: 2) {
                data.publishers[Int(arr[i])!] = arr[i + 1]
            }
        } catch {
            print("Error: \(error)")
            return "readErrorPublisher"
        }
        
        //borrowreturn
        fileUrl = dir.appendingPathComponent("borrowreturn.txt")
  
        data.borrowreturns = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 { //adminが1からのため
            data.borrowreturns.append(0)
        }
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            
            for i in stride(from: 0, to: arr.count, by: 2) {
                let split = arr[i + 1].components(separatedBy: " ")
                if Int(split[0])! == 1 {
                    data.borrowreturns[Int(arr[i])!] = Int(split[1])!
                }else{
                    data.borrowreturns[Int(arr[i])!] = -1
                }
            }
        }catch {
            print("Error: \(error)")
            return "readErrorBorrowreturn"
        }
        
        //Comment
        data.comments = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 {
            data.comments.append("")
        }
        
        for i in 0 ..< data.ids.count {
            fileUrl = dir.appendingPathComponent(String(data.ids[i]) + ".txt")
            do {
                data.comments[data.ids[i]] = try String(contentsOf: fileUrl)
            }catch {
                //本idに対応するcommentファイルが存在しない
            }
        }
        
        //Image
        data.images = []
        for _ in 0 ..< data.ids[data.ids.count - 1] + 1 { //adminが1からのため
            data.images.append("")
        }
        
        for i in 0 ..< data.ids.count {
            fileUrl = dir.appendingPathComponent(String(data.ids[i]) + ".jpeg")
            if UIImage(contentsOfFile: fileUrl.path) != nil {
                data.images[data.ids[i]] = fileUrl.path
            }
        }
        
        //user file
        fileUrl = dir.appendingPathComponent("user.txt")

        do {
            let tmp = try String(contentsOf: fileUrl)
            data.users = tmp.components(separatedBy: "\n").filter{!$0.isEmpty}
        } catch {
            print("Error: \(error)")
            return "readErrorUser"
        }
        
        return "fileloadsuccess"
        
    }
    
    
    
    func fileloadAdmin(_ data: inout [Int]) -> String{
        //file
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        //admin idを管理
        let fileUrl = dir.appendingPathComponent("admin.txt")
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            for tmp in arr {
                data.append(Int(tmp)!)
            }
        } catch {
            print("Error: \(error)")
            return "readErrorAdmin"
        }
        
        return "fileloadAdminsuccess"
    }
    
    
    
    func fileloadBorrowreturn(_ idx: Int, _ checktarget: inout Int, _ size: Int) -> String{
        //file
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileUrl = dir.appendingPathComponent("borrowreturn.txt")
  
        var data: [Int] = []
        
        for _ in 0 ..< size { //adminが1からのため
            data.append(0)
        }
        
        do {
            let text = try String(contentsOf: fileUrl)
            let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
            
            for i in stride(from: 0, to: arr.count, by: 2) {
                let split = arr[i + 1].components(separatedBy: " ")
                if Int(split[0])! == 1 {
                    data[Int(arr[i])!] = Int(split[1])!
                }else{
                    data[Int(arr[i])!] = -1
                }
            }
        }catch {
            print("Error: \(error)")
            return "readErrorBorrowreturn"
        }
        
        checktarget = data[idx]
        
        return "fileloadBorrowreturnsuccess"
    }
    
    
    
    func filesaveBorrowreturn(_ data: inout [Int], _ ids: inout [Int]) -> String{
        //file
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileUrl = dir.appendingPathComponent("borrowreturn.txt")
        
        var writetext = ""
        
        //write borrowreturn
        for i in 0 ..< data.count {
            
            if ids.firstIndex(of: i) == nil {continue}
            
            if data[i] == -1 {
                writetext += ("\n" + String(i) + "\n0 ")
            }else {
                writetext += ("\n" + String(i) + "\n1 " + String(data[i]))
            }
        }
        
        do {
            try writetext.write(to: fileUrl, atomically: false, encoding: .utf8)
        } catch {
            print("Error: \(error)")
            return "writeErrorBorrowreturn"
        }
        
        return "filesaveBorrowretrunsucess"
    }
    
}
