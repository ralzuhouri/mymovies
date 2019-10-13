//
//  MovieProvider.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 12/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import UIKit

// MARK: - MovieProviderDelegate
protocol MovieProviderDelegate: AnyObject {
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingBackdropImageForMovie movie: Movie)
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingBackdropImageForMovie movie: Movie)
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieDetails movie: Movie)
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieDetails movie: Movie)
    
    func movieProvider(_ movieProvider: MovieProvider, failedDownloadingMovieTrailer movie: Movie)
    
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingMovieTrailer movie: Movie)
}

// MARK: - MovieProviderDelegateWrapper
// This class encapsulated a weak MovieProviderDelegate delegate object
class MovieProviderDelegateWrapper: NSObject {
    weak var delegate: MovieProviderDelegate?
    
    init(delegate: MovieProviderDelegate) {
        self.delegate = delegate
    }
}

// MARK: - MovieProvider
// This class is able to load all the information of a Movie object
class MovieProvider {
    static var shared = {
        return MovieProvider()
    }()
    
    private var delegateWrappers: [MovieProviderDelegateWrapper] = []
    var delegates: [MovieProviderDelegate] {
        return delegateWrappers.compactMap {
            $0.delegate
        }
    }
    
    func addDelegate(_ delegate: MovieProviderDelegate) {
        delegateWrappers.append(MovieProviderDelegateWrapper(delegate: delegate))
    }
    
    private let apiKey = "ad7aab374970181ee8a5914ba2d5a709"
    private let baseUrl = "https://api.themoviedb.org/3/movie"
    private let imageBaseUrl = "https://image.tmdb.org/t/p"
    
    private var popularMoviesUrl: String {
        return "\(self.baseUrl)/popular?api_key=\(self.apiKey)"
    }
    
    private func movieDetailPath(movie: Movie) -> String {
        return "\(self.baseUrl)/\(movie.id)?api_key=\(self.apiKey)"
    }
    
    private func movieVideoPath(movie: Movie) -> String {
        return "\(self.baseUrl)/\(movie.id)/videos?api_key=\(self.apiKey)"
    }
    
    private func movieBackdropPath(_ movie: Movie) -> String {
        return "\(self.imageBaseUrl)/w500/\(movie.backdropPath)"
    }
    
    private init() {}
}

// MARK: - Getting Movies
extension MovieProvider {
    func getPopularMovies(completion: @escaping ([Movie]) -> Void, failure: @escaping (Error) -> Void) {
        
        guard let url = URL(string: self.popularMoviesUrl) else {
            assertionFailure("Could not construct popular movies URL")
            return
        }
        
        let helper = UrlSessionHelper()
        
        helper.runTask(url: url, completion: { jsonString in
            do {
            	let decoder = JSONDecoder()
                let queryResult = try decoder.decode(PopularMoviesQueryResult.self, from: jsonString)
                
                let movies = queryResult.results.map { movieResult -> Movie in
                    let movie = Movie(result: movieResult)
                    self.downloadBackdropImage(movie: movie)
                    return movie
                }
                
                completion(movies)
            }
            catch {
                print("Failed to decode popular movies with error: \(error)")
                failure(error)
            }
        }, failure: { error in
            print("Failed to retrieve popular movies with error: \(error)")
            failure(error)
        })
    }
    
    private func downloadBackdropImage(movie: Movie) {
        guard let url = URL(string: self.movieBackdropPath(movie)) else {
            assertionFailure("Could not construct movie's backdrop image url")
            return
        }
        
        let helper = UrlSessionHelper()
        
        helper.runTask(url: url, completion: { data in
            
            movie.backdropImage = UIImage(data: data)
            
            for delegate in self.delegates {
            	delegate.movieProvider(self, finishedDownloadingBackdropImageForMovie: movie)
            }
            
        }, failure: { error in
            for delegate in self.delegates {
            	delegate.movieProvider(self, failedDownloadingBackdropImageForMovie: movie)
            }
        })
    }
    
    func downloadMovieDetails(_ movie: Movie) {
        guard let url = URL(string: self.movieDetailPath(movie: movie)) else {
            assertionFailure("Could not construct movie's detail information url")
            return
        }
        
        let helper = UrlSessionHelper()
        
        helper.runTask(url: url, completion: { data in
            
            do {
                let details = try JSONDecoder().decode(MovieDetailResult.self, from: data)
                movie.detailResult = details
                
                for delegate in self.delegates {
                	delegate.movieProvider(self, finishedDownloadingMovieDetails: movie)
                }
            } catch {
                for delegate in self.delegates {
                	delegate.movieProvider(self, finishedDownloadingMovieDetails: movie)
                }
            }
        }, failure: { error in
            for delegate in self.delegates {
            	delegate.movieProvider(self, failedDownloadingMovieDetails: movie)
            }
        })
    }
    
    func downloadMovieVideo(_ movie: Movie) {
        guard let url = URL(string: self.movieVideoPath(movie: movie)) else {
            assertionFailure("Could not construct movie's video url")
            return
        }
        
        let helper = UrlSessionHelper()
        
        helper.runTask(url: url, completion: { data in
            
            do {
                let result = try JSONDecoder().decode(MovieVideoResult.self, from: data)
                movie.videoResult = result
                
                for delegate in self.delegates {
                    delegate.movieProvider(self, finishedDownloadingMovieTrailer: movie)
                }
            } catch {
                for delegate in self.delegates {
                    delegate.movieProvider(self, failedDownloadingMovieTrailer: movie)
                }
            }
        }, failure: { error in
            for delegate in self.delegates {
                delegate.movieProvider(self, failedDownloadingMovieTrailer: movie)
            }
        })
    }
}
