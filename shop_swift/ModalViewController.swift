//
//  ModalViewController.swift
//  sample01
//
//  Created by makoto sakamaki on 2022/02/07.
//

import UIKit
import Alamofire

class ModalViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var message: UILabel!
    
    var userDefault = UserDefaults.standard
    var items:[Item]?
    var cartItems:[Int]?
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchDown)
        buyButton.addTarget(self, action: #selector(buy), for: .touchDown)
        self.cartItems = self.userDefault.array(forKey: "cartItems") as? [Int]
        if !self.cartItems!.isEmpty {
            self.items = getCartItems(itemIds: self.cartItems!)
            message.isHidden = true
        } else {
            message.text = "カートは空です"
            message.isHidden = false
            tableView.isHidden = true
            buyButton.isEnabled = false
        }
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func getCartItems(itemIds: [Int]) -> [Item] {
        var isLock = true
        var result:[Item] = []
        let params = ["itemIds":itemIds]
        AF.request("http://localhost/api/fetch_cart_items",method: .post,parameters: params)
            .responseData {response in
                switch response.result {
                    case .success(let data):
                        do {
                            result = try JSONDecoder().decode([Item].self, from: data)
                            print(result)
                            isLock = false
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        while isLock &&
                RunLoop.current.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {}
        
        return result
    }
    
    func buyCartItems(cartItems: [Int]) -> Bool {
        var isLock = true
        var result:Bool = false
        let params = ["cartItems":cartItems]
        AF.request(Setting.BASE_URL+"/api/buy_cart_items",method: .post,parameters: params)
            .responseData {response in
                switch response.result {
                    case .success:
                        result = true
                        isLock = false
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
        while isLock &&
                RunLoop.current.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {}
        
        return result
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.cartItems!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        tableView.rowHeight = 130
        let imageView = cell.viewWithTag(101) as! UIImageView
        let cellImage = UIImage(url: (self.items![indexPath.row].image_path!))
        imageView.image = cellImage
        let nameLabel = cell.viewWithTag(102) as! UILabel
        nameLabel.text = self.items![indexPath.row].name!
        let priceLabel = cell.viewWithTag(103) as! UILabel
        priceLabel.text = self.items![indexPath.row].price!.description + "円"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            self.cartItems?.remove(at: indexPath.row)
            self.userDefault.set(self.cartItems, forKey:"cartItems")
            if self.cartItems!.isEmpty {
                message.text = "カートは空です"
                message.isHidden = false
                tableView.isHidden = true
                buyButton.isEnabled = false
            }
            tableView.reloadData()
        default:
            break
        }
    }
    
    @objc func cancel(_ sender:UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func buy(_ sender:UIButton) {
        self.cartItems = self.userDefault.array(forKey: "cartItems") as? [Int]
        let navi = self.presentingViewController as! UINavigationController
        let shopView = navi.viewControllers[navi.viewControllers.count - 1] as! ViewController
        if buyCartItems(cartItems: self.cartItems!) && !cartItems!.isEmpty {
            self.userDefault.set([], forKey: "cartItems")
            shopView.buyResult = 1
            self.dismiss(animated: true, completion: nil)
        } else {
            shopView.buyResult = 2
            self.dismiss(animated: true, completion: nil)
        }
    }
}
