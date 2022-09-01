//
//  MovieDetailViewModel.swift
//  MVP Match
//
//  Created by Junaid Butt on 3/16/22.
//

import Foundation

class MoviewDetailViewModel {
    var movieDetail = Bindable<Movie>()
    var isSearching = Bindable<Bool>()
    var errorMessage = Bindable<String>()


    private let movieService = MovieService()
    
    func getMovieDetail (imdbID: String) {
        self.isSearching.value = true
        movieService.fetchMovies(with: imdbID) {[weak self] movie, errorMessage in
            guard let self = self else {return}
            self.isSearching.value = false
            if let errorMessage = errorMessage {
                self.errorMessage.value = errorMessage
            } else {
                guard let movie = movie else {return}
                self.movieDetail.value = movie
            }
        }
    }
}
