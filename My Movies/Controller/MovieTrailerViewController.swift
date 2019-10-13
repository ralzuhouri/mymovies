//
//  MovieTrailerViewController.swift
//  My Movies
//
//  Created by Ramy Al Zuhouri on 13/10/19.
//  Copyright © 2019 Ramy Al Zuhouri. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import AVKit

class MovieTrailerViewController: UIViewController {
    var movie: Movie?
    @IBOutlet weak var activityIndicator: NSLayoutConstraint!
    @IBOutlet weak var doneButton: UIButton!
    
    // When called for the first time, it's automatically configured
    // and added to the view hierarchy.
    lazy var webView: UIView = {
        let webView: UIView
        
        if #available(iOS 11.0, *) {
            webView = WKWebView()
        } else {
            webView = UIWebView()
        }
        
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            webView.topAnchor.constraint(equalTo: self.doneButton.bottomAnchor, constant: 15),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        return webView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        MovieProvider.shared.addDelegate(self)
    }
}

// MARK: - Actions
extension MovieTrailerViewController {
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - MovieProviderDelegate
extension MovieTrailerViewController: MovieProviderDelegate {
    func movieProvider(_ movieProvider: MovieProvider, finishedDownloadingBackdropImageForMovie movie: Movie) {
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
        DispatchQueue.main.async {
            guard let trailerUrl = movie.trailerUrl else {
                return
            }

            let request = URLRequest(url: trailerUrl)

            if #available(iOS 11.0, *) {
                guard let webView = self.webView as? WKWebView else {
                    assertionFailure("Could not find WKWebView for iOS 11+")
                    return
                }

                webView.load(request)
                webView.allowsBackForwardNavigationGestures = true
            } else {
                guard let webView = self.webView as? UIWebView else {
                    assertionFailure("Could not find WKWebView for iOS 10 or lower")
                    return
                }

                webView.loadRequest(request)
                webView.mediaPlaybackRequiresUserAction = false
            }
        }
    }
}
