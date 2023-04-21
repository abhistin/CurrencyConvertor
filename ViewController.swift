//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Abhishek Bhardwaj on 17/04/23.
//

import UIKit

struct Currency: Decodable {
    let success: Bool
    let base: String
    var rates: [String:Double]
}

class ViewController: UIViewController, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var selectedCurr: String = ""
    
    @IBOutlet weak var TextErrorLabel: UILabel!
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var conversionTableView: UITableView!
    // this will store API output
    var currency: Currency?
    //we'll use this to perform our business logic
    var convertedCurencyToRateDictionary = [String:Double]()
    var dropDownListKeys = [String]()
    var baseRate: Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dropDown.delegate = self
        dropDown.dataSource = self
        conversionTableView.dataSource = self
        fetchData()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currencyFetched = currency {
            return currencyFetched.rates.count
            
        }
        return 0
    }
    
    @IBOutlet weak var dropDown: UIPickerView!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        // this is done for sorting
        let currencyFetchedVariable = convertedCurencyToRateDictionary.sorted(by: { $0.0 < $1.0 })
        
        var currencyKey = [String]()
        var currencyValues = [Double]()
        
        for curr in currencyFetchedVariable {
            currencyKey.append(curr.key)
            currencyValues.append(curr.value)
        }
        cell.textLabel?.text = Array(currencyKey)[indexPath.row]
        
        
        cell.detailTextLabel?.text = String(format: "%.5f", Array(currencyValues)[indexPath.row] * baseRate)
        return cell
        
        
    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dropDownListKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dropDownListKeys.sorted()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCurr = self.dropDownListKeys.sorted()[row]
        print("selecting a country")
        print(selectedCurr)
        
    }
    
    @IBAction func convertPressed(_ sender: UIButton) {
        
        if let inputAmountInString = amountField.text {
            if let inputAmountInDouble = Double(inputAmountInString) {
                TextErrorLabel.text = ""
                
                self.convertedCurencyToRateDictionary = self.currency!.rates
                let conversionFactor = (self.currency?.rates[selectedCurr])
                for currenyRates in self.currency?.rates ?? [:] {
                    let convertedRates =  inputAmountInDouble/conversionFactor! * (self.convertedCurencyToRateDictionary[currenyRates.key] ?? 1.0)
                    self.convertedCurencyToRateDictionary[currenyRates.key] = convertedRates
                }
                
                // Reloading table components as we have computed the conversion data
                reloadTableComponent()
                return
            }
            
            // Otherwise it should be an error
            TextErrorLabel.text = "Enter Numbers Only"
            TextErrorLabel.textColor = .red
            
        }
    }
    
    
    // Reload table components once there is any change in data.
    func reloadTableComponent() {
        
        DispatchQueue.main.async {
            self.conversionTableView.reloadData()
            self.dropDown.reloadAllComponents()
            
            
        }
        
    }
    
    // Make an HTTP call to fetch the base data and store it in local variables
    func fetchData() {
        let url = URL(string: "https://dqcyzkkq84hco.cloudfront.net/content.json")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error")
            }
            do {
                self.currency = try JSONDecoder().decode(Currency.self, from: data!)
                self.convertedCurencyToRateDictionary = (self.currency?.rates)!
                
                if self.currency != nil {
                    self.dropDownListKeys = Array(self.currency?.rates.map{String($0.key) } ?? ["DUMMY"])
                }
                
                // Reloading table components as we have computed the conversion data
                self.reloadTableComponent()
            }
            catch {
                print("Parse Error")
            }
        }
        
        task.resume()
    }
}

