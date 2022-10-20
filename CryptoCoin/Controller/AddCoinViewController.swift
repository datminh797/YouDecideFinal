//
//  AddCoinViewController.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation
import UIKit

protocol AddCoinViewControllerDelegate: AnyObject {
    func reloadData()
}

class AddCoinViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    @IBOutlet weak var numberCoinTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    weak var delegate: AddCoinViewControllerDelegate?
    private var pickerData: [Coins]?
    private var coin: Coins?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        CoreDataService.sharedInstance().fetchedData(self)
        setupView()
    }
    
    @objc func save() {
        if self.numberCoinTF.text?.isEmpty ?? true{
            self.presentAlertView("Invalid Number")
            return
        }
        self.showLoadingView()
        getHistoryCoin(uuid: self.coin?.uuid ?? "") { priceHistory in
            let coins = CoreDataService.sharedInstance().fetchedCoin(uuid: self.coin?.uuid ?? "", symbol: self.coin?.symbol ?? "")
            if let coinData = coins.first {
                let sum = (Int(coinData.number ?? "") ?? 0) + (Int(self.numberCoinTF.text ?? "") ?? 0)
                coinData.number = "\(sum)"
                
                let price = ((Double(coinData.price ?? "") ?? 0.0) + (self.priceTF.text?.removeFormatAmount() ?? 0.0)) / 2
                coinData.price = "\(price)"
                coinData.priceHistory = priceHistory
            } else {
                let coinData = CoinData(context: CoreDataService.sharedInstance().viewContext)
                coinData.symbol = self.coin?.symbol ?? ""
                coinData.uuid = self.coin?.uuid ?? ""
                coinData.name = self.coin?.name ?? ""
                coinData.price = "\(self.priceTF.text?.removeFormatAmount() ?? 0.0)"
                coinData.number = self.numberCoinTF.text
                coinData.iconURL = self.coin?.iconURL ?? ""
                coinData.priceHistory = priceHistory
            }
            self.dimissLoadingView()
            try? CoreDataService.sharedInstance().viewContext.save()
            self.dismiss(animated: true)
            self.delegate?.reloadData()
        }
    }
    
    private func getHistoryCoin(uuid: String, completion:@escaping (String) -> Void) {
        NetworkManager.shared.getHistory(coin: uuid, type: .oneD) { response, error in
            self.dimissLoadingView()
            let stringArray = response?.data?.history?.map{$0.price ?? ""}.joined(separator: ",")
            completion(stringArray ?? "")
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true)
    }
    
    private func setupView() {
        numberCoinTF.delegate = self
        priceTF.delegate = self
        pickerView.dataSource = self
        pickerView.delegate = self
        self.addTapGestureInView()
        self.pickerData = NetworkManager.shared.allCoins
        self.coin = NetworkManager.shared.allCoins?.first
        self.coinLabel.text = self.coin?.symbol ?? ""
        self.priceTF.text = self.update(price: self.coin?.price ?? "")
    }
    
    
    fileprivate func addTapGestureInView() {
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(onHandleTapAction))
        tapGes.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGes)
    }
    
    @objc func onHandleTapAction() {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        if textField == self.priceTF {
            let newString = text.formattedNumber()
            self.priceTF.text = newString.convertToCurrency()
            return false
        } else if textField == self.numberCoinTF && text.count > 10 {
            self.presentAlertView("Max number")
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddCoinViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerData?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let data = self.pickerData?[row]
        return (data?.symbol ?? "") + "---" + (data?.name ?? "")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        coin = self.pickerData?[row]
        self.coinLabel.text = coin?.symbol ?? ""
        self.priceTF.text = self.update(price: coin?.price ?? "")
    }
}

