//
//  ViewController.swift
//  sample01
//
//  Created by makoto sakamaki on 2022/01/27.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UICollectionViewDataSource,
                      UICollectionViewDelegate,UITabBarDelegate,UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var loginCustomer:Customer?
    let cellIdentifier = "cell"
    var categories:[Category] = []
    var items:[Item] = []
    var userDefault = UserDefaults.standard
    var cartBarButtonItem:UIBarButtonItem?
    var didPrepareMenu = false
    let tabLabelWidth:CGFloat = 100
    var firstAppear = true
    var buyResult = -1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "shop"
        self.cartBarButtonItem = UIBarButtonItem(title: "カートを見る", style: .done, target: self, action: #selector(cartItem(_:)))
        self.navigationItem.rightBarButtonItems = [self.cartBarButtonItem!]
        self.navigationItem.hidesBackButton = true
        self.categories = getCategories()
        self.items = getItems(category_id: self.categories[0].id!)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstAppear {
            firstAppear = false
            return
        }
        if buyResult == 1 {
            toast(text: "購入しました")
        } else if buyResult == 2 {
            toast(text: "購入失敗しました")
        }
    }
    
    override func viewDidLayoutSubviews() {
        if didPrepareMenu { return }
        didPrepareMenu = true
        
        let tabLabelHeight:CGFloat = scrollView.frame.height
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCategory(sender:)))
        singleTapGesture.numberOfTapsRequired = 1
        
        let firstLabel = UILabel()
        firstLabel.isUserInteractionEnabled = true
        firstLabel.tag = categories[0].id!
        firstLabel.textAlignment = .center
        firstLabel.frame = CGRect(x: 0, y: 0, width: tabLabelWidth, height: tabLabelHeight)
        firstLabel.text = categories[0].name
        firstLabel.textColor = UIColor.white
        firstLabel.backgroundColor = UIColor.lightGray
        firstLabel.addGestureRecognizer(singleTapGesture)
        scrollView.addSubview(firstLabel)
        
        var originX = firstLabel.frame.width
        for i in 1 ..< self.categories.count {
            let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCategory(sender:)))
            singleTapGesture.numberOfTapsRequired = 1
            let label = UILabel()
            label.isUserInteractionEnabled = true
            label.tag = categories[i].id!
            label.textAlignment = .center
            label.frame = CGRect(x: originX, y: 0, width: tabLabelWidth, height: tabLabelHeight)
            label.text = categories[i].name
            label.addGestureRecognizer(singleTapGesture)
            scrollView.addSubview(label)
            originX += tabLabelWidth
        }
        
        scrollView.contentSize = CGSize(width:originX, height:tabLabelHeight)
        scrollView.frame = CGRect(x: 0, y: (self.navigationController!.navigationBar.frame.size.height)+tabLabelHeight, width: UIScreen.main.bounds.width, height: tabLabelHeight)
    }
    
    func toast(text:String) {
        let bar = UILabel()
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        let barHeight = 60
        bar.frame = CGRect(x: 0, y: screenHeight-CGFloat(barHeight), width: screenWidth, height: CGFloat(barHeight))
        bar.alpha = 0.0
        bar.backgroundColor = .black
        bar.text = text
        bar.textColor = .white
        bar.textAlignment = .center
        UIView.animate(withDuration: 5, delay: 0.0, options: .curveEaseOut ,animations: { () -> Void in
            bar.alpha = 1.0
        }, completion: { _ in
            bar.removeFromSuperview()
        })
        self.view.addSubview(bar)
    }
    
    func getCategories() -> [Category] {
        var isLock = true
        var result:[Category] = []
        AF.request(Setting.BASE_URL+"/api/fetch_categories",method: .post)
            .responseData {response in
                switch response.result {
                    case .success(let data):
                        do {
                            result = try JSONDecoder().decode([Category].self, from: data)
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
    
    func getItems(category_id: Int) -> [Item] {
        var isLock = true
        var result:[Item] = []
        let params = ["categoryId":category_id]
        AF.request(Setting.BASE_URL+"/api/fetch_items",method: .post,parameters: params)
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
    
    func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectItem(sender:)))
        singleTapGesture.numberOfTapsRequired = 1
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.tag = self.items[indexPath.row].id!
        cell.addGestureRecognizer(singleTapGesture)
        let imageView = cell.viewWithTag(101) as! UIImageView
        let cellImage = UIImage(url: self.items[indexPath.row].image_path!)
        imageView.image = cellImage
        
        let nameLabel = cell.viewWithTag(102) as! UILabel
        nameLabel.text = self.items[indexPath.row].name!
        
        let priceLabel = cell.viewWithTag(103) as! UILabel
        priceLabel.text = self.items[indexPath.row].price!.description + "円"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace:CGFloat = 10
        let cellSize:CGFloat = self.view.bounds.width/2 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    @objc func selectCategory(sender:UITapGestureRecognizer) {
        for category in self.categories {
            scrollView.viewWithTag(category.id!)?.backgroundColor = UIColor.white
            (scrollView.viewWithTag(category.id!) as! UILabel).textColor = UIColor.black
        }
        (sender.view! as! UILabel).backgroundColor = UIColor.lightGray
        (sender.view! as! UILabel).textColor = UIColor.white
        self.items = getItems(category_id: sender.view!.tag)
        collectionView.reloadData()
    }
    
    @objc func selectItem(sender:UITapGestureRecognizer) {
        let alert: UIAlertController = UIAlertController(title: "カートへ", message:  "", preferredStyle:  UIAlertController.Style.alert)
        
        let confirmAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            
            (action: UIAlertAction!) -> Void in
            let cell = sender.view as! UICollectionViewCell
            if var cartItems = self.userDefault.array(forKey: "cartItems") {
                cartItems.append(cell.tag)
                self.userDefault.set(cartItems,forKey: "cartItems")
            } else {
                let ary:[Int] = [cell.tag]
                self.userDefault.set(ary,forKey: "cartItems")
            }
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            
            (action: UIAlertAction!) -> Void in
            alert.dismiss(animated: true, completion: nil)
        })

        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func cartItem(_ sender:UIBarButtonItem) {
        let modal = self.storyboard?.instantiateViewController(identifier: "modal")
        modal?.modalPresentationStyle = .fullScreen
        present(modal!, animated: true, completion: nil)
    }
}

extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}
