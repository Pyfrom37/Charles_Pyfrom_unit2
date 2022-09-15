//
//  MoviesViewController.swift
//  Flix
//
//  Created by Anita on 1/25/16.
//  Copyright © 2016 Anita Leung. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet var navi: UIView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var filteredMovies = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkErrorView.alpha = 0.0
        noResultsLabel.hidden = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchBar.delegate = self
        
        // Shadow on navigation
        navi.layer.shadowColor = UIColor.blackColor().CGColor
        navi.layer.shadowOpacity = 0.3
        navi.layer.shadowOffset = CGSizeZero
        navi.layer.shadowRadius = 3
        navi.layer.shadowPath = UIBezierPath(rect: navi.bounds).CGPath
        navi.layer.shouldRasterize = true
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        
      refreshControl.bounds = CGRectMake(0, 90, refreshControl.bounds.size.width, refreshControl.bounds.size.height)
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        refreshControlAction(refreshControl)
    }
    
    let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
    let task = session.dataTask(with: request) { (data, response, error) in
         // This will run when the network request returns
         if let error = error {
                print(error.localizedDescription)
         } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]

                // TODO: Get the array of movies
                // TODO: Store the movies in a property to use elsewhere
                // TODO: Reload your table view data
            self.movies = dataDictionary["results"] as! [[String:Any]]
            print(self.movies)

         }
    }
    task.resume()
                            
                           
                            
   
                    }
                }
                // Network error
                if let _ = error {
                    refreshControl.endRefreshing()
                    UIView.animateWithDuration(0.2, animations: {() -> Void in
                        self.networkErrorView.alpha = 1.0
                    })
                }
        })
        task.resume()
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = filteredMovies[indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
}

// MARK: - UICollectionViewDataSource
extension MoviesViewController: UICollectionViewDataSource {
  // Return appropriate number of movies
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filteredMovies.count
  }
  
  // Populate collection cell with movie posters
  func collectionView(collectionView: UICollectionView,
    cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("codepath.MovieCollectionCell",
        forIndexPath: indexPath) as! MovieCollectionCell
      let movie = filteredMovies[indexPath.row]
      
      //cell.titleLabel.text = title
      //cell.overviewLabel.text = overview
      //cell.moviePoster.setImageWithURL(imageUrl!)
      
      if let posterPath = movie["poster_path"] as? String {
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let imageUrl = NSURL(string: baseUrl + posterPath) {
          let imageRequest = NSURLRequest(URL: imageUrl)
          
          // Fade movie poster in
          cell.moviePoster.setImageWithURLRequest(imageRequest, placeholderImage: nil,
            success: {(imagerequest, imageResponse, image) -> Void in
              if imageResponse != nil {
                cell.moviePoster.alpha = 0.0
                cell.moviePoster.image = image
                UIView.animateWithDuration(0.3, animations: {() -> Void in
                  cell.moviePoster.alpha = 1.0
                })
              } else {
                cell.moviePoster.image = image
              }},
            failure: nil
          )
        }
      }
      return cell
  }
}

// MARK: - UISearchBarDelegate
extension MoviesViewController: UISearchBarDelegate {
  // Behavior for searchbar
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      filteredMovies = movies!
    } else {
      filteredMovies = (movies?.filter({(movie: NSDictionary) -> Bool in
        if (movie["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
          return true
        } else {
          return false
        }
      }))!
      if filteredMovies.count == 0 {
        noResultsLabel.hidden = false
      } else {
        noResultsLabel.hidden = true
      }
    }
    collectionView.reloadData()
  }
  
  // Show cancel button on searchbar when being used
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    self.searchBar.setShowsCancelButton(true, animated: true)
  }
  
  // Clear search bar when cancel is hit
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.resignFirstResponder()
    searchBar.text = ""
    filteredMovies = movies!
    noResultsLabel.hidden = true
    collectionView.reloadData()
  }
}

