//
//  Data Model.swift
//  Notes Manager
//
//  Created by Akash Ungarala on 10/11/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import Foundation

extension NSDate {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
}

struct Note {
    var id: String!
    var description: String!
    var created: NSTimeInterval!
}

struct Notebook {
    var id: String!
    var title: String!
    var created: NSTimeInterval!
    var updated: NSTimeInterval!
}