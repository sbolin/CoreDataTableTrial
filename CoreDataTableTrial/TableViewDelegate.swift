//
//  TableViewDelegate.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/24/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit
import CoreData

class TableViewDelegate: NSObject, UITableViewDelegate {
  
  let fetchController = CoreDataController.sharedManager.fetchedResultsController
  
  //MARK: - UITableViewDelegate Methods
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 64
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    print("didSelectRowAt called at \(indexPath.row)")
    
    let goal = fetchController.object(at: indexPath)
    
    print("didSelectRowAt Goal object: \(goal)")
    
    let alert = UIAlertController(title: "Update Goal",
                                  message: "Update Goal Contents",
                                  preferredStyle: .alert)
    
    alert.addTextField { (textFieldNoteTitle) in
      textFieldNoteTitle.placeholder = "Goal Title"
      textFieldNoteTitle.text = goal.value(forKeyPath: #keyPath(Goal.goalTitle)) as? String
    }
    alert.addTextField { (textFieldAttachment) in
      textFieldAttachment.placeholder = "Goal Contents"
      textFieldAttachment.text = goal.value(forKeyPath: #keyPath(Goal.notes.noteText)) as? String
      //UPDATE
      let updateAction = UIAlertAction(title: "Update", style: .default) { [unowned self] action in
        guard let textFieldTitle = alert.textFields?[0],
          let goalToSave = textFieldTitle.text else {
            return
        }
        guard let textFieldnoteText = alert.textFields?[1],
          let noteTextToSave = textFieldnoteText.text else {
            return
        }
        self.update(goalTitle: goalToSave, noteText: noteTextToSave, goalToUpdate: goal, at: indexPath)
      }
      
      //DELETE
      let deleteAction = UIAlertAction(title: "Delete", style: .default) { [unowned self] action in
        self.deleteGoal(goalToDelete: goal)
      }
      
      //CANCEL
      let cancelAction = UIAlertAction(title: "Cancel", style: .default)
      alert.addAction(updateAction)
      alert.addAction(cancelAction)
      alert.addAction(deleteAction)
      guard let viewController = tableView.findViewController() else { return }
      viewController.present(alert, animated: true)
      
    }
  }
  
  func update(goalTitle: String, noteText: String, goalToUpdate: Goal, at indexPath: IndexPath) {
    print("update goal from TableViewDelegate")
    CoreDataController.sharedManager.updateGoal(title: goalTitle, noteText: noteText, goal: goalToUpdate, at: indexPath)
  }
  
  func deleteGoal(goalToDelete: Goal) {
    print("deleteGoal from TableViewDelegate")
    CoreDataController.sharedManager.deleteGoal(goal: goalToDelete)
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
