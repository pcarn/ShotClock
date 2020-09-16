//
//  SettingsViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/29/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    var delegate: isAbleToSetLeague?
    var league: ShotClockConfiguration.League?

    @IBOutlet weak var shotClockLengthLabel: UILabel!
    @IBOutlet weak var middleResetLabel: UILabel!
    @IBOutlet weak var copyrightNotice: UILabel!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var leagueChooser: UISegmentedControl!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    @IBOutlet weak var customShotClockLengthInput: UITextField!
    @IBOutlet weak var customMiddleResetAmountInput: UITextField!

    var customShotClockLength = 30.0
    var customMiddleResetAmount = 20.0

    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        let iosVersion = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"

        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["peter@pcarn.com"])
        mailComposerVC.setSubject("Shot Clock Feedback")
        mailComposerVC.setMessageBody("\n\n\nDevice: \(deviceName())\niOS Version: \(iosVersion)\nApp Version: \(appVersion())", isHTML: false)

        return mailComposerVC
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(
            title: "Could Not Send Email",
            message: "Your device could not send e-mail.",
            preferredStyle: UIAlertController.Style.alert
        )
        sendMailErrorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }

    @IBAction func sendFeedbackButton(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }

    @IBAction func leagueChanged(_ sender: UISegmentedControl) {
        let league = ShotClockConfiguration.League(rawValue: sender.selectedSegmentIndex)!
        changeLeague(newLeague: league)
        delegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "leagueSetting")
    }

    func changeLeague(newLeague: ShotClockConfiguration.League) {
        let config: ShotClockConfiguration.Configuration = ShotClockConfiguration.leagueConfiguration(league: newLeague)

        league = newLeague
        if newLeague == ShotClockConfiguration.League.custom {
            shotClockLengthLabel.isHidden = true
            middleResetLabel.isHidden = true
            customShotClockLengthInput.isHidden = false
            customMiddleResetAmountInput.isHidden = false
        } else {
            shotClockLengthLabel.isHidden = false
            middleResetLabel.isHidden = false
            customShotClockLengthInput.isHidden = true
            customMiddleResetAmountInput.isHidden = true
        }
        shotClockLengthLabel.text = String(Int(config.shotClockLength))
        middleResetLabel.text = String(Int(config.middleResetAmount))
        instructionTextView.text = config.instructions
        instructionTextView.contentOffset = CGPoint.zero
    }

    @IBAction func customShotClockLengthDidChange(_ sender: UITextField) {
        if sender.text != nil {
            let numRegex = "^\\d+$"
            let validateNum = NSPredicate(format: "SELF MATCHES %@", numRegex)
            let validNum = validateNum.evaluate(with: sender.text) && sender.text != "0"
            if !validNum {
                sender.text = "30"
            }
        } else {
            sender.text = "30"
        }

        customShotClockLength = Double(sender.text!)!
        let league = ShotClockConfiguration.League(rawValue: leagueChooser.selectedSegmentIndex)!
        delegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
        UserDefaults.standard.set(customShotClockLength, forKey: "customShotClockLength")
    }

    @IBAction func middleResetDidChange(_ sender: UITextField) {
        if sender.text != nil {
            let numRegex = "^\\d+$"
            let validateNum = NSPredicate(format: "SELF MATCHES %@", numRegex)
            let validNum = validateNum.evaluate(with: sender.text) && sender.text != "0"
            if !validNum {
                sender.text = "20"
            }
        } else {
            sender.text = "20"
        }

        customMiddleResetAmount = Double(sender.text!)!
        let league = ShotClockConfiguration.League(rawValue: leagueChooser.selectedSegmentIndex)!
        delegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
        UserDefaults.standard.set(customMiddleResetAmount, forKey: "customMiddleResetAmount")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionTextView.isScrollEnabled = false
        instructionTextView.isScrollEnabled = true // Setting content offset to zero only works if we do this

        sendFeedbackButton.layer.borderWidth = 1.0
        sendFeedbackButton.layer.cornerRadius = 8.0
        sendFeedbackButton.layer.borderColor = sendFeedbackButton.currentTitleColor.cgColor

        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        leagueChooser.setTitleTextAttributes(titleTextAttributes, for: .normal)
        leagueChooser.setTitleTextAttributes(titleTextAttributes, for: .selected)

        if let league = ShotClockConfiguration.League(rawValue: UserDefaults.standard.integer(forKey: "leagueSetting")) {
            changeLeague(newLeague: league)
            leagueChooser.selectedSegmentIndex = league.rawValue
        } else { // Default
            changeLeague(newLeague: ShotClockConfiguration.League.ncaa)
            leagueChooser.selectedSegmentIndex = ShotClockConfiguration.League.ncaa.rawValue
        }

        let savedShotClockLength = UserDefaults.standard.double(forKey: "customShotClockLength")
        if savedShotClockLength > 0 {
            customShotClockLength = savedShotClockLength
            customShotClockLengthInput.text = "\(String(format: "%.0f", Darwin.round(savedShotClockLength)))"
        }
        let savedMiddleResetAmount = UserDefaults.standard.double(forKey: "customMiddleResetAmount")
        if savedMiddleResetAmount > 0 {
            customMiddleResetAmount = savedMiddleResetAmount
            customMiddleResetAmountInput.text = "\(String(format: "%.0f", Darwin.round(savedMiddleResetAmount)))"
        }

        copyrightNotice.text = "Copyright © \(Calendar.current.component(.year, from: Date())) Peter Carnesciali"
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

    func appVersion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
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
        case "iPhone11,2":                               return "iPhone XS"
        case "iPhone11,4", "iPhone11,6":                 return "iPhone XS Max"
        case "iPhone11,8":                               return "iPhone XR"
        case "iPhone12,1":                               return "iPhone 11"
        case "iPhone12,3":                               return "iPhone 11 Pro"
        case "iPhone12,5":                               return "iPhone 11 Pro Max"
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
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4",
             "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro 3rd Gen"
        case "iPad11,1", "iPad11,2":                     return "iPad mini 5th Gen"
        case "iPad11,3", "iPad11,4":                     return "iPad Air 3rd Gen"
        default:                                         return identifier
        }
    }
}
