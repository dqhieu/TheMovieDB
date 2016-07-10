//
//  MovieDetailViewController.swift
//  TheMovieDB
//
//  Created by Dinh Quang Hieu on 7/10/16.
//  Copyright © 2016 Dinh Quang Hieu. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import youtube_ios_player_helper

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblOverview: UILabel!
    @IBOutlet weak var containView: UIView!
    
    var movieID:Int!
    var movieInfo = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor(patternImage: UIImage(named: "backbuttoncolor.png")!)
        
        showLoadingNotification()
        downloadData()
    }

    func showLoadingNotification() {
        var loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.Indeterminate
        loadingNotification.labelText = "Loading"
    }
    
    func downloadData() {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(movieID)?api_key=\(apiKey)&append_to_response=trailers")
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
                    self.movieInfo = responseDictionary
                    MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
                    self.loadData()
                }
            }
        })
        task.resume()
    }
    
    func loadData() {
        // load image
        if let photoPath = movieInfo["poster_path"] as? String {
            let mediumResBaseUrl = "https://image.tmdb.org/t/p/w342"
            let highResBaseUrl = "https://image.tmdb.org/t/p/original"
            let posterUrl = NSURL(string: mediumResBaseUrl + photoPath)
            self.imgViewPhoto.setImageWithURLRequest(NSURLRequest(URL: posterUrl!), placeholderImage: nil, success: { (request, respone, mediumResimage) in
                self.imgViewPhoto.alpha = 0.0
                self.imgViewPhoto.image = mediumResimage
                UIView.animateWithDuration(0.5, animations: {
                    self.imgViewPhoto.alpha = 1.0
                    }, completion: { (success) in
                        self.imgViewPhoto.setImageWithURLRequest(NSURLRequest(URL: NSURL(string: highResBaseUrl + photoPath)!), placeholderImage: mediumResimage, success: { (req, resp, highResImage) in
                            self.imgViewPhoto.image = highResImage
                            }, failure: nil)
                        
                })
                }, failure: nil)
        }
        else {
            self.imgViewPhoto.image = nil
        }

        // load info
        lblName.text = movieInfo["title"] as! String
        lblDate.text = movieInfo["release_date"] as! String
        lblDuration.text = "\(movieInfo["runtime"] as! Int) mins"
        lblRating.text = String(movieInfo["vote_average"] as! Double)
        lblOverview.text = movieInfo["overview"] as! String
        lblOverview.numberOfLines = 0
        lblOverview.sizeToFit()
        playerView.frame.origin.y = lblOverview.frame.origin.y + lblOverview.frame.height + 10
        
        // load video
        let trailers = movieInfo["trailers"] as! NSDictionary
        let youtube = trailers["youtube"] as! [NSDictionary]
        if youtube.count > 0 {
            self.playerView.loadWithVideoId(youtube[0]["source"] as! String)
            self.playerView.setPlaybackQuality(YTPlaybackQuality.Auto)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if (recognizer.state == .Began) {
            
        }
        else if (recognizer.state == .Changed) {
            containView.frame.origin.y = containView.frame.origin.y + translation.y / 10
            if containView.frame.origin.y > self.view.frame.height - 40 {
                containView.frame.origin.y = 627
            }
            let bottom = (playerView.superview?.frame.origin.y)! + playerView.frame.origin.y + playerView.frame.height
            if bottom < self.view.frame.height - 20 {
                containView.frame.origin.y = self.view.frame.origin.y + self.view.frame.height - (playerView.frame.origin.y + playerView.frame.height + 20)
                
            }

        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
