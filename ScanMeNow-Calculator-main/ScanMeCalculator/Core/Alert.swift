//
//  Alert.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 27/03/23.
//

import UIKit

class Alert {
    class func showBasic(title: String, message: String, vc: UIViewController, handler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            handler?()
        }))
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
        }
    }
}
