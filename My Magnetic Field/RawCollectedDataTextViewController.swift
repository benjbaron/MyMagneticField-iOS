//
//  RawCollectedDataTextViewController.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 11/20/17.
//  Copyright © 2017 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

class RawCollectedDataTextViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    var file: URL!
    var filename: String!
    var filecontent: String!
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = filename
        self.textView.text = filecontent
        
        // add an upload button in the view
        let addButton = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func addTapped(sender: UIBarButtonItem) {
        print("uploading file \(filename)")
    }
}
