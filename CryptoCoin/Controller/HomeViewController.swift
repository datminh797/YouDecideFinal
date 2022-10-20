//
//  HomeViewController.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit

class HomeViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHomeViewController()
        self.configureTableView()
        self.dimissLoadingView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getAllCoins() {
            self.tableView.reloadData()
            self.dimissLoadingView()
        }
    }
    private var data: [Coins] = []
    private var filteredArray : [Coins]?
    private var refreshControl = UIRefreshControl()
    private var count = 1
    private var isActivateSearchBar = true
    private var searchBar = UISearchBar()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(CryptoListCell.self, forCellReuseIdentifier: CryptoListCell.reUseID)
        return table
    }()
    
 

    private func configureHomeViewController() {
        view.backgroundColor = .systemBackground
    }
    
    @objc func presentalert() {
        self.presentAlertView()
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.rowHeight = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.sectionHeaderHeight = 80
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
        searchBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40)
        tableView.tableHeaderView = searchBar
        searchBar.delegate = self
    }
    
    private func getAllCoins(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.showLoadingView()
        }
        NetworkManager.shared.getAllCoins { response, error in
            self.dimissLoadingView()
            self.refreshControl.endRefreshing()
                                
            guard let response = response else {
                return
            }
            self.data = response.data.coins
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getAllCoins() {
            DispatchQueue.main.async {
                self.dimissLoadingView()
            }
        }
    }
}

//MARK: - Manipulate with TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray?.count ?? data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoListCell.reUseID, for: indexPath) as? CryptoListCell  else {
            fatalError()
        }
        let coins = (filteredArray ?? self.data)[indexPath.row]
        cell.set(data: coins)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let vc = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController else {
            return
        }
        let coins = (filteredArray ?? self.data)[indexPath.row]
        vc.uuid = coins.uuid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard  editingStyle == .delete else {
            return
        }
        getAllCoins() {
            DispatchQueue.main.async {
                self.dimissLoadingView()
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    @objc func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if !isActivateSearchBar {
            isActivateSearchBar = true
            return false
        }
        return true
    }
    
    @objc func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    @objc func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(text: searchBar.text)
        searchBar.resignFirstResponder()
    }
    
    @objc func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0 && !searchBar.isFirstResponder) {
            searchBarDidClear(searchBar)
        } else {
            self.search(text: searchBar.text)
        }
    }
    
    @objc func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    @objc func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarDidClear(_ searchBar: UISearchBar) {
        isActivateSearchBar = false
        self.search(text: "")
    }
    
    func search(text: String?) {
        filteredArray = []
        if let text = text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredArray = self.data.filter { coin in
                if coin.description.range(of: text, options: .caseInsensitive) != nil {
                    return true
                }
                return false
            }
        } else {
            filteredArray = nil
        }
        
        self.tableView.reloadData()
    }
}
