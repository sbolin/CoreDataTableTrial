//
//  NoteCell.swift
//  CoreDataTableTrial
//
//  Created by Scott Bolin on 5/27/20.
//  Copyright © 2020 Scott Bolin. All rights reserved.
//

import UIKit

protocol NoteCellDelegate: class {
  func noteCell(_ cell: NoteCell, completionChanged completion: Bool)
}

class NoteCell: UITableViewCell {
  
  //MARK:- Properties
  public static let reuseIdentifier = "NoteCell"
  weak var noteCellDelegate: NoteCellDelegate?
  
  //MARK: - IBOutlets
  @IBOutlet weak var goalTitleLabel: UILabel!
  @IBOutlet weak var noteTextLabel: UILabel!
  @IBOutlet weak var dayCreatedLabel: UILabel!
  @IBOutlet weak var monthCreatedLabel: UILabel!
  @IBOutlet weak var completedButton: UIButton!
  
  
  //MARK: - View lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  //MARK: - Helper function
  func configureNoteCell(for note: Note) {

    let dayFormatter = DateFormatter()
    let monthFormatter = DateFormatter()
    dayFormatter.dateFormat = "dd"
    monthFormatter.dateFormat = "MMM"
    goalTitleLabel.text = note.goal.goalTitle
    noteTextLabel.text = note.noteText
    dayCreatedLabel.text = dayFormatter.string(from: note.noteDateCreated)
    monthCreatedLabel.text = monthFormatter.string(from: note.noteDateCreated)
    completedButton.isSelected = note.noteCompleted
    
    toggleButtonColor()
  }
  
  func toggleButtonColor() {
    completedButton.isSelected ? (completedButton.tintColor = .systemGreen) :
     (completedButton.tintColor = .systemGray6)
  }
  
  func handleCompletionCheck(for note: Note) {
    let completed = completedButton.isSelected
    if completed {
      CoreDataController.sharedManager.markNoteCompleted(completed: completed, note: note)
      completedButton.tintColor = .systemGreen
    } else {
      completedButton.tintColor = .systemGray6
    }
  }
  
  //MARK: - IBAction
  @IBAction func completedTapped(_ sender: UIButton) {
    completedButton.isSelected.toggle()
    toggleButtonColor()
    // update data model
    noteCellDelegate?.noteCell(self, completionChanged: completedButton.isSelected)
  }
}
