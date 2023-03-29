//
//  InputResultCell.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 28/03/23.
//

import UIKit

class InputResultCell: UITableViewCell {
    // MARK: - IBOutlet
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: - Properties
    
    var model: InputResult? {
        didSet {
            setupView()
        }
    }
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderWidth = 2
        layer.borderColor = tintColor.cgColor
    }
    
    // MARK: - Private Func
    private func setupView() {
        guard let model = model else { return }
        
        inputLabel.text = model.input
        resultLabel.text = "\(model.result)"
    }
    
}
