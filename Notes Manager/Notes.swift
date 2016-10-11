//
//  Notes.swift
//  Notes Manager
//
//  Created by Akash Ungarala on 10/11/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class Notes: UITableViewController {
    
    var notebook: Notebook!
    var ref: FIRDatabaseReference!
    var notes = [Note]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = notebook.title
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getNotes()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notecell", forIndexPath: indexPath) as! NoteCell
        cell.noteDescription.text = notes[indexPath.row].description
        cell.created.text = "Created at \(format(notes[indexPath.row].created))"
        cell.deleteNote.tag = indexPath.row
        cell.deleteNote.addTarget(self, action: "deleteNote:", forControlEvents: .TouchUpInside)
        return cell
    }
    
    @IBAction func addNewNote(sender: AnyObject) {
        let input = UIAlertController(title: "New Note", message: "Enter New Note Description", preferredStyle: UIAlertControllerStyle.Alert)
        input.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        input.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            let textField = input.textFields![0] as UITextField
            self.pushtoFirebase(textField.text! as String)
        }))
        input.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Note Description"
        }
        input.view.setNeedsLayout()
        self.presentViewController(input, animated: true, completion: nil)
    }
    
    func getNotes() {
        notes.removeAll()
        ref.observeEventType(.ChildAdded, withBlock: { snapshot in
            var note = Note()
            note.id = snapshot.value?.objectForKey("id") as! String
            note.description = snapshot.value?.objectForKey("description") as! String
            note.created = snapshot.value?.objectForKey("created") as! NSTimeInterval
            self.notes.insert(note, atIndex: 0)
            self.tableView.reloadData()
        })
        self.tableView.reloadData()
    }
    
    func deleteNote(sender: UIButton!) {
        let input = UIAlertController(title: "Note Delete", message: "Do you want to delete this note?", preferredStyle: UIAlertControllerStyle.Alert)
        input.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: nil))
        input.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action) -> Void in
            let notebooksRef = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("notebooks")
            notebooksRef.child(self.notebook.id).child("updated").setValue(FIRServerValue.timestamp())
            self.ref.child(self.notes[sender.tag].id!).setValue(nil)
            self.notes.removeAtIndex(sender.tag)
            self.tableView.reloadData()
        }))
        input.view.setNeedsLayout()
        self.presentViewController(input, animated: true, completion: nil)
    }
    
    func pushtoFirebase(text: String) {
        if text != "" {
            let notebooksRef = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!).child("notebooks")
            notebooksRef.child(self.notebook.id).child("updated").setValue(FIRServerValue.timestamp())
            let noteRef = ref.childByAutoId()
            noteRef.setValue(["id": noteRef.key, "description": text, "created": FIRServerValue.timestamp()])
            self.tableView.reloadData()
        }
    }
    
    private func format(myTimeStamp: NSTimeInterval) -> String {
        let date = NSDate(timeIntervalSince1970:myTimeStamp/1000)
        return date.dateStringWithFormat("EEE, d MMM yyyy HH:mm:ss")
    }
    
}