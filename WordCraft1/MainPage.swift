//
//  MainPage.swift
// Resources Used: Apple Swift Documentation, SwiftByExample, StackOverflow (For errors), Ray Wenderlich (Kokedo), YouTube - @LetsBuildThatApp

import UIKit
import Foundation

class MainPageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Welcome to WordCraft", message: "Please name your session", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Session Name"
        }
        
        let confirmAction = UIAlertAction(title: "Start Game", style: .default) { [unowned alertController] _ in
            if let sessionName = alertController.textFields?.first?.text, !sessionName.isEmpty {
                self.startUserSession(withName: sessionName)
            } else {
                self.presentAlertForNameEntry()
            }
        }
        
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true)
    }

    private func presentAlertForNameEntry() {
        let alertController = UIAlertController(title: "Name Required", message: "Please enter a session name to continue.", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Session Name"
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [unowned alertController] _ in
            if let sessionName = alertController.textFields?.first?.text, !sessionName.isEmpty {
                self.startUserSession(withName: sessionName)
            }
        }
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true)
    }

    func startUserSession(withName name: String) {
        var sessionNames = UserDefaults.standard.array(forKey: "SessionNames") as? [String] ?? [String]()
        sessionNames.append(name)
        UserDefaults.standard.set(sessionNames, forKey: "SessionNames")
        performSegue(withIdentifier: "startGameSegue", sender: name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startGameSegue" {
            if let destinationVC = segue.destination as? BoardViewController {
                let alertController = UIAlertController(title: "Welcome to WordCraft", message: "Please name your session", preferredStyle: .alert)
                
                alertController.addTextField { textField in
                    textField.placeholder = "Session Name"
                }
                
                let confirmAction = UIAlertAction(title: "Start Game", style: .default) { [unowned alertController] _ in
                    if let sessionName = alertController.textFields?.first?.text, !sessionName.isEmpty {
                        destinationVC.sessionName = sessionName
                    } else {
                        self.presentAlertForNameEntry()
                    }
                }
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true)
            }
        }
    }


}
