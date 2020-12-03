//
//  CustomTableViewCell.swift
//  Leave Days
//
//  Created by David Kababyan on 20/11/2020.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var numberOfDaysLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(with leave: Leave) {
        
        typeNameLabel.text = leave.typeName! + " Leave"
        numberOfDaysLabel.text = String(format: "Days: %.0f", leave.numberOfDays)
        startDateLabel.text = "Start: \(leave.startDate?.dayMonth() ?? "")"
        endDateLabel.text = "End: \(leave.endDate?.dayMonth() ?? "")"
    }

}
