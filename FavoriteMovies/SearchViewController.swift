//
//  SearchViewController.swift
//  FavoriteMovies
//
//  Created by JESUS MANUEL RIOS OLIVAS  on 6/7/19.
//  Copyright © 2019 JESUS MANUEL RIOS OLIVAS . All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var searchText: UITextField!
    @IBOutlet var tableView: UITableView!
    
    weak var delegate: ViewController!
    
    var searchResults: [Movie] = []
    
    @IBAction func search (sender: UIButton) {
        print("Searching!")
        let searchTerm = searchText.text!
        if(searchTerm.count > 2) {
            retrieveMoviesByTerm(searchTerm: searchTerm)
        }
    }
    
    @IBAction func addFav(sender: UIButton) -> Void {
        self.delegate.favoriteMovies.append(searchResults[sender.tag])
    }
    
    func retrieveMoviesByTerm(searchTerm: String) {
        let url = "https://www.omdbapi.com/?s=\(searchTerm)&type=movie&r=json"
        HTTPHandler.getJson(urlString: url, completionHandler: parseDataIntoMovies)
    }
    
    func parseDataIntoMovies(data: Data?) -> Void {
        if let data = data {
            let object = JSONParser.parse(data: data)
            if let object = object {
                self.searchResults = MovieDataProcessor.mapJsonToMovies(object: object, moviesKey: "Search")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Search Results"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moviecell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! CustomTableViewCell
        
        let idx: Int = indexPath.row
        moviecell.favButton.tag = idx
        
        moviecell.movieTitle?.text = searchResults[idx].title
        moviecell.movieYear?.text = searchResults[idx].year
        displayMovieImage(idx, moviecell: moviecell)
        
        return moviecell
    }
    
    func displayMovieImage(_ row: Int, moviecell: CustomTableViewCell) {
        let url: String = (URL(string: searchResults[row].imageUrl)?.absoluteString)!
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                let image = UIImage(data: data!)
                moviecell.movieImageView?.image = image
            })
        }).resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
