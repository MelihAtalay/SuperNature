//
//  CommentCellview.swift
//  SuperNature
//
//  Created by Melih Atalay on 5.05.2024.
//

import UIKit
import Firebase

import FirebaseFirestore

class CommentCellview: UITableViewCell {
   
    
    @IBOutlet weak var profileInfo: UIImageView!
    
    
    @IBOutlet weak var UserInfo: UILabel!
    
    @IBOutlet weak var Comment: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        profileInfo.layer.cornerRadius = profileInfo.frame.size.width / 2
        profileInfo.clipsToBounds = true
     
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

 
    }
    
    
    
    
    
    

}
