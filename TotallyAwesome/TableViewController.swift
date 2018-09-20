//
//  MainTableViewController.swift
//  TotallyAwesome
//
//  Created by Dai Tran on 9/19/18.
//  Copyright © 2018 Dai Tran. All rights reserved.
//

import UIKit

class CellData {
    var id: String
    var image: UIImage
    
    init(id: String, image: UIImage) {
        self.id = id
        self.image = image
    }
}

protocol TableViewProtocol: class {
    func passId(id:String)
}

class TableViewController: UITableViewController, TableViewProtocol {
    
    var cells: [CellData] = [CellData]()
    var id: String? = nil
    var delegate: TableViewProtocol?
    
    let cellId = "cellId"
    
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .gray
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        let cellXib = UINib.init(nibName: "TableViewCell", bundle: nil)
        tableView.register(cellXib, forCellReuseIdentifier: cellId)
        tableView.separatorStyle = .none
        
        navigationItem.title = "Feeds"
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        var url = URL(string: "https://api.popjam.com/v2/users/05fea6f3-4c9b-4c77-b321-8734623662ec/homeFeed")!
        if let id = id {
            let stringURL = "https://api.popjam.com/v2/users/05fea6f3-4c9b-4c77-b321-8734623662ec/homeFeed?lastId=" + id
            url = URL(string: stringURL)!
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if (error != nil) {
                print(error!)
            }

            guard let data = data else { return }

            guard let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
            guard let json = jsonObj as? [String: Any] else { return }

            guard let feedItems = json["feedItems"] as? [[String: Any]] else { return }
            for i in 0..<feedItems.count {
                let item = feedItems[i]
                guard let sourceImg = item["imageSrc"] as? String else {
                    if i == feedItems.count - 1 {
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                        }
                    }
                    continue
                }
                guard let id = item["id"] as? String else {
                    print("Id errr")
                    return
                }

                let url = URL(string: sourceImg)!
                URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                    if (error != nil) {
                        print(error!)
                    }

                    guard let image = UIImage(data: data!) else { return }

                    let cellData = CellData(id: id, image: image)
                    self.cells.append(cellData)

                    if i == feedItems.count - 1 {
                        DispatchQueue.main.async {
                            self.loadingIndicator.stopAnimating()
                            self.tableView.reloadData()
                        }
                    }

                }).resume()
            }

        }.resume()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cells.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TableViewCell
        if (indexPath.row < cells.count) {
            cell.mainImageView.image = cells[indexPath.row].image
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.width
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainTableViewController = TableViewController()
        let cellData = cells[indexPath.row]
        mainTableViewController.passId(id: cellData.id)
        navigationController?.pushViewController(mainTableViewController, animated: true)
    }
    
    func passId(id: String) {
        self.id = id
    }

}
