//
//  DataManager.swift
//  TestGithubRepos
//
//  Created by M R on 7/21/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import Foundation

class DataManager {
    
    private static var sharedDataManager: DataManager = {
        let dataManager = DataManager()
        
        return dataManager
    }()
    
    class func shared() -> DataManager {
        return sharedDataManager
    }
    
    
    func laodUserRepos(page:Int, limit:Int, competion :@escaping ([Reposatory], Error?)->()) {
        guard let url = URL(string: "https://api.github.com/users/johnsundell/repos?page=\(page)&per_page=\(limit)") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Something went wrong!!! \(error.localizedDescription)")
                competion([], error)
                return
            }
            
            guard let data = data else {
                print("There is no data")
                competion([], error)
                return
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                //print(jsonData)
                
                // reload UI in the main thread
                DispatchQueue.main.async {
                    // decode json data to Repo model
                    guard let repos = try? JSONDecoder().decode([Reposatory].self, from: data) else {
                        return
                    }  
                    
                    competion(repos, nil)
                }
            } catch {
                print(error.localizedDescription)
                competion([], error)
            }
            }.resume()
    }
    
    func saveReposToJsonFile(_ repos:Any) {
        // Get the url of Repos.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("Repos.json")
        
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: repos, options: [])
            try data.write(to: fileUrl, options: [])
        } catch {
            print(error)
        }
    }
    
    func retrieveReposFromJsonFile() -> [Reposatory] {
        // Get the url of Repos.json in document directory
        guard let documentsDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        let fileUrl = documentsDirectoryUrl.appendingPathComponent("Repos.json")
        
        // Read data from .json file and transform data into an array
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            guard let repos = try? JSONDecoder().decode([Reposatory].self, from: data) else {
                print("error parsing json data")
                return []
            }
            return repos
        } catch {
            print(error)
        }
        
        return []
    }
}
