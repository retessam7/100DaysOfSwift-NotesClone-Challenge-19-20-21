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
        
        load()
        
        title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        
        // Подписываемся на уведомление об обновлении заметки
        NotificationCenter.default.addObserver(self, selector: #selector(noteUpdated(_:)), name: .didUpdateNote, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteNote(_:)), name: .didDeleteNote, object: nil)
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
        notes.reverse()
        tableView.reloadData()
    }
    
    @objc func addNote() {
        let newNote = Note(text: "")
        notes.append(newNote)
        tableView.reloadData()
        save()
        
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
                save()
            }
        }
    }
    
    @objc func deleteNote(_ notification: Notification) {
        if let noteToDelete = notification.object as? Note {
            if let index = notes.firstIndex(where: { $0 === noteToDelete }) {
                notes.remove(at: index)
            }
        }
    }
    
    deinit {
        // Удаляем наблюдателя при деинициализации
        NotificationCenter.default.removeObserver(self, name: .didUpdateNote, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didDeleteNote, object: nil)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Saving failed")
        }
    }
    
    func load() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.data(forKey: "notes") as Data? {
            let jsonDecoder = JSONDecoder()
            if let decodedData = try? jsonDecoder.decode([Note].self, from: savedData) {
                notes = decodedData
            }
        }
    }
}
