//
//  CryptoListCell.swift
//  CryptoCoin
//
//  Created by minhdat on 20/10/2022.
//

import UIKit
import SVGKit

class CryptoListCell: UITableViewCell {
    
    static let reUseID = "cryptoListID"
    var isSaveCoreData: Bool = false
    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    var coin: CoinData?
    
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.maximumFractionDigits = 2
        formatter.numberStyle = .currency
        return formatter
    }()
    
    let logoImage: UIImageView = {
        let imageview = UIImageView(frame: .zero)
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    let cache = NetworkManager.shared.cache
    let cryptoName = CyTrackerLabel(textSize: 18, textAlignment: .left, textColor: .label)
    let idLabel = CyTrackerLabel(textSize: 15, textAlignment: .left, textColor: .gray)
    let dollar = CyTrackerLabel(textSize: 20, textAlignment: .right, textColor: .systemGreen)
    
    
//MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureImage()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(data: Coins) {
        let number = NSNumber(value: Double(data.price) ?? 0)
        let string = Self.formatter.string(from: number)
        dollar.text = string
        cryptoName.text = data.name
        idLabel.text = data.symbol
        self.downloadImage(urlString: data.iconURL)
    }
    
    func setAssets(data: CoinData) {
        isSaveCoreData = true
        coin = data
        let total = (data.price?.convertToDouble ?? 0.0) * (data.number?.convertToDouble ?? 0.0)
        let number = NSNumber(value: total)
        let string = Self.formatter.string(from: number)
        dollar.text = string
        cryptoName.text = data.name
        idLabel.text = data.symbol
        if let dataImage = data.image {
            self.logoImage.image = UIImage(data: dataImage)
        } else {
            self.downloadImage(urlString: data.iconURL ?? "")
        }
    }

    private func configure() {
        addSubview(cryptoName)
        addSubview(dollar)
        addSubview(idLabel)
        
        NSLayoutConstraint.activate([
            cryptoName.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            cryptoName.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 5),
            cryptoName.heightAnchor.constraint(equalToConstant: 20),
            cryptoName.widthAnchor.constraint(equalToConstant: 80),
            
            idLabel.topAnchor.constraint(equalTo: cryptoName.bottomAnchor, constant: 5),
            idLabel.leadingAnchor.constraint(equalTo: logoImage.trailingAnchor, constant: 5),
            idLabel.heightAnchor.constraint(equalToConstant: 20),
            idLabel.widthAnchor.constraint(equalToConstant: 40),
            
            dollar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            dollar.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            dollar.heightAnchor.constraint(equalToConstant: 30),
            dollar.widthAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    private func configureImage() {
        addSubview(logoImage)
        
        NSLayoutConstraint.activate([
            logoImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            logoImage.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            logoImage.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10),
            logoImage.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func downloadImage(urlString: String) {
        let cacheKey = NSString(string: urlString)
        guard let url = URL(string: urlString)?.deletingPathExtension().appendingPathExtension("png") else {
            return
        }
        if let image = cache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.logoImage.image = image
                if self.isSaveCoreData {
                    self.coin?.image = image.pngData()
                    try? CoreDataService.sharedInstance().viewContext.save()
                }
                self.dismiss()
            }
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        if let error = error {
                            print(error)
                            return
                        }
                        if let downloadedImage = UIImage(data: data!) {
                            self.logoImage.image = downloadedImage
                            
                        } else if let imageSvg = SVGKImage(data: data!) {
                            self.logoImage.image = imageSvg.uiImage
                        }
                        if let image = self.logoImage.image {
                            if self.isSaveCoreData {
                                self.coin?.image = image.pngData()
                                try? CoreDataService.sharedInstance().viewContext.save()
                            } else {
                                self.cache.setObject(image, forKey: cacheKey)
                            }
                        }
                    }
                }).resume()
            }
        }
    }
    
//MARK: - Image Loading View
    func showImage() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()
        
        logoImage.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerYAnchor.constraint(equalTo: logoImage.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: logoImage.centerXAnchor)
        ])
        
    }
    
    func dismiss() {
        loadingIndicator.removeFromSuperview()
    }
}
