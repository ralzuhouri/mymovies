//
//  MovieDetailViewController.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 13/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    var movie: Movie?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var overviewLabel: UITextView!
    @IBOutlet weak var noMovieSelectedLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        MovieProvider.shared.addDelegate(self)
        
        self.refreshData()
    }
    
    private func refreshData() {
        DispatchQueue.main.async {
        
        	guard let movie = self.movie else {
                // This happens when the view controller is loaded without
                // a movie (e.g. when the app is launched in portrait on
                // the iPad): the detail is presented, but without that a movie
                // has been set. I want to hide all the views and show the
                // noMovieSelectedLabel label, which communicates to the user
                // that no movie has been selected yet.
                self.scrollView.subviews.forEach {
                    $0.isHidden = true
                }
                
                self.noMovieSelectedLabel.isHidden = false
                
            	return
        	}
        
        	self.backdropImageView.image = self.movie?.backdropImage
            self.titleLabel.text = movie.title
        	self.genresLabel.text = movie.genres?.joined(separator: ", ")
        
        	if let releaseDate = movie.releaseDate {
            	let formatter = DateFormatter()
            	formatter.dateStyle = .long
            	self.dateLabel.text = formatter.string(from: releaseDate)
        	}
        
        	self.overviewLabel.text = movie.overview
        }
    }
}

// MARK: - Events
extension MovieDetailViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showTrailer" {
            // I want to be able to pass information to the view controller
            // that will present the trailer. I pass a movie object.
            guard let movieTrailerVC = segue.destination as? MovieTrailerViewController else {
                assertionFailure("Could not find MovieTrailerViewController destination object in 'showTrailer' segue")
                return
            }
            
            guard let movie = self.movie else {
                assertionFailure("Could not find movie that triggered the 'showTrailer' segue")
                return
            }
            
            if !movie.isTrailerLoaded {
                // The first time this view controller is presented, the movie
                // trailer will not be loaded so I need to tell the movie provider
                // do it (then the appropriate delegate callback will be called)
            	MovieProvider.shared.downloadMovieVideo(movie)
            }
            
            movieTrailerVC.movie = movie
        }
    }
}

// MARK: - MovieProviderDelegate
extension MovieDetailViewController: MovieProviderDelegate {
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingBackdropImageForMovie movie: Movie) {
        guard self.movie === movie else { return }
        
        self.refreshData()
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingBackdropImageForMovie movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieDetails movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieDetails movie: Movie) {
        guard self.movie === movie else { return }
        
        self.refreshData()
    }
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieTrailer movie: Movie) {
    }
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieTrailer movie: Movie) {
    }
}
