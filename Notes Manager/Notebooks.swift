//
//  Notebooks.swift
//  Notes Manager
//
//  Created by Akash Ungarala on 10/11/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class Notebooks: UITableViewController {
    
    let ref = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("notebooks")
    var notebooks = [Notebook]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getNotebooks()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notebooks.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notebookcell", forIndexPath: indexPath) as! NotebookCell
        cell.notebookTitle.text = notebooks[indexPath.row].title
        format(notebooks[indexPath.row].created)
        cell.created.text = "Created at \(format(notebooks[indexPath.row].created))"
        cell.updated.text = "Updated at \(format(notebooks[indexPath.row].updated))"
        cell.deleteNotebook.tag = indexPath.row
        cell.deleteNotebook.addTarget(self, action: "deleteNotebook:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    @IBAction func addNewNoteBook(sender: AnyObject) {
        let input = UIAlertController(title: "New Notebook", message: "Enter Notebook Title", preferredStyle: UIAlertControllerStyle.Alert)
        input.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        input.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            let textField = input.textFields![0] as UITextField
            self.pushtoFirebase(textField.text! as String)
        }))
        input.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Notebook Title"
        }
        input.view.setNeedsLayout()
        self.presentViewController(input, animated: true, completion: nil)
    }
    
    func getNotebooks() {
        notebooks.removeAll()
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            var notebook = Notebook()
            notebook.id = snapshot.value?.objectForKey("id") as! String
            notebook.title = snapshot.value?.objectForKey("title") as! String
            notebook.created = snapshot.value?.objectForKey("created") as! NSTimeInterval
            notebook.updated = snapshot.value?.objectForKey("updated") as! NSTimeInterval
            self.notebooks.insert(notebook, atIndex: 0)
            self.tableView.reloadData()
        })
        self.tableView.reloadData()
    }
    
    func deleteNotebook(sender: UIButton!) {
        let input = UIAlertController(title: "Notebook Delete", message: "Do you want to delete this notebook?", preferredStyle: UIAlertControllerStyle.Alert)
        input.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        input.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            self.ref.child(self.notebooks[sender.tag].id!).setValue(nil)
            self.notebooks.removeAtIndex(sender.tag)
            self.tableView.reloadData()
        }))
        input.view.setNeedsLayout()
        self.presentViewController(input, animated: true, completion: nil)
    }
    
    func pushtoFirebase(text: String) {
        if text != "" {
            let noteRef = ref.childByAutoId()
            noteRef.setValue(["id": noteRef.key, "title": text, "created": FIRServerValue.timestamp(), "updated": FIRServerValue.timestamp()])
            self.tableView.reloadData()
        }
    }
    
    private func format(myTimeStamp: NSTimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970:myTimeStamp/1000)
        return date.dateStringWithFormat("EEE, d MMM yyyy HH:mm:ss")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? Notes {
            let notebook = notebooks[(self.tableView.indexPathForSelectedRow?.row)!]
            destination.notebook = notebook
            destination.ref = ref.child(notebook.id!).child("notes")
        }
    }
    
    @IBAction func backToNotebooks(sender: UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
}