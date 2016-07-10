//
//  ViewController.swift
//  TheMovieDB
//
//  Created by Dinh Quang Hieu on 7/10/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieNowPlayingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate  {

    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let gridFlowLayout = MovieGridFlowLayout()
    let listFlowLayout = MovieListFlowLayout()
    
    var isGridFlowLayoutUsed: Bool = false
    var searchController:UISearchController!
    var refreshControl = UIRefreshControl()
    
    var movies = [NSDictionary]()
    var filteredMovies = [NSDictionary]()
    var baseUrl = "http://image.tmdb.org/t/p/w342/"

    @IBOutlet weak var btnLayoutChange: UIBarButtonItem!
    
   
    @IBAction func onBtnChangeLayoutPressed(sender: AnyObject) {
        if isGridFlowLayoutUsed {
            UIView.animateWithDuration(0.2) { () -> Void in
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.setCollectionViewLayout(self.listFlowLayout, animated: true)
            }
            self.collectionView.pagingEnabled = true
            btnLayoutChange.image = UIImage(named: "grid_view.png")

        }
        else {
            UIView.animateWithDuration(0.2) { () -> Void in
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.setCollectionViewLayout(self.gridFlowLayout, animated: true)
            }
            self.collectionView.pagingEnabled = false
            btnLayoutChange.image = UIImage(named: "horizontal_list_view.png")

        }
        
        isGridFlowLayoutUsed = !isGridFlowLayoutUsed
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.barTintColor = UIColor(patternImage: UIImage(named: "bar.png")!)
        setupInitialLayout()
        initSearchBar()
        initRefreshControl()
        showLoadingNotification()
        loadData()
        
    }
    
    func showLoadingNotification() {
        var loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func setupInitialLayout() {
        isGridFlowLayoutUsed = true
        collectionView.collectionViewLayout = gridFlowLayout
    }
    
    func initRefreshControl() {
        refreshControl.addTarget(self, action: #selector(MovieNowPlayingViewController.loadData), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        
    }
    
    func initSearchBar() {
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
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                }
            }
        })
        task.resume()

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredMovies.count
        }
        return movies.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        var movie:NSDictionary
        
        if searchController.active && searchController.searchBar.text != "" {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        cell.lblName.text = movie["title"] as? String
        cell.lblRating.text = String(movie["vote_average"]as! Double)
        
        let imgView = cell.imgViewPhoto
        if let posterPath = movie["poster_path"] as? String {
            let mediumResBaseUrl = "https://image.tmdb.org/t/p/w342"
            let highResBaseUrl = "https://image.tmdb.org/t/p/original"
            let posterUrl = NSURL(string: mediumResBaseUrl + posterPath)
            cell.imgViewPhoto.setImageWithURLRequest(NSURLRequest(URL: posterUrl!), placeholderImage: nil, success: { (request, respone, mediumResimage) in
                imgView.alpha = 0.0
                imgView.image = mediumResimage
                UIView.animateWithDuration(0.5, animations: {
                    imgView.alpha = 1.0
                    }, completion: { (success) in
                        imgView.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: highResBaseUrl + posterPath)!), placeholderImage: mediumResimage, success: { (req, resp, highResImage) in
                            imgView.image = highResImage
                            }, failure: nil)

                })
            }, failure: nil)
        }
        else {
            cell.imgViewPhoto.image = nil
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
        
        collectionView.reloadData()
    }
    
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueDetail" {
            let vc = segue.destinationViewController as! MovieDetailViewController
            let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
            var movie:NSDictionary
            if searchController.active && searchController.searchBar.text != "" {
                movie = filteredMovies[indexPath!.row]
            } else {
                movie = movies[indexPath!.row]
            }
            vc.movieID = movie["id"] as! Int
        }
        
    }
    

}
