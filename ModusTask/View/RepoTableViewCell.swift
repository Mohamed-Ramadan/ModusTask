//
//  RepoTableViewCell.swift
//  TestGithubRepos
//
//  Created by macbook on 7/19/19.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit
import Foundation

class RepoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var forksCountLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    } 
    
    func configureCell (_ repo: Reposatory) {
        selectionStyle = .none
        
        titleLabel.text = repo.name
        descriptionLabel.text = repo.repoDescription
        forksCountLabel.text = "\(repo.forksCount)"
        languageLabel.text =  repo.language?.rawValue ?? "-"
        createdAtLabel.text = Date.getFormattedDate(string: repo.createdAt, formatter: "MMM dd,yyyy")
        loadUserImage(from: URL(string: repo.owner.avatarURL)!)
    }
    
    func loadUserImage(from url:URL) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as String as NSString) {
            // set cached image to image veiw
            self.userImageView.image = cachedImage
        } else {
            getData(from: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        // cache image
                        self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        
                        // set image to image view
                        self.userImageView.image = image
                    }
                }
            }
        }
        
    }
    
    func getData(from url:URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
}

extension Date {
    static func getFormattedDate(string: String , formatter:String) -> String{
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = formatter
        
        let date: Date? = dateFormatterGet.date(from: string)
        return dateFormatterPrint.string(from: date!);
    }
}
