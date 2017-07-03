//
//  EditProfileViewController.swift
//  That Conference
//
//  Created by Steven Yang on 6/16/17.
//  Copyright © 2017 That Conference. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var firstNameTextField: ProfileTextField!
    @IBOutlet weak var lastNameTextField: ProfileTextField!
    @IBOutlet weak var emailTextField: ProfileTextField!
    @IBOutlet weak var phoneTextField: ProfileTextField!
    @IBOutlet weak var cityTextField: ProfileTextField!
    @IBOutlet weak var stateTextField: ProfileTextField!
    @IBOutlet weak var companyTextField: ProfileTextField!
    @IBOutlet weak var titleTextField: ProfileTextField!
    @IBOutlet weak var websiteTextField: ProfileTextField!
    @IBOutlet weak var twitterTextField: ProfileTextField!
    @IBOutlet weak var facebookTextField: ProfileTextField!
    @IBOutlet weak var googleTextField: ProfileTextField!
    @IBOutlet weak var githubTextField: ProfileTextField!
    @IBOutlet weak var pinterestTextField: ProfileTextField!
    @IBOutlet weak var instagramTextField: ProfileTextField!
    @IBOutlet weak var linkedinTextField: ProfileTextField!
    @IBOutlet weak var publicSlackHandle: ProfileTextField!
    @IBOutlet weak var biographyTextView: BiographyTextView!
    
    let currentUser = StateData.instance.currentUser
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityIndicator = UIActivityIndicatorView()
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.activityIndicator.backgroundColor = UIColor(white: 0, alpha: 0.4)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        self.activityIndicator.clipsToBounds = true
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.center = self.view.center
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        loadCurrentData()
    }

    // MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        if (firstNameTextField.text == "" || lastNameTextField.text == "") {
            if (firstNameTextField.text == "") {
                let alert = UIAlertController(title: "Empty Textfields", message: "First name and last name textfields cannot be empty.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }

        } else {
            startIndicator()
            let user = User(id: currentUser.id,
                            headShot: currentUser.headShot,
                            displayHeadShot: currentUser.displayHeadShot,
                            firstName: currentUser.firstName,
                            lastName: currentUser.lastName,
                            email: currentUser.email,
                            publicEmail: checkTextfieldValue(emailTextField),
                            biography: checkTextView(biographyTextView),
                            phone: currentUser.phone,
                            publicPhone: checkTextfieldValue(phoneTextField),
                            publicThatSlackHandle: checkTextfieldValue(publicSlackHandle),
                            city: checkTextfieldValue(cityTextField),
                            state: checkTextfieldValue(stateTextField),
                            company: checkTextfieldValue(companyTextField),
                            title: checkTextfieldValue(titleTextField),
                            website: checkTextfieldValue(websiteTextField),
                            twitter: checkTextfieldValue(twitterTextField),
                            facebook: checkTextfieldValue(facebookTextField),
                            googlePlus: checkTextfieldValue(googleTextField),
                            github: checkTextfieldValue(githubTextField),
                            pinterest: checkTextfieldValue(pinterestTextField),
                            instagram: checkTextfieldValue(instagramTextField),
                            linkedIn: checkTextfieldValue(linkedinTextField)
            )
            
            print(user.parameter)
            
            let userAPI = UserAPI()
            userAPI.postUser(params: user.parameter) { (result) in
                switch (result) {
                case .success():
                    self.stopIndicator()
                    let alert = UIAlertController(title: "Sucessfully saved profile changes", message: "", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                        userAPI.getMainUser()
                        _ = self.navigationController?.popViewController(animated: true)
                    })
                    
                    alert.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                    print(error)
                    
                    self.stopIndicator()
                    let alert = UIAlertController(title: "Unable to save profile changes", message: "Please try again", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                    alert.addAction(ok)
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                    break
                }
            }
        }
    }
    
    // MARK: Functions
    
    func loadCurrentData() {
        firstNameTextField.text = currentUser.firstName
        lastNameTextField.text = currentUser.lastName
        emailTextField.text = currentUser.publicEmail ?? ""
        phoneTextField.text = currentUser.publicPhone ?? ""
        publicSlackHandle.text = currentUser.publicThatSlackHandle ?? ""
        cityTextField.text = currentUser.city ?? ""
        stateTextField.text = currentUser.state ?? ""
        companyTextField.text = currentUser.company ?? ""
        titleTextField.text = currentUser.title ?? ""
        websiteTextField.text = currentUser.website ?? ""
        twitterTextField.text = currentUser.twitter ?? ""
        facebookTextField.text = currentUser.facebook ?? ""
        googleTextField.text = currentUser.googlePlus ?? ""
        githubTextField.text = currentUser.github ?? ""
        pinterestTextField.text = currentUser.pinterest ?? ""
        instagramTextField.text = currentUser.instagram ?? ""
        linkedinTextField.text = currentUser.linkedIn ?? ""
        biographyTextView.text = currentUser.biography ?? ""
        biographyTextView.checkText()
    }
    
    private func checkTextfieldValue(_ textfield: UITextField) -> String? {
        if (textfield.text == "") {
            return nil
        } else {
            if (textfield == websiteTextField || textfield == facebookTextField || textfield == googleTextField || textfield == githubTextField || textfield == pinterestTextField || textfield == instagramTextField ||  textfield == linkedinTextField) {
                if (textfield.text!.contains("http://") || textfield.text!.contains("https://")) {
                    return textfield.text!
                } else {
                    let requestString = "https://"
                    let urlString = requestString + textfield.text!
                    return urlString
                }
            } else if (textfield == publicSlackHandle) {
                if (textfield.text!.contains("@")) {
                    return textfield.text!
                } else {
                    let requestString = "@"
                    let urlString = requestString + textfield.text!
                    return urlString
                }
            } else {
                return textfield.text!
            }
        }
    }
    
    private func checkTextView(_ textView: UITextView) -> String? {
        if (textView.text == "" || textView.text == "Biography") {
            return nil
        } else {
            return textView.text!
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    
    func startIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.startAnimating()
        })
    }
    
    func stopIndicator() {
        DispatchQueue.main.async(execute: {
            self.activityIndicator.stopAnimating()
        })
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
