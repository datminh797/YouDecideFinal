//
//  PortfolioViewController.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit
import SwiftChart

class PortfolioViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoinAction))
        setupTableView()
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        scroll.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
        
    }
    
    @IBOutlet weak var currentBalance: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var contraintHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var totalLabel: UILabel!
    private var data: [CoinData] = []
    private var refreshControl = UIRefreshControl()
    var changeHistory: String = ""
    var arrayHistory: [Double] = []
    
    
    @objc func refresh(_ sender: AnyObject) {
        self.refreshControl.beginRefreshing()
        NetworkManager.shared.getAllCoins { response, error in
            self.dimissLoadingView()
            self.refreshControl.endRefreshing()
            
            CoreDataService.sharedInstance().fetchedData(self)
            if let coins = CoreDataService.sharedInstance().fetchedData?.fetchedObjects {
                let dispatcher = DispatchGroup()
                coins.forEach { coinData in
                    dispatcher.enter()
                    self.getHistoryCoin(uuid: coinData.uuid ?? "") { string in
                        coinData.priceHistory = string
                        dispatcher.leave()
                    }
                }
                
                dispatcher.notify(queue: .main) {
                    try? CoreDataService.sharedInstance().viewContext.save()
                    self.loadData()
                }
            } else {
                self.loadData()
            }
        }
    }
    
    func loadData() {
        self.showLoadingView()
        self.activityIndicatorView.startAnimating()
        CoreDataService.sharedInstance().fetchedData(self)
        if let coins = CoreDataService.sharedInstance().fetchedData?.fetchedObjects {
            self.dimissLoadingView()
            data = coins
            var listCurrent: [Coins] = []
            for coin in NetworkManager.shared.allCoins ?? [] {
                if coins.contains(where: {$0.symbol == coin.symbol}) {
                    listCurrent.append(coin)
                }
            }
            
            var balance = 0.0
            var priceBalance = 0.0
            var totalBuy = 0.0
            self.arrayHistory = []
            coins.forEach { coinData in
                if let number = coinData.number?.convertToDouble, let priceHistory = coinData.priceHistory, !priceHistory.isEmpty {
                    let arrayPrice = priceHistory.components(separatedBy: ",").compactMap{Double($0)}
                    if arrayHistory.count > 0 {
                        for index in  0...arrayHistory.count - 1 {
                            let abc1 = arrayHistory[index]
                            let abc2 = arrayPrice[index] * number
                            arrayHistory[index] = abc1 + abc2
                        }
                    } else {
                        arrayPrice.forEach { price in
                            arrayHistory.append(price * number)
                        }
                    }
                    priceBalance += coinData.price?.convertToDouble ?? 0.0
                    if let coinCurrent = listCurrent.first(where: { $0.uuid == coinData.uuid}) {
                        let total = number * coinCurrent.price.convertToDouble
                        balance = balance + total
                        totalBuy += number * (coinData.price?.convertToDouble ?? 0.0)
                    }
                }
            }

            var priceCurrent = 0.0
            listCurrent.forEach { coinData in
                priceCurrent += coinData.price.convertToDouble
            }
            self.price.text = self.update(price: "\(balance)")
            self.totalLabel.text = "Total buy: " + self.update(price: "\(totalBuy)")
            changeHistory = "\(((priceCurrent - priceBalance) / priceBalance) * 100)"
            setChangePercentage(change, percentage: changeHistory)
            setupChartView()
            self.activityIndicatorView.stopAnimating()
            tableView.reloadData {
                self.contraintHeightTableView.constant = self.tableView.contentSize.height
            }
        }
    }
    
    private func getHistoryCoin(uuid: String, completion:@escaping (String) -> Void) {
        NetworkManager.shared.getHistory(coin: uuid, type: .oneD) { response, error in
            self.dimissLoadingView()
            let stringArray = response?.data?.history?.map{$0.price ?? ""}.joined(separator: ",")
            completion(stringArray ?? "")
        }
    }
    
    private func setupChartView() {
        chart.removeAllSeries()
        chart.reloadInputViews()
        var data:[Double] = []
        for i in arrayHistory {
            data.append(i)
        }
        addChartSeries(data)
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
        chart.add(series)
        chart.xLabels = []
    }
    
    @objc func addCoinAction() {
        if NetworkManager.shared.allCoins?.isEmpty ?? true {
            self.showLoadingView()
            NetworkManager.shared.getAllCoins { response, error in
                self.dimissLoadingView()
                guard let _ = response else {
                    self.presentAlertView()
                    return
                }
                self.presetAdd()
            }
            return
        }
        presetAdd()
    }
    
    func presetAdd() {
        guard let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AddCoinViewController") as? AddCoinViewController else {
            return
        }
        vc.delegate = self
        self.present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    func setupTableView() {
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CryptoListCell.self, forCellReuseIdentifier: CryptoListCell.reUseID)
    }
}

//MARK: - Manipulate with TableView
extension PortfolioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoListCell.reUseID, for: indexPath) as? CryptoListCell  else {
            fatalError()
        }
        let coins = self.data[indexPath.row]
        cell.setAssets(data: coins)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return true
    }

    private func tableView(tableView: UITableView!, commitEditingStyle editingStyle:   UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            tableView.endUpdates()

        }
    }
    
    @objc(tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            let coin = self.data[indexPath.row]
            CoreDataService.sharedInstance().viewContext.delete(coin)
            tableView.beginUpdates()
            self.data.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            self.loadData()
            completionHandler(true)
        }

        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
}

//MARK: - Add Coin ViewControllerDelegate
extension PortfolioViewController: AddCoinViewControllerDelegate {
    func reloadData() {
        loadData()
    }
}

//MARK: - Reload data
extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: reloadData)
            { _ in completion() }
    }
}
