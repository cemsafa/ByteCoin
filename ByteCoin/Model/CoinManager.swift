//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Cem Safa on 10.07.2020.
//  Copyright © 2020 Cem Safa. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateRates(_ price: String, _ currency: String)
    func didFailWithError(_ error: Error)
}

struct CoinManager {
    
    var baseURL = ""
    var apiKey = ""
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let bitcoinPrice = self.parseJSON(safeData) {
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdateRates(priceString, currency)
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ coinData: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate

            return rate
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
