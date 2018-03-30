//
//  SettingsViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/29/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sendFeedbackButton(_ sender: Any) {
        let iosVersion = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        NSLog(deviceName())
        NSLog(iosVersion)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func deviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        switch identifier {
        case "i386", "x86_64":                           return "Simulator"    // Wikipedia List of iOS Devices
        case "iPod1,1":                                  return "iPod Touch 1"
        case "iPod2,1":                                  return "iPod Touch 2"
        case "iPod3,1":                                  return "iPod Touch 3"
        case "iPod4,1":                                  return "iPod Touch 4"
        case "iPod5,1":                                  return "iPod Touch 5"
        case "iPod7,1":                                  return "iPod Touch 6"
        case "iPhone1,1":                                return "iPhone 2G"
        case "iPhone1,2":                                return "iPhone 3G"
        case "iPhone2,1":                                return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":      return "iPhone 4"
        case "iPhone4,1":                                return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2":                   return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                   return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                   return "iPhone 5s"
        case "iPhone7,1":                                return "iPhone 6 Plus"
        case "iPhone7,2":                                return "iPhone 6"
        case "iPhone8,1":                                return "iPhone 6s"
        case "iPhone8,2":                                return "iPhone 6s Plus"
        case "iPhone8,4":                                return "iPhone SE"
        case "iPhone9,1", "iPhone9,3":                   return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                   return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                 return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                 return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                 return "iPhone X"
        case "iPad1,1":                                  return "iPad Original"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
        case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
        case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                       return "iPad Mini 4"
        case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
        case "iPad6,3", "iPad6,4":                       return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8":                       return "iPad Pro (12.9-inch)"
        case "iPad6,11", "iPad6,12":                     return "iPad (5th generation)"
        case "iPad7,1", "iPad7,2":                       return "iPad Pro (12.9-inch, 2nd generation)"
        case "iPad7,3", "iPad7,4":                       return "iPad Pro (10.5-inch)"
        case "iPad7,5", "iPad7,6":                       return "iPad (6th generation)"
        default:                                         return identifier
        }
    }
}
