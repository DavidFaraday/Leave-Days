//
//  ViewController.swift
//  Leave Days
//
//  Created by David Kababyan on 20/11/2020.
//

import UIKit
import CoreData

class MainLeaveViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var annualLeaveBackgroundView: UIView!
    @IBOutlet weak var sickLeaveBackgroundView: UIView!
    @IBOutlet weak var annualLeaveLabel: UILabel!
    @IBOutlet weak var sickLeaveLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    //MARK: - Vars
    var leaveFetchResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Leave")

    var totalLeaves: Float = 21.0
    var totalSickLeaves: Float = 5.0
    
    var usedLeave: Float = 0.0
    var usedSickLeave: Float = 0.0

    var sickLeaveTextField: UITextField!
    var annualLeaveTextField: UITextField!

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        loadFromUserDefaults()
        fetchLeaves()
        updateTotalAmounts()

        tableView.tableHeaderView = headerView
        setupViewCornerRadius()
    }
    
    //MARK: Fetching Data
    
    private func fetchLeaves() {
        
        fetchRequest.sortDescriptors = [ NSSortDescriptor(key: "startDate", ascending: false) ]
        
        leaveFetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: nil, cacheName: nil)
        

        leaveFetchResultsController.delegate = self
        
        do {
            try leaveFetchResultsController.performFetch()
        } catch {
            fatalError("Transaction fetch error")
        }

    }

    //MARK: - IBActions
    @IBAction func menuButtonPressed(_ sender: Any) {
        showMenuOptions()
    }
    
    @IBAction func addLeaveButtonPressed(_ sender: Any) {
        
        performSegue(withIdentifier: "mainToNewEntrySeg", sender: self)
    }
    
    //MARK: - SetupUI
    private func setupViewCornerRadius() {
        
        annualLeaveBackgroundView.layer.cornerRadius = 8
        annualLeaveBackgroundView.layer.masksToBounds = true
        sickLeaveBackgroundView.layer.cornerRadius = 8
        sickLeaveBackgroundView.layer.masksToBounds = true
    }

    private func updateTotalAmounts() {
        
        calculateLeaves()
        
        annualLeaveLabel.text = "Annual leave: " + String(format: "%.0f", totalLeaves)
        sickLeaveLabel.text = "Sick leave: " + String(format: "%.0f", totalSickLeaves)
    }
    
    private func showMenuOptions() {
        
        let alertController = UIAlertController(title: "Menu", message: "Set yearly defaults or delete all entries and reset the year.", preferredStyle: .actionSheet)
        
        
        alertController.addAction(UIAlertAction(title: "Change Yearly Totals", style: .default, handler: { (action) in
            
            self.showResetMenu()
        }))
        
        alertController.addAction(UIAlertAction(title: "Reset To Defaults", style: .destructive, handler: { (action) in
            
            self.resetCoreData()
            self.resetUserDefaults()
            self.updateTotalAmounts()
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    
    private func showResetMenu() {
        
        let alertController = UIAlertController(title: "Set Year Defaults", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (annualTextField) in
            annualTextField.placeholder = "Total Annual Leaves"
            self.annualLeaveTextField = annualTextField
        }
        
        alertController.addTextField { (sickTextField) in
            sickTextField.placeholder = "Total Sick Leaves"

            self.sickLeaveTextField = sickTextField
        }
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
            
            self.saveToUserDefaults()
            self.loadFromUserDefaults()
            self.updateTotalAmounts()
        }))
        

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

    private func saveToUserDefaults() {
        
        if annualLeaveTextField.text != "" && sickLeaveTextField.text != "" {
            
            UserDefaults.standard.setValue(Float(annualLeaveTextField.text!) ?? 0.0, forKey: LeaveType.Annual.rawValue)
            UserDefaults.standard.setValue(Float(sickLeaveTextField.text!) ?? 0.0, forKey: LeaveType.Sick.rawValue)

            UserDefaults.standard.synchronize()
            
        } else {
            print("empty data")
        }
    }
    
    private func loadFromUserDefaults() {

        if let annualDays = UserDefaults.standard.value(forKey: LeaveType.Annual.rawValue) {
            totalLeaves = annualDays as? Float ?? 21.0
        } else {
            self.resetUserDefaults()
        }
        
        if let sickDays = UserDefaults.standard.value(forKey: LeaveType.Sick.rawValue) {
            totalSickLeaves = sickDays as? Float ?? 5.0
        }
    }

    private func resetUserDefaults() {
        
        UserDefaults.standard.setValue(21.0, forKey: LeaveType.Annual.rawValue)
        UserDefaults.standard.setValue(5.0, forKey: LeaveType.Sick.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    private func resetCoreData() {
        
        for item in leaveFetchResultsController.sections?[0].objects as! [Leave] {
            AppDelegate.context.delete(item)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }

    
    //MARK: - Helpers
    private func calculateLeaves() {

        loadFromUserDefaults()
        usedSickLeave = 0
        usedLeave = 0
        
        for leave in leaveFetchResultsController.fetchedObjects! {
            
            let tempLeaveObject = leave as! Leave
            
            if tempLeaveObject.isAnnualLeave {
                usedLeave += tempLeaveObject.numberOfDays
            } else {
                usedSickLeave += tempLeaveObject.numberOfDays
            }
        }

        totalLeaves = totalLeaves - usedLeave
        totalSickLeaves = totalSickLeaves - usedSickLeave
    }


    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "mainToNewEntrySeg" {
            
            if let indexPath = sender as? IndexPath {
                
                let destinationVc = segue.destination as! AddEntryViewController
                destinationVc.leaveToEdit = leaveFetchResultsController.object(at: indexPath) as? Leave
            }
            
        }
    }

}


extension MainLeaveViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaveFetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        cell.configureCell(with: leaveFetchResultsController.object(at: indexPath) as! Leave)
        
        return cell
    }
}


extension MainLeaveViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "mainToNewEntrySeg", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let leaveToDelete = leaveFetchResultsController.object(at: indexPath) as! Leave
                        
            AppDelegate.context.delete(leaveToDelete)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
}


extension MainLeaveViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        updateTotalAmounts()
        tableView.reloadData()
    }
}
