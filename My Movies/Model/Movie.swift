//
//  Movie.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 12/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Codable structs
// Those structs are directly encoded/decoded from json

struct PopularMoviesQueryResult: Codable {
    var results: [MovieResult]
}

struct MovieGenre: Codable {
    var name: String
}

struct MovieResult: Codable {
    var id: Int
    var title: String
    var backdrop_path: String
}

struct MovieDetailResult: Codable {
    var genres: [MovieGenre]
    var release_date: String
    var overview: String
}

struct MovieVideoResult: Codable {
    var results: [Video]
}

struct Video: Codable {
   	var key: String
}

// MARK: - Movie
// The Movie class encapsulates all the above structs.
// It is meant to be loaded with partial information and then
// more details can be added as they get loaded from the web (e.g.
// backdrop image, trailer).
class Movie {
    // The basic information that must be contained in this class
    // is in the MovieResult value
    let result: MovieResult
    
    // Those properties can be loaded later, from the video provider
    var detailResult: MovieDetailResult?
    var backdropImage: UIImage?
    var videoResult: MovieVideoResult?
    
    var isDetailInfoLoaded: Bool {
        return detailResult != nil
    }
    
    var isTrailerLoaded: Bool {
        return videoResult != nil
    }
    
    init(result: MovieResult) {
        self.result = result
    }
    
    var id: Int {
        return result.id
    }
    
    var title: String {
        return result.title
    }
    
    var backdropPath: String {
        return result.backdrop_path
    }
    
    var genres: [String]? {
        return detailResult?.genres.map { genre in
            return genre.name
        }
    }
    
    var releaseDate: Date? {
        guard let releaseDateString = detailResult?.release_date else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd"
        return formatter.date(from: releaseDateString)
    }
    
    var overview: String? {
        return detailResult?.overview
    }
    
    // Assumes that the video is hosted on youtube
    var trailerUrl: URL? {
        guard let video = self.videoResult?.results.first else {
            return nil
        }
        
        return URL(string: "https://www.youtube.com/watch?v=\(video.key)")
    }
}

