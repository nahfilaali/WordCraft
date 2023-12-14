//
//  SessionTableViewController.swift
//  WordCraft1

import UIKit

class SessionTableViewController: UITableViewController {
    
    var sessionNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSessionNames()
        self.title = "Session Details"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell", for: indexPath)
        cell.textLabel?.text = sessionNames[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSessionDetail", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sessionNameToDelete = sessionNames[indexPath.row]
            deleteSessionWithName(sessionNameToDelete, atIndexPath: indexPath)
        }
    }
    func deleteSessionWithName(_ name: String, atIndexPath indexPath: IndexPath) {
        sessionNames.remove(at: indexPath.row)
        UserDefaults.standard.set(sessionNames, forKey: "SessionNames")
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBoard",
           let indexPath = sender as? IndexPath,
           let boardVC = segue.destination as? BoardViewController {
            let sessionName = sessionNames[indexPath.row]
            boardVC.sessionName = sessionName
        }
    }
    
    private func loadSessionNames() {
        sessionNames = UserDefaults.standard.array(forKey: "SessionNames") as? [String] ?? []
        tableView.reloadData()
    }
    
}
