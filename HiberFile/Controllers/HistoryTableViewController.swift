//
//  HistoryTableViewController.swift
//  HiberLink
//
//  Created by Nathan FALLET on 19/04/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController, HistoryDelegate {
    
    var files = [(String, String, Date)]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title
        navigationItem.title = "history_title".localized()
        
        // Register cells
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "labelCell")
        
        // Clear button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "history_clear".localized(), style: .plain, target: self, action: #selector(clear(_:)))
        
        // Load content
        loadContent()
    }
    
    func loadContent() {
        DispatchQueue.global(qos: .userInitiated).async {
            // Load from database
            self.files = Database.current.getFiles()
            
            DispatchQueue.main.async {
                // Refresh tableView
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func clear(_ sender: UIBarButtonItem) {
        DispatchQueue.global(qos: .userInitiated).async {
            // Load from database
            Database.current.clearHistory()
            
            DispatchQueue.main.async {
                // Refresh tableView
                self.files.removeAll()
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "labelCell", for: indexPath)
        let link = files[indexPath.row]
        
        cell.textLabel?.text = link.0
        cell.detailTextLabel?.text = link.1

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Copy link
        let link = files[indexPath.row]
        UIPasteboard.general.string = link.0
        
        // Show confirmation
        let alert = UIAlertController(title: "copied_title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "copied_close".localized(), style: .default) { action in })
        present(alert, animated: true, completion: nil)
    }

}
