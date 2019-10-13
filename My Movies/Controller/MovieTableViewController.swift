//
//  MovieTableViewController.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 12/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class MovieTableViewController: UITableViewController {
    var movies: [Movie] = []
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        self.loadMovies()
        
        MovieProvider.shared.addDelegate(self)
    }
    
    private func loadMovies() {
        MovieProvider.shared.getPopularMovies(completion: { movies in
            DispatchQueue.main.async {
                self.movies = movies
                self.tableView.reloadData()
            }
        }, failure: { error in
        })
    }
}

// MARK: - Events
extension MovieTableViewController {
    override func didReceiveMemoryWarning() {
        for movie in self.movies {
            movie.detailResult = nil
            movie.videoResult = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showMovie" {
            guard let movieDetailVC = segue.destination as? MovieDetailViewController else {
                assertionFailure("Couldn't find MovieDetailViewController as destination of the 'showMovie' segue")
                return
            }
            
            guard let movie = sender as? Movie else {
                assertionFailure("'showMovie' segue started without an associated movie object")
                return
            }
            
            if !movie.isDetailInfoLoaded {
                MovieProvider.shared.downloadMovieDetails(movie)
            }
            
            movieDetailVC.movie = sender as? Movie
        }
    }
}

// MARK: - UITableViewDelegate
extension MovieTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = self.movies[indexPath.row]
        self.performSegue(withIdentifier: "showMovie", sender: movie)
    }
}

// MARK: - UITableViewDataSource
extension MovieTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movie = self.movies[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as? MovieTableViewCell else {
            fatalError("Could not instantiate movie table view cell")
        }
        
        cell.titleLabel.text = movie.title
        cell.backdropImageView.image = movie.backdropImage
        
        return cell
    }
}

// MARK: - MovieProviderDelegate
extension MovieTableViewController: MovieProviderDelegate {
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingBackdropImageForMovie movie: Movie) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingBackdropImageForMovie movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieDetails movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieDetails movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieTrailer movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieTrailer movie: Movie) {
    }
}
