//
//  NotebookCell.swift
//  Notes Manager
//
//  Created by Akash Ungarala on 10/11/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit

class NotebookCell: UITableViewCell {
    
    @IBOutlet weak var notebookTitle: UILabel!
    @IBOutlet weak var created: UILabel!
    @IBOutlet weak var updated: UILabel!
    @IBOutlet weak var deleteNotebook: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}