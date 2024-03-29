//
//  AddEntryViewController.swift
//  Leave Days
//
//  Created by David Kababyan on 20/11/2020.
//

import UIKit

class AddEntryViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var leaveTypeTextField: UITextField!
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    //MARK: - Vars
    var leaveTypePicker = UIPickerView()
    var isAnnualLeave = true
    
    var leaveToEdit: Leave?

    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldInputView()
        configureTypePickerView()
        setDefaultLeaveType()
        
        if leaveToEdit != nil {
            updateUIForEdit()
        }
    }

    
    //MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if leaveTypeTextField.text != "" {
            
            if isDateValid() {
                leaveToEdit != nil ? editEntry() : saveEntry()
            } else {
                let notification = AppNotification(title: "Error!", subTitle: "End date is before start date!", view: self)
                notification.showNotification()
            }
        }
    }
    
    @IBAction func startDatePickerValueChanged(_ sender: UIDatePicker) {
        endDatePicker.minimumDate = sender.date
    }
    
    @IBAction func endDatePickerValueChanged(_ sender: UIDatePicker) {
        
        startDatePicker.maximumDate = sender.date
    }
    
    //MARK: -  Configuration
    private func configureTypePickerView() {
        
        leaveTypePicker.dataSource = self
        leaveTypePicker.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()

        // Adding Button ToolBar
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClicked))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
        toolBar.isUserInteractionEnabled = true

        leaveTypeTextField.inputAccessoryView = toolBar
    }
    
    private func setDefaultLeaveType() {
        leaveTypeTextField.text = LeaveType.allCases[0].rawValue
    }
    

    
    //MARK: - Save
    private func saveEntry() {
        
        let context = AppDelegate.context
        let leaveEntry = Leave(context: context)
        leaveEntry.typeName = leaveTypeTextField.text!
        leaveEntry.startDate = startDatePicker.date
        leaveEntry.endDate = endDatePicker.date
        leaveEntry.numberOfDays = numberOfDaysFromDates()
        leaveEntry.isAnnualLeave = isAnnualLeave

        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        vibrate()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func editEntry() {
        
        leaveToEdit!.typeName = leaveTypeTextField.text!
        leaveToEdit!.startDate = startDatePicker.date
        leaveToEdit!.endDate = endDatePicker.date
        leaveToEdit!.numberOfDays = numberOfDaysFromDates()
        leaveToEdit!.isAnnualLeave = isAnnualLeave
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        vibrate()
        self.dismiss(animated: true, completion: nil)
    }


    //MARK: - Helpers
    private func numberOfDaysFromDates() -> Float {
        Float(startDatePicker.date.daysCount(until: endDatePicker.date).workingDays)
    }
    
    private func vibrate() {
        UIDevice.vibrate()
    }
    
    private func setTextFieldInputView() {
        leaveTypeTextField.inputView = leaveTypePicker
    }

    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func doneClicked() {

        leaveTypeTextField.text = LeaveType.allCases[leaveTypePicker.selectedRow(inComponent: 0)].rawValue
        
        isAnnualLeave = (leaveTypePicker.selectedRow(inComponent: 0) == 0)

        dismissKeyboard()
    }

    private func isDateValid() -> Bool {
        startDatePicker.date.interval(ofComponent: .day, fromDate: endDatePicker.date) >= 0.0
    }
    
    //MARK: - Editing
    private func updateUIForEdit() {
        
        leaveTypeTextField.text = leaveToEdit!.typeName
        startDatePicker.setDate(leaveToEdit!.startDate!, animated: false)
        endDatePicker.setDate(leaveToEdit!.endDate!, animated: false)
        isAnnualLeave = leaveToEdit!.isAnnualLeave
    }

}

extension AddEntryViewController: UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        LeaveType.allCases.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        LeaveType.allCases[row].rawValue
    }
    
}

extension AddEntryViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        isAnnualLeave = row != 0
        leaveTypeTextField.text = LeaveType.allCases[row].rawValue
    }
}

