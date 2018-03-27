//
//  RecFeedViewController.swift
//  GetRecd
//
//  Created by Dhruv Upadhyay on 3/26/18.
//  Copyright © 2018 CS 407. All rights reserved.
//

import UIKit
import FirebaseAuth

class RecFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var currentUser: User?
    
    @IBOutlet weak var recFeedTableView: UITableView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var movies = [Movie]() {
        didSet {
            DispatchQueue.main.async {
                self.recFeedTableView.reloadData()
            }
        }
    }
    
    var shows = [Show]() {
        didSet {
            DispatchQueue.main.async {
                self.recFeedTableView.reloadData()
            }
        }
    }
    
    var songs = [Song]() {
        didSet {
            DispatchQueue.main.async {
                self.recFeedTableView.reloadData()
            }
        }
    }
    
    var likedAppleMusicSongs = Set<String>()
    var likedSpotifySongs = Set<String>()
    var likedMovies = Set<Int>()
    var likedTVShows = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        likeButton.isHidden = true
        
        getCurrentUser()
        
        getMovies()
        
        recFeedTableView.delegate = self
        recFeedTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getCurrentUser()
    }
    
    func getCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DataService.instance.getUser(userID: uid) { (user) in
            self.currentUser = user
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch  segmentedControl.selectedSegmentIndex {
        case 0:
            return songs.count
        case 1:
            return movies.count
        case 2:
            return shows.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongCell
            
            // Reset the cell from previous use:
            cell.artistLabel.text = ""
            cell.artworkView.image = UIImage()
            cell.nameLabel.text = ""
            
            cell.tag = indexPath.row
            cell.artworkView.tag = indexPath.row
            let song = songs[indexPath.row]
            cell.song = song
            return cell
            case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
            
            // Reset the cell from previous use:
            cell.releaseLabel.text = ""
            cell.nameLabel.text = ""
            cell.artworkView.image = UIImage()
            
            cell.tag = indexPath.row
            cell.artworkView.tag = indexPath.row
            let movie = movies[indexPath.row]
            cell.movie = movie
            return cell
            case 2:
            // Note: we're using a movie cell as a tv show cell as well for efficiency 😄
            let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
            
            // Reset the cell from previous use:
            cell.releaseLabel.text = ""
            cell.nameLabel.text = ""
            cell.artworkView.image = UIImage()
            
            cell.tag = indexPath.row
            cell.artworkView.tag = indexPath.row
            let show = shows[indexPath.row]
            cell.show = show
            return cell
            default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            if let cell = tableView.cellForRow(at: indexPath) as? SongCell {
                
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    switch cell.song.type {
                    case .AppleMusic:
                        likedAppleMusicSongs.remove(cell.song.id)
                    case .Spotify:
                        likedSpotifySongs.remove(cell.song.id)
                    default:
                        break
                    }
                } else {
                    cell.accessoryType = .checkmark
                    switch cell.song.type {
                    case .AppleMusic:
                        likedAppleMusicSongs.insert(cell.song.id)
                    case .Spotify:
                        likedSpotifySongs.insert(cell.song.id)
                    default:
                        break
                    }
                }
            }
            
            if likedAppleMusicSongs.count > 0 || likedSpotifySongs.count > 0 {
                likeButton.isHidden = false
            } else {
                likeButton.isHidden = true
            }
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            if let cell = tableView.cellForRow(at: indexPath) as? MovieCell {
                
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    likedMovies.remove(cell.movie.id)
                } else {
                    cell.accessoryType = .checkmark
                    likedMovies.insert(cell.movie.id)
                }
            }
            
            if likedMovies.count > 0 {
                likeButton.isHidden = false
            } else {
                likeButton.isHidden = true
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            if let cell = tableView.cellForRow(at: indexPath) as? MovieCell {
                
                if cell.accessoryType == .checkmark {
                    cell.accessoryType = .none
                    likedTVShows.remove(cell.show.id)
                } else {
                    cell.accessoryType = .checkmark
                    likedTVShows.insert(cell.show.id)
                }
            }
            
            if likedTVShows.count > 0 {
                likeButton.isHidden = false
            } else {
                likeButton.isHidden = true
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            break
        }
    }
    
    @IBAction func didSelectSegment(_ sender: Any) {
        DispatchQueue.main.async {
            self.recFeedTableView.reloadData()
        }
    }
    
    @IBAction func onAdd(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            DataService.instance.likeSongs(appleMusicSongs: likedAppleMusicSongs, spotifySongs: likedSpotifySongs, success: {
            })
        case 1:
            DataService.instance.likeMovies(movies: likedMovies, success: {
            })
        case 2:
            DataService.instance.likeShows(shows: likedTVShows, success: {
            })
        default:
            break
        }
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func getMovies() {
        let currUserLikes = DataService.instance.REF_USERLIKES.child(Auth.auth().currentUser!.uid)
        let movieLikes = currUserLikes.child("Movies")
        MovieService.sharedInstance.searchTMDB(forMovie: "Star Wars") { (movies, error) in
            if error == nil, let moviesArr = movies {
                self.movies = moviesArr
            }
        }
    }
}
