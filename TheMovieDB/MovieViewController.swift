//
//  MovieTableViewController.swift
//  TheMovieDB
//
//  Created by Dinh Quang Hieu on 7/5/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController:UISearchController!
    var refreshControl = UIRefreshControl()
    var loadingNotification:MBProgressHUD!
    
    var movies = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var baseUrl = "http://image.tmdb.org/t/p/w342/"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        initRefreshControl()
        initSearchBar()
        showLoadingNotification()
        loadData()
        
    }
    
    func showLoadingNotification() {
        loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func initRefreshControl() {
        refreshControl.addTarget(self, action: #selector(MovieViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)

    }
    
    func initSearchBar() {
        //self.navigationController!.navigationBar.barTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar

    }
    
    
    func loadData() {
        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "No internet connection", message: nil, preferredStyle: .Alert)
            let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(actionOk)
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            self.refreshControl.endRefreshing()
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        
        movies.removeAll()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
                                                                     completionHandler: { (dataOrNil, response, error) in
                                                                        if let data = dataOrNil {
                                                                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                                                                data, options:[]) as? NSDictionary {
                                                                                //print("response: \(responseDictionary)")
                                                                                self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                                self.tableView.reloadData()
                                                                                self.refreshControl.endRefreshing()
                                                                                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                                                                            }
                                                                        }
        })
        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies.count
        }
        return movies.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieCell
        
        var movie:NSDictionary
        
        if searchController.active && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        
        cell.lblTitle.text = movie["title"] as? String
        cell.lblOverview.text = movie["overview"] as? String
        let imgView = cell.imgViewPoster
        if let posterPath = movie["poster_path"] as? String {
            let lowResBaseUrl = "https://image.tmdb.org/t/p/w45"
            let highResBaseUrl = "https://image.tmdb.org/t/p/original"
            let posterUrl = NSURL(string: highResBaseUrl + posterPath)
            cell.imgViewPoster.setImageWithURLRequest(NSURLRequest(URL: posterUrl!), placeholderImage: nil, success: { (request, respone, image) in
                    imgView.alpha = 0.0
                    imgView.image = image
                    UIView.animateWithDuration(0.5, animations: {
                        imgView.alpha = 1
                    })
                    //imgView.setImageWithURL(NSURL(string: highResBaseUrl + posterPath)!, placeholderImage: image)
                }, failure: nil)
        }
        else {
            cell.imgViewPoster.image = nil
        }
        
        return cell
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredMovies = movies.filter { movie in
            return movie["title"]!.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
