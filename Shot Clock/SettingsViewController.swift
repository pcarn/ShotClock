//
//  SettingsViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/29/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UIViewController, @preconcurrency MFMailComposeViewControllerDelegate {
    var leagueSettingsDelegate: isAbleToSetLeague?
    var buzzerSettingsDelegate: isAbleToChangeBuzzerSettings?
    var league: ShotClockConfiguration.League?

    @IBOutlet weak var shotClockLengthLabel: UILabel!
    @IBOutlet weak var middleResetLabel: UILabel!
    @IBOutlet weak var copyrightNotice: UILabel!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var leagueChooser: UISegmentedControl!
    @IBOutlet weak var sendFeedbackButton: UIButton!
    @IBOutlet weak var customShotClockLengthInput: UITextField!
    @IBOutlet weak var customMiddleResetAmountInput: UITextField!
    @IBOutlet weak var warningBuzzerSoundEnabledSwitch: UISwitch!
    @IBOutlet weak var expirationBuzzerSoundEnabledSwitch: UISwitch!
    
    var customShotClockLength = 30.0
    var customMiddleResetAmount = 20.0
    
    var warningBuzzerSoundEnabled = true
    var expirationBuzzerSoundEnabled = true

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
        leagueSettingsDelegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
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
        if customShotClockLength > 99 {
            customShotClockLength = 99
            sender.text = String(Int(customShotClockLength))
        }
        if customMiddleResetAmount > customShotClockLength {
            customMiddleResetAmount = customShotClockLength
            customMiddleResetAmountInput.text = String(Int(customShotClockLength))
        }
        let league = ShotClockConfiguration.League(rawValue: leagueChooser.selectedSegmentIndex)!
        leagueSettingsDelegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
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
        if customMiddleResetAmount > customShotClockLength {
            customMiddleResetAmount = customShotClockLength
            sender.text = String(Int(customShotClockLength))
        }
        let league = ShotClockConfiguration.League(rawValue: leagueChooser.selectedSegmentIndex)!
        leagueSettingsDelegate?.changeLeague(selectedLeague: league, customShotClockLength: customShotClockLength, customMiddleResetAmount: customMiddleResetAmount)
        UserDefaults.standard.set(customMiddleResetAmount, forKey: "customMiddleResetAmount")
    }
    
    @IBAction func warningBuzzerSoundEnabledChanged(_ sender: UISwitch) {
        buzzerSettingsDelegate?.setWarningBuzzerSoundEnabled(enabled: sender.isOn)
        UserDefaults.standard.set(sender.isOn, forKey: "warningBuzzerSoundEnabled")
    }
    
    @IBAction func expirationBuzzerSoundEnabledChanged(_ sender: UISwitch) {
        buzzerSettingsDelegate?.setExpirationBuzzerSoundEnabled(enabled: sender.isOn)
        UserDefaults.standard.set(sender.isOn, forKey: "expirationBuzzerSoundEnabled")
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
        
        if let warningBuzzerSoundConfig = UserDefaults.standard.object(forKey: "warningBuzzerSoundEnabled") {
            let warningBuzzerSoundEnabled = warningBuzzerSoundConfig as! Bool
            buzzerSettingsDelegate?.setWarningBuzzerSoundEnabled(enabled: warningBuzzerSoundEnabled)
            warningBuzzerSoundEnabledSwitch.isOn = warningBuzzerSoundEnabled
        }
        
        if let expirationBuzzerSoundConfig = UserDefaults.standard.object(forKey: "expirationBuzzerSoundEnabled") {
            let expirationBuzzerSoundEnabled = expirationBuzzerSoundConfig as! Bool
            buzzerSettingsDelegate?.setExpirationBuzzerSoundEnabled(enabled: expirationBuzzerSoundEnabled)
            expirationBuzzerSoundEnabledSwitch.isOn = expirationBuzzerSoundEnabled
        }

        copyrightNotice.text = "Copyright © \(Calendar.current.component(.year, from: Date())) Peter Carnesciali"
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
        
        return identifier;
    }
}
