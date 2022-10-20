//
//  DetailsViewController.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import Foundation
import SwiftChart

enum HistoryDays {
    case threeH
    case oneD
    case sevenDay
    case thirtyD
    case threeM
    case oneY
    
    var description: String {
        switch self {
        case .threeH:
            return "3h"
        case .oneD:
            return "24h"
        case .sevenDay:
            return "7d"
        case .thirtyD:
            return "30d"
        case .threeM:
            return "3m"
        case .oneY:
            return "1y"
        }
    }
}

class DetailsViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var chartView: Chart!
    
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var allTimeHighLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var noOfMarketsLabel: UILabel!
    
    @IBOutlet weak var threeHourButton: UIButton!
    @IBOutlet weak var oneDayButton: UIButton!
    @IBOutlet weak var sevenDayButton: UIButton!
    @IBOutlet weak var thirtyDayButton: UIButton!
    @IBOutlet weak var oneYearButton: UIButton!
    @IBOutlet weak var threeMonthButton: UIButton!

    
    var singleCoinId: String = ""
    var currencyId: String?
    var uuid: String?
    var historyArray: [History]? = []
    var changeHistory: String = ""
    var coinHistory: HistoryDays = .oneD
    var coin: SingleCoin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtons()
        getHistory()
    }
    
    func getHistory() {
        self.showLoadingView()
        let dispatcher = DispatchGroup()
        dispatcher.enter()
        NetworkManager.shared.getHistory(coin: uuid ?? "", type: coinHistory) { response, error in
            self.historyArray = response?.data?.history
            dispatcher.leave()
        }
        
        dispatcher.enter()
        NetworkManager.shared.getSingleCoin(uuid: uuid ?? "") { response, error in
            self.coin = response?.data.coin
            dispatcher.leave()
        }
        
        dispatcher.notify(queue: .main) {
            self.dimissLoadingView()
            if self.historyArray?.isEmpty ?? true || self.coin == nil {
                self.presentAlertView()
            }
            self.reloadChart()
        }
    }
    
    func roundButtons() {
        threeHourButton.layer.cornerRadius = 10
        oneDayButton.layer.cornerRadius = 10
        sevenDayButton.layer.cornerRadius = 10
        thirtyDayButton.layer.cornerRadius = 10
        threeMonthButton.layer.cornerRadius = 10
        oneYearButton.layer.cornerRadius = 10
    }
    
    func reloadChart() {
        chartView.removeAllSeries()
        changeHistory = coin?.change ?? "0.00"
        setChangePercentage(changeLabel, percentage: changeHistory)
        setupChartView()
        setupView()
    }
    
    private func setupChartView() {
        var data:[Double] = []
        if let historyArray = historyArray?.reversed() {
            for i in historyArray {
                data.append(Double(i.price ?? "0.0")!)
            }
            addChartSeries(data)
        }
    }
    
    private func setupView() {
        if coin == nil {
            return
        }
        symbolLabel.text = coin?.symbol
        setChangePercentage(changeLabel, percentage: coin?.change)
        setPrice(priceLabel, price: coin?.price ?? "")
        marketCapLabel.text = formatPrice(Double(coin?.marketCap ?? "") ?? 0.00)
        volumeLabel.text = formatPrice(Double(coin?.the24HVolume ?? "") ?? 0.00)
        setPrice(allTimeHighLabel, price: coin?.allTimeHigh.price ?? "")
        rankLabel.text = "\(coin?.rank ?? 0)"
        noOfMarketsLabel.text = String(coin?.numberOfMarkets ?? 0)
        self.title = coin?.name
    }
    
    private func addChartSeries(_ data: [Double]) {
        let series = ChartSeries(data)
        
        series.area = true
        
        if Double(changeHistory)! > 0 {
            series.color = ChartColors.blueColor()
        }
        else {
            series.color = ChartColors.redColor()
        }
        chartView.add(series)
        chartView.xLabels = []
    }
    
    func updateHistory() {
        self.showLoadingView()
        NetworkManager.shared.getHistory(coin: uuid ?? "", type: coinHistory) { response, error in
            self.dimissLoadingView()
            guard let response = response else {
                self.presentAlertView()
                return
            }
            
            if response.code == "RATE_LIMIT_EXCEEDED" {
                self.presentAlertView("You've reached the API request limit. Generate a free API key: https://developers.coinranking.com/create-account")
            }
            
            self.historyArray = response.data?.history
            self.reloadChart()
        }
    }
    
    
    @IBAction func threehAction(_ sender: Any) {
        coinHistory = .threeH
        updateHistory()
    }
    
    @IBAction func dayAction(_ sender: Any) {
        coinHistory = .oneD
        updateHistory()
    }
    @IBAction func sevenDayAction(_ sender: Any) {
        coinHistory = .sevenDay
        updateHistory()
    }
    @IBAction func thrityDayAction(_ sender: Any) {
        coinHistory = .thirtyD
        updateHistory()
    }
    @IBAction func threeMonthAction(_ sender: Any) {
        coinHistory = .threeM
        updateHistory()
    }
    @IBAction func oneYearAction(_ sender: Any) {
        coinHistory = .oneY
        updateHistory()
    }
    
}
