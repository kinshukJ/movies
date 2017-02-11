//
//  MoviesViewController.swift
//  Movies
//
//  Created by Kinshuk Juneja on 1/31/17.
//  Copyright © 2017 CS490. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    var movies: [NSDictionary]?
    var endPoint : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        // Initialize a UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: .valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        refreshControlAction(refreshControl)

    }

    func refreshControlAction(_ refreshControl: UIRefreshControl) {

        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endPoint!)?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        
        
        // Display HUD right before the request is made
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            // Hide HUD once the network request comes back (must be done on main UI thread)
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if let data = data {
                
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    //                    print(dataDictionary)
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]!
                    self.tableView.reloadData()
                    
                }
            }
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
            
            // Tell the refreshControl to stop spinning
            refreshControl.endRefreshing()
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        else {
            print("mvoeis is nill")

            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
//        Use a red color when the user selects the cell
//        let backgroundView = UIView()
//        backgroundView.backgroundColor = UIColor.red
//        cell.selectedBackgroundView = backgroundView
        cell.selectionStyle = .none
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        
        if let posterPath = movie["poster_path"] as? String {
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        
        cell.posterImage.setImageWith(imageUrl as! URL)
        
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
               print("row \(indexPath.row)")
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![(indexPath?.row)!]
        
        let detailViewController = segue.destination as! DetailViewController
        detailViewController.movie = movie
        
        
    }
    
}
