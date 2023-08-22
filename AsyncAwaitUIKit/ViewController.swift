//
//  ViewController.swift
//  AsyncAwaitUIKit
//
//  Created by Maliks on 22/08/2023.
//

import UIKit

struct User: Codable {
    let name: String
}

class ViewController: UIViewController, UITableViewDataSource {

    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    
    private var users = [User]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
        tableView.dataSource = self
        
        //async <- Depricated {
        Task(priority: .background) {
            let users = await fetchUsers()
            self.users = users
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func fetchUsers() async -> [User] {
        guard let url = url else {
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let users = try JSONDecoder().decode([User].self, from: data)
            return users
        }
        catch {
            return []
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }
}

