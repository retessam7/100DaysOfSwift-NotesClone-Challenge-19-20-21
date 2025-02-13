//
//  DetailViewController.swift
//  Project192021
//
//  Created by Aleksei Ivanov on 11/2/25.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var noteText: UITextView!
    var selectedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        noteText.text = selectedNote?.text
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote)),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote)),
        ]
        
        // ask to be told when the keyboard state changes by using a new class
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        noteText.becomeFirstResponder() // Открывает клавиатуру сразу
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // In this instance, it means that it passes the method on to UIViewController, which may do its own processing.
        navigationController?.hidesBarsOnTap = false
        
        selectedNote?.text = noteText.text
        
        // передать обновленную заметку обратно в контроллер списка (например, через делегат)
        if let note = selectedNote {
            // Передаем обновленный текст в родительский контроллер
            NotificationCenter.default.post(name: .didUpdateNote, object: note)
        }
    }
    
    @objc func deleteNote() {
        guard let note = selectedNote else { return }
        
        NotificationCenter.default.post(name: .didDeleteNote, object: note)
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareNote() {
        guard let note = selectedNote else { return }
        
        let vc = UIActivityViewController(activityItems: [note.text], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view)
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            noteText.contentInset = .zero
        } else {
            noteText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        noteText.scrollIndicatorInsets = noteText.contentInset
        
        let selectedRange = noteText.selectedRange
        noteText.scrollRangeToVisible(selectedRange)
        
    }
}

extension Notification.Name {
    static let didUpdateNote = Notification.Name("didUpdateNote")
    static let didDeleteNote = Notification.Name("didDeleteNote")
}

