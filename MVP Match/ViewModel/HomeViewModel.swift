//
//  HomeViewModel.swift
//  MVP Match
//
//  Created by Junaid Butt on 3/14/22.
//

import Foundation

class HomeViewModel {
    var searchResults = Bindable<[Movie]>()
    var favouriteMovies = Bindable<[Movie]>()
    var hiddenMovies = Bindable<[Movie]>()
    var errorMessage = Bindable<String>()
    var isSearching = Bindable<Bool>()
    
    private let movieService = MovieService()
    
    //MARK: - Search Movie Api call
    func getSearchedMovies(with title: String) {
        isSearching.value = true
        movieService.fetchSearchMovies(with: title) { [weak self] movies, errorMessage in
            guard let self = self else {return}
            self.isSearching.value = false
            if let errorMessage = errorMessage {
                self.errorMessage.value = errorMessage
            } else {
                guard let movies = movies, var searchMovies = movies.search else {
                    self.errorMessage.value = errorMessage
                    return
                }
                
                // Favourite Movies show
                for movie in searchMovies {
                    for favouriteMovie in self.favouriteMovies.value ?? [] {
                        if movie.imdbID == favouriteMovie.imdbID {
                            movie.isFavourite = true
                            continue
                        }
                    }
                }
                
                // Hidden Movies show
                for movie in searchMovies {
                    for hiddenMovie in self.hiddenMovies.value ?? [] {
                        if movie.imdbID == hiddenMovie.imdbID {
                            if let index = searchMovies.firstIndex(where: {$0.imdbID == hiddenMovie.imdbID}) {
                                movie.isHidden = true
                                searchMovies.remove(at: index)
                                continue
                            }
                        }
                    }
                }
                
                self.searchResults.value = searchMovies
            }
        }
    }
    
    
    //MARK: - Get Favourite movies
    func getFavouriteMovies() {
        let favMovies = MoviePersistenceManager.shared.fetch().filter({$0.isFavourite == true})
        self.favouriteMovies.value = favMovies
        self.searchResults.value = favMovies
    }
    
    //MARK: - Get Hidden movies
    func getHiddenMovies() {
        let hiddenMovies = MoviePersistenceManager.shared.fetch().filter({$0.isHidden == true})
        self.hiddenMovies.value = hiddenMovies
    }
    
    //MARK: - Favourite movie button Tapped
    func favouriteMovieTapped(indexPath: IndexPath, searchBarText: String) {
        let movie = self.searchResults.value?[indexPath.row]
        if movie!.isFavourite == true {
            for favMovie in self.favouriteMovies.value ?? [] {
                if favMovie.imdbID == movie!.imdbID {
                    //find index and them remove from user default
                    if let index = self.favouriteMovies.value!.firstIndex(where: {$0.imdbID == movie!.imdbID}) {
                        
                        if searchBarText == "" {
                            MoviePersistenceManager.shared.deleteMovie(id: self.favouriteMovies.value![indexPath.row].imdbID ?? "")
                            self.favouriteMovies.value!.remove(at: indexPath.row)
                            self.searchResults.value?.remove(at: indexPath.row)
                            
                        } else {
                            movie!.isFavourite = false
                            MoviePersistenceManager.shared.deleteMovie(id: self.favouriteMovies.value![index].imdbID ?? "")
                            self.favouriteMovies.value!.remove(at: index)
                        }
                        
                        break
                    }
                }
            }
            
        } else {
            movie!.isFavourite = true
            self.favouriteMovies.value!.append(movie ?? Movie())
            MoviePersistenceManager.shared.save(movies: self.favouriteMovies.value ?? [])
        }
    }
    
    //MARK: - Hide movies button tapped
    func hideMoviesTapped(indexPath: IndexPath, searchBarText: String) {
        let movie = self.searchResults.value?[indexPath.row]
        if searchBarText.isEmpty == false {
            if movie?.isHidden == false {
                self.searchResults.value?.remove(at: indexPath.row)
                movie?.isHidden = true
                self.hiddenMovies.value?.append(movie ?? Movie())
                
                MoviePersistenceManager.shared.save(movies: self.hiddenMovies.value ?? [])
            }
        }
    }
}
