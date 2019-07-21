//
//  ReposTableViewController.swift
//  TestGithubRepos
//
//  Created by macbook on 7/19/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class ReposTableViewController: UITableViewController {

    let repoCellId = "RepoTableViewCell"
    var repos:[Reposatory] = []
    var indicator = UIActivityIndicatorView()
    let cachedRepos = NSCache<NSString, Reposatory>() //  used for caching json response
    var pageNumber = 0
    let pageLimit = 10
    var loadMore = true // load more if repos count in the current page is equal to \(pageLimit)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup view controller appearence
        self.setupUI()
        self.setupActivityIndicator()
        
        // register table cell
        self.registerTableViewcell()
        
        // check for cached  data
        if (DataManager.shared().retrieveReposFromJsonFile().count == 0) {
            // load from github api
            self.getUserRepos()
        } else {
            // get repos from cached json
            repos = DataManager.shared().retrieveReposFromJsonFile()
            tableView.reloadData()
            
            if (Reachability.isConnectedToNetwork()) {
                // refresh repos list from api
                self.getUserRepos()
            }
        }
    }

    // MARK: - private methods
    func setupUI() {
        title = "Reposatories"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(didClickRefreshRepoList))
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    @objc func didClickRefreshRepoList() {
        if (Reachability.isConnectedToNetwork()) {
            // back to top of the repos list
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            loadMore = true // restore pagenation
            
            getUserRepos()
        } else {
            let alert = UIAlertController(title: "Network Error", message: "You are not connected to the internet, Please check network connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func getUserRepos() {
        self.showIndicator() // show indicator
        DataManager.shared().laodUserRepos(page: pageNumber, limit: pageLimit) { [weak self] (repos, error) in
            self?.hideIndicator() // hide indicator
            
            if let error = error {
                print("Something went wrong!!! \(error.localizedDescription)")
                return
            }
            
            self?.repos.append(contentsOf: repos)
            self?.tableView.reloadData()
            
            print("# Repos: \(self?.repos.count ?? 0)")
            
            // check if there is more repos to load
            // if there is a remainded then this is the last page
            if let reposCount = self?.repos.count, let limit = self?.pageLimit {
                if (reposCount%limit != 0) {
                    self?.loadMore = false
                }
            }
            
            // save repos to json file
            // Encode data
            let jsonEncoder = JSONEncoder()
            do {
                let data = try jsonEncoder.encode(self?.repos)
                // save repos to json file
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                DataManager.shared().saveReposToJsonFile(jsonData)
            }
            catch {
            }
            
            
        }
    }
    
    func setupActivityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 40,height: 40))
        indicator.style = .whiteLarge
        indicator.backgroundColor = .gray
        indicator.center = view.center
        self.view.addSubview(indicator)
    }
    
    func registerTableViewcell() {
        // register table view cell
        let nib = UINib(nibName: repoCellId, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: repoCellId)
    }
    
    func showIndicator() {
        indicator.startAnimating()
        indicator.backgroundColor = .gray
        indicator.alpha = 1
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            self.indicator.alpha = 0
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return repos.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: repoCellId, for: indexPath) as! RepoTableViewCell

        // Configure the cell...
        cell.configureCell(repos[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // open repo in browser
        let url = URL(string: repos[indexPath.row].url)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == repos.count-1 { // load when reach last visible cell into repos
            if loadMore {
                pageNumber += 1 // increase page number
                self.getUserRepos() // load repos for current page
            }
        }
    }
   
}
