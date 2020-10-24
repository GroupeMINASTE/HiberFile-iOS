//
//  ShareViewController.swift
//  HiberFile Input
//
//  Created by PlugN on 24/10/2020.
//  Copyright © 2020 Nathan FALLET. All rights reserved.
//

import UIKit
import MobileCoreServices

@objc(ShareExtensionViewController)
class CustomShareViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    
    let scrollView = UIScrollView()
    //let contentView = UIView()
    let select = UIPickerView()
    var bottomConstraint: NSLayoutConstraint!
    let selectOptions = ["1 heure", "1 jour", "3 jours", "7 jours", "Jamais"]
    var selected = "1 heure"

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .background
    setupNavBar()
    
    // Add views
    view.addSubview(scrollView)
        
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    bottomConstraint = scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    bottomConstraint.isActive = true
        
        
    scrollView.addSubview(select)
    
    select.translatesAutoresizingMaskIntoConstraints = false
    select.topAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.topAnchor, constant: 15).isActive = true
    //select.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor, constant: 15).isActive = true
    //select.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor, constant: -15).isActive = true
    select.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    //select.widthAnchor.constraint(equalToConstant: 300).isActive = true
    //select.heightAnchor.constraint(equalToConstant: 150).isActive = true
    select.delegate = self
    select.dataSource = self
    
  }
    
    // 2: Set the title and the navigation items
        private func setupNavBar() {
            self.navigationItem.title = "HiberFile"

            let itemCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
            self.navigationItem.setLeftBarButton(itemCancel, animated: false)
            
            let itemDone = UIBarButtonItem(title: "upload_generate".localized(), style: .done, target: self, action: #selector(doneAction))
            self.navigationItem.setRightBarButton(itemDone, animated: false)
            
        }

        // 3: Define the actions for the navigation items
        @objc private func cancelAction () {
            let alert = UIAlertController(title: "upload_error".localized(), message: nil, preferredStyle: .alert)
            let error = NSError(domain: "me.nathanfallet.HiberFile", code: 0, userInfo: [NSLocalizedDescriptionKey: "Canceled operation"])
            alert.addAction(UIAlertAction(title: "copied_close".localized(), style: .default) { action in
                self.extensionContext?.cancelRequest(withError: error)
            })
            present(alert, animated: true, completion: nil)
            
        }

        @objc private func doneAction() {
            self.handleSharedFile()
        }
  
    private func handleSharedFile() {
      // extracting the path to the URL that is being shared
        
      let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
      let contentType = kUTTypeData as String
      for provider in attachments {
        // Check if the content type is the same as we expected
        if provider.hasItemConformingToTypeIdentifier(contentType) {
          provider.loadItem(forTypeIdentifier: contentType,
                            options: nil) { (data, error) in
          // Handle the error here if you want
          guard error == nil else {
            self.cancelAction()
            return
          }
               
          if let url = data as? URL,
             let imageData = try? Data(contentsOf: url) {
            self.save(data: imageData, url: url)
          } else {
            // Handle this situation as you prefer
            self.cancelAction()
          }
        }}
      }
    }
      
    private func save(data: Data, url: URL) {
        // Generate a link
        APIRequest("POST", path: "/send.php").with(body: ["time": self.selected]).uploadFile(file: data, name: url.lastPathComponent) { string, status in
            // Check if request was sent
            if let string = string {
                // Show generated link
                print(string)
                
                // Add it to database
                Database.current.addFile((string, url.lastPathComponent, Date()))

                UIPasteboard.general.string = string
                
                let alert = UIAlertController(title: "copied_title".localized(), message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "copied_close".localized(), style: .default) { action in
                    self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                })
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
}
