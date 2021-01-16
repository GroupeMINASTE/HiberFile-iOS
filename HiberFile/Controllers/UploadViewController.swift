/*
Copyright (C) 2020 Groupe MINASTE

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
//
//  UploadViewController.swift
//  HiberLink
//
//  Created by Nathan FALLET on 19/04/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import MobileCoreServices
import SwCrypt
import ZIPFoundation
import CryptoKit

class UploadViewController: UIViewController, UITextFieldDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectOptions[row].localized()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = selectOptions[row]
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let input = UIButton()
    let select = UIPickerView()
    let generate = UIButton()
    let output = UITextField()
    let copy = UIButton()
    var bottomConstraint: NSLayoutConstraint!
    var urls: [URL]?
    weak var delegate: HistoryDelegate?
    let selectOptions = ["1 heure", "1 jour", "3 jours", "7 jours", "Jamais"]
    var selected = "1 heure"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set background color
        view.backgroundColor = .background
        
        // Set title
        navigationItem.title = "upload_title".localized()
        
        // Add views
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        scrollView.addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        contentView.addSubview(input)
        contentView.addSubview(select)
        contentView.addSubview(generate)
        contentView.addSubview(output)
        contentView.addSubview(copy)
        
        input.translatesAutoresizingMaskIntoConstraints = false
        input.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
        input.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 15).isActive = true
        input.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
        input.setTitle("upload_input".localized(), for: .normal)
        input.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            input.setTitleColor(.label, for: .normal)
        } else {
            // Fallback on earlier versions
            input.setTitleColor(.black, for: .normal)
        }
        
        select.translatesAutoresizingMaskIntoConstraints = false
        select.topAnchor.constraint(equalTo: input.bottomAnchor, constant: 15).isActive = true
        select.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        select.widthAnchor.constraint(equalToConstant: 300).isActive = true
        select.heightAnchor.constraint(equalToConstant: 150).isActive = true
        select.delegate = self
        select.dataSource = self
        
        generate.translatesAutoresizingMaskIntoConstraints = false
        generate.topAnchor.constraint(equalTo: select.bottomAnchor, constant: 15).isActive = true
        generate.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        generate.widthAnchor.constraint(equalToConstant: 300).isActive = true
        generate.heightAnchor.constraint(equalToConstant: 50).isActive = true
        generate.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        generate.setTitle("upload_input".localized(), for: .normal)
        generate.setTitle("upload_generating".localized(), for: .disabled)
        generate.setTitle("upload_generate".localized(), for: .highlighted)
        generate.backgroundColor = .systemBlue
        generate.layer.cornerRadius = 10
        generate.clipsToBounds = true
        
        output.translatesAutoresizingMaskIntoConstraints = false
        output.topAnchor.constraint(equalTo: generate.bottomAnchor, constant: 30).isActive = true
        output.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 15).isActive = true
        output.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
        output.placeholder = "upload_output".localized()
        output.textAlignment = .center
        output.autocorrectionType = .no
        output.autocapitalizationType = .none
        output.returnKeyType = .done
        output.keyboardType = .URL
        output.isUserInteractionEnabled = false
        output.delegate = self
        
        copy.translatesAutoresizingMaskIntoConstraints = false
        copy.topAnchor.constraint(equalTo: output.bottomAnchor, constant: 15).isActive = true
        copy.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor, constant: -15).isActive = true
        copy.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        copy.widthAnchor.constraint(equalToConstant: 300).isActive = true
        copy.heightAnchor.constraint(equalToConstant: 50).isActive = true
        copy.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        copy.setTitle("upload_copy".localized(), for: .normal)
        copy.setTitleColor(.white, for: .normal)
        copy.backgroundColor = .systemBlue
        copy.layer.cornerRadius = 10
        copy.clipsToBounds = true
        
        // Listen for keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardChanged(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        if sender == input {
            let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeData), String(kUTTypeContent), String(kUTTypeItem)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            if #available(iOS 11.0, *) {
                importMenu.allowsMultipleSelection = true
            }
            self.present(importMenu, animated: true, completion: nil)
        } else if sender == generate, let urls = urls {
            // Disable
            input.endEditing(true)
            generate.isEnabled = false
            
            do {
                
                guard var url = urls.first else {
                    self.generate.isEnabled = true
                    return
                }
                
                if urls.count > 1 {
                    let fileManager = FileManager()
                    
                    let currentWorkingPath = getDocumentsDirectory().absoluteString
                    
                    var destinationURL = URL(fileURLWithPath: currentWorkingPath)
                    destinationURL.appendPathComponent("HFLegacyArchive.zip")
                    
                    var tempURL = URL(fileURLWithPath: currentWorkingPath)
                    tempURL.appendPathComponent("HFLegacyFolder")
                    
                    print("Checking \(tempURL.path)")
                    if fileManager.fileExists(atPath: tempURL.path) {
                        print("Removing \(tempURL.path)")
                        try fileManager.removeItem(at: tempURL)
                    }
                    
                    print("Checking \(destinationURL.path)")
                    if fileManager.fileExists(atPath: destinationURL.path) {
                        print("Removing \(destinationURL.path)")
                        try fileManager.removeItem(at: destinationURL)
                    }
                    
                    try fileManager.createDirectory(at: tempURL, withIntermediateDirectories: true, attributes: nil)
                    
                    for url in urls {
                        var tempDestination = tempURL
                        tempDestination.appendPathComponent(url.lastPathComponent)
                        
                        print("Checking \(tempDestination.path)")
                        if fileManager.fileExists(atPath: tempDestination.path) {
                            print("Removing \(tempDestination.path)")
                            try fileManager.removeItem(at: tempDestination)
                        }
                        try fileManager.copyItem(at: url, to: tempDestination)
                    }
                    
                    try fileManager.zipItem(at: tempURL, to: destinationURL, shouldKeepParent: false, compressionMethod: .none)
                    
                    url = destinationURL
                    
                }
                
                // Read data
                let data = try Data(contentsOf: url)
                
                // Generate a link
                APIRequest("POST", path: "/send.php").with(body: ["time": selected]).uploadFile(file: data, name: url.lastPathComponent) { string, status in
                    // Check if request was sent
                    if var string = string {
                        // Show generated link
                        
                        string = string + "?p=legacy-wellknown"
                        
                        self.output.text = string
                        print(string)
                        
                        // Add it to database
                        Database.current.addFile((string, url.lastPathComponent, Date()))
                        
                        // Notify delegate
                        self.delegate?.loadContent()
                        
                        // Select it
                        self.output.becomeFirstResponder()
                        self.output.selectAll(nil)
                        self.buttonClicked(self.copy)
                    } else {
                        // An error occured
                        self.output.text = "upload_error".localized()
                        print(status)
                    }
                    
                    // Enable again
                    self.generate.isEnabled = true
                    self.urls = nil
                    self.input.setTitle("upload_input".localized(), for: .normal)
                }
            } catch {
                print(error)
                self.generate.isEnabled = true
                self.urls = nil
                self.input.setTitle("upload_input".localized(), for: .normal)
            }
        } else if sender == copy, let url = output.text, !url.isEmpty {
            // Select it
            output.becomeFirstResponder()
            output.selectAll(nil)
            
            // Copy link
            UIPasteboard.general.string = url
            
            // Show confirmation
            let alert = UIAlertController(title: "copied_title".localized(), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "copied_close".localized(), style: .default) { action in })
            present(alert, animated: true, completion: nil)
        } else if sender == generate {
            buttonClicked(input)
        }
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Set URL
        self.urls = urls
            
        // Set file name
        if urls.count > 1 {
            self.input.setTitle("\(urls.count) \("files".localized())", for: .normal)
        } else {
            self.input.setTitle(urls.first?.lastPathComponent, for: .normal)
        }
            
        self.generate.isHighlighted = true
    }
    
    @objc func keyboardChanged(_ sender: NSNotification) {
        if let userInfo = sender.userInfo {
            // Adjust frame to keyboard
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            let tabBarFrame = tabBarController?.tabBar.frame
            let isKeyboardShowing = sender.name == UIResponder.keyboardWillShowNotification
            bottomConstraint.constant = isKeyboardShowing ? -((keyboardFrame?.height ?? 0) - (tabBarFrame?.height ?? 0)) : 0
            
            // And animate the transition
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField != output
    }

}

protocol HistoryDelegate: class {
    
    func loadContent()
    
}
