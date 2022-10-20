//
//  UIViewController+Extension.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
    
    func presentAlertView(_ message: String = "") {
        DispatchQueue.main.async {
            let alertView = AlertScreenVC()
            if !message.isEmpty {
                alertView.message = message
            }
            alertView.modalTransitionStyle = .crossDissolve
            alertView.modalPresentationStyle = .overFullScreen
            self.present(alertView, animated: true, completion: nil)
        }
    }
    
    func showLoadingView() {
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        //animate containerView alpha from 0 to 0.8
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        containerView.bringSubviewToFront(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dimissLoadingView() {
        DispatchQueue.main.async {
            if (containerView != nil) {
                containerView.removeFromSuperview()
                containerView = nil
            }
        }
        
    }
    
    func setChangePercentage(_ changeLabel: UILabel, percentage: String?){
        guard let a = percentage, let doubleValue = Double(a), !doubleValue.isNaN else {
            changeLabel.text = ""
            return
        }
        var arrow: String = ""
        if doubleValue < 0 {
            changeLabel.textColor = .red
            arrow = "\u{2193}"
        }
        else {
            changeLabel.textColor = .systemGreen
            arrow = "\u{2191}"
        }
        changeLabel.text = arrow + String(format: "%.2f", doubleValue) + "%"
    }
    
    func setPrice(_ priceLabel: UILabel, price: String) {
        priceLabel.text = self.update(price: price)
    }
    
    func update(price: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        let number = NSNumber(value: Double(price) ?? 0)
        return formatter.string(from: number) ?? "0$"
    }
    
    func formatPrice(_ number: Double) -> String {
        let thousand = number / 1000
        let million = number / 1000000
        let billion = number / 1000000000

        if billion >= 1.0 {
            return "\(round(billion*10)/10)Billion"
        } else if million >= 1.0 {
            return "\(round(million*10)/10)Million"
        } else if thousand >= 1.0 {
            return ("\(round(thousand*10/10))K")
        } else {
            return "\(Int(number))"
        }
    }
}
