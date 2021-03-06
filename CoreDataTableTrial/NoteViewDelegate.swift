//
//  NoteViewDelegate.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class NoteViewDelegate: NSObject, UITableViewDelegate {
  
  let fetchController = CoreDataController.shared.fetchedNoteResultsController

  //MARK: - UITableViewDelegate Methods
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let note = fetchController.object(at: indexPath)
    let goal = note.goal

    let alert = UIAlertController(title: "Update Goal",
                                  message: "Update Goal Contents",
                                  preferredStyle: .alert)
    
    alert.addTextField { (textFieldNoteTitle) in
      textFieldNoteTitle.placeholder = "Goal Title"
      textFieldNoteTitle.text = goal.goalTitle
    }
    alert.addTextField { (textFieldAttachment) in
      textFieldAttachment.placeholder = "Goal Contents"
      textFieldAttachment.text = note.noteText
      
      //UPDATE
      let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] action in
        guard let textFieldTitle = alert.textFields?[0],
          let goalTitleToSave = textFieldTitle.text else {
            return
        }
        guard let textFieldnoteText = alert.textFields?[1],
          let noteTextToSave = textFieldnoteText.text else {
            return
        }
        self.update(goalTitle: goalTitleToSave, noteText: noteTextToSave, at: indexPath)
      }
      
      //UPDATE
      let addNoteAction = UIAlertAction(title: "Add Note", style: .default) { [unowned self] action in
        guard let textFieldTitle = alert.textFields?[0],
          let goalTitleToSave = textFieldTitle.text else {
            return
        }
        guard let textFieldnoteText = alert.textFields?[1],
          let noteTextToSave = textFieldnoteText.text else {
            return
        }
        self.addNote(goalTitle: goalTitleToSave, noteText: noteTextToSave, at: indexPath)
      }
      
      //DELETE
      let deleteAction = UIAlertAction(title: "Delete", style: .default) { [unowned self] action in
        self.deleteGoal(goalToDelete: goal)
      }
      
      //CANCEL
      let cancelAction = UIAlertAction(title: "Cancel", style: .default)
      alert.addAction(updateAction)
      alert.addAction(addNoteAction)
      alert.addAction(cancelAction)
      alert.addAction(deleteAction)
      guard let viewController = tableView.findViewController() else { return }
      viewController.present(alert, animated: true)
      
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  func update(goalTitle: String, noteText: String, at indexPath: IndexPath) {
    CoreDataController.shared.updateGoal(updatedGoalTitle: goalTitle, updatedNoteText: noteText, at: indexPath)
  }
  
  func addNote(goalTitle: String, noteText: String, at indexPath: IndexPath) {
    CoreDataController.shared.addNote(text: noteText, at: indexPath)
  }
  
  func deleteGoal(goalToDelete: Goal) {
    CoreDataController.shared.deleteGoal(goal: goalToDelete)
  }
}

// MARK: - Helper
// extension from https://www.hackingwithswift.com/example-code/uikit/how-to-find-the-view-controller-responsible-for-a-view
extension UIView {
  func findViewController() -> UIViewController? {
    if let nextResponder = self.next as? UIViewController {
      return nextResponder
    } else if let nextResponder = self.next as? UIView {
      return nextResponder.findViewController()
    } else {
      return nil
    }
  }
}
