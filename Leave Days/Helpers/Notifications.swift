//
//  Notifications.swift
//  Leave Days
//
//  Created by David Kababyan on 03/12/2020.
//

import Foundation
import UIKit

class AppNotification {
    
    var title: String
    var message: String
    var view: UIViewController
    
    init(title: String, subTitle: String, view: UIViewController) {
        
        self.title = title
        self.message = subTitle
        self.view = view
    }
    
    
    func showNotification() {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.view.present(alertController, animated: true, completion: nil)
    }
}
