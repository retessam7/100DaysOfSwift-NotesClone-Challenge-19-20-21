//
//  ViewController.swift
//  Project192021
//
//  Created by Aleksei Ivanov on 11/2/25.
//

import UIKit

class ViewController: UITableViewController {
    var notes = [Note]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        // Подписываемся на уведомление об обновлении заметки
        NotificationCenter.default.addObserver(self, selector: #selector(noteUpdated(_:)), name: .didUpdateNote, object: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedNote = notes[indexPath.row]
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func addNote() {
        let newNote = Note(text: "")
        notes.append(newNote)
        tableView.reloadData()
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedNote = newNote
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func noteUpdated(_ notification: Notification) {
        if let updatedNote = notification.object as? Note {
            // Находим индекс заметки в массиве и обновляем его
            // === для проверки идентичности объектов (в ячейке памяти) только для классов (не для структур)
            if let index = notes.firstIndex(where: { $0 === updatedNote }) {
                notes[index] = updatedNote
                
                if updatedNote.text.isEmpty {
                    notes.remove(at: index)
                }
                
                tableView.reloadData()
            }
        }
    }
    
    deinit {
        // Удаляем наблюдателя при деинициализации
        NotificationCenter.default.removeObserver(self, name: .didUpdateNote, object: nil)
    }
}
