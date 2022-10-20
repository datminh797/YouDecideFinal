//
//  CyTrackerLabel.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit

class CyTrackerLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(textSize: CGFloat, textAlignment: NSTextAlignment, textColor: UIColor) {
        self.init(frame: .zero)
        self.font = UIFont.systemFont(ofSize: textSize, weight: .semibold)
        self.textAlignment = textAlignment
        self.textColor = textColor
    }
    
    private func config() {
        translatesAutoresizingMaskIntoConstraints = false
        adjustsFontSizeToFitWidth = true
        
    }
    
}
