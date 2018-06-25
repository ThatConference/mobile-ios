//
//  TextFieldPickerView.swift
//  Event Scheduler
//
//  Created by Matthew Ridley on 1/30/17.
//  Copyright © 2017 Six Speed. All rights reserved.
//

import Foundation

class TextFieldPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    var textField: UITextField?
    var valuesArray: [String] = []
    var displayArray: [String] = []
    
    var selectedValue: String = "" {
        didSet {
            if (selectedValue != "" && selectedValue != "0") {
                selectRow(valuesArray.index(of: selectedValue)!, inComponent: 0, animated: true)
            }
        }
    }
    
    var onValueSelected: ((_ valueSelected: String) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }
    
    func setUp() {
        self.showsSelectionIndicator = true
        self.delegate = self
        self.dataSource = self
        
        if (selectedValue != "" && selectedValue != "0") {
            selectRow(valuesArray.index(of: selectedValue)!, inComponent: 0, animated: true)
        }
    }
    
    public func selectDefault() {
        if ((selectedValue == "" || selectedValue == "0") && valuesArray.count > 0) {
            selectedValue = valuesArray[0]
            
            if let block = onValueSelected {
                block(selectedValue)
            }
        }
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return displayArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return valuesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = valuesArray[row]
        
        if let block = onValueSelected {
            block(selectedValue)
        }
        
        self.selectedValue = selectedValue
    }
    
    // Mark: Toolbar
    func getToolbar(textField: UITextField) -> UIToolbar{
        self.textField = textField
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action:  #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    @objc func donePicker (sender:UIBarButtonItem)
    {
        self.textField?.endEditing(true)
    }
}
