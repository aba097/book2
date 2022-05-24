//
//  CollectionViewCell.swift
//  Book2
//
//  Created by 相場智也 on 2021/10/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var TitleTextView: UITextView!
    
    @IBOutlet weak var AuthorTextView: UITextView!

    @IBOutlet weak var PublisherTextView: UITextView!
    
    @IBOutlet weak var CommentTextView: UITextView!
    
    @IBOutlet weak var Button: UIButton!
    
    weak var vc: ViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        Button.addTarget(self, action: #selector(self.buttonEvent(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func buttonEvent(_ sender: UIButton) {
        vc.stateAction(sender)
    }
}
