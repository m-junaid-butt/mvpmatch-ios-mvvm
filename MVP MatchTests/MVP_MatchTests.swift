//
//  MVP_MatchTests.swift
//  MVP MatchTests
//
//  Created by Junaid Butt on 01/09/2022.
//

import XCTest
@testable import MVP_Match

class MVP_MatchTests: XCTestCase {
    
    private let movieService = MovieService()
    var homeviewModel = HomeViewModel()
    var persistManager = MoviePersistenceManager.shared
    
    func test_PersistantMovies() {
        let movies = persistManager.fetch()
        XCTAssertNotNil(movies)
    }

    func test_searchMoviesApi() {
        let expectation = XCTestExpectation.init(description: "Search Movies")
        
        movieService.fetchSearchMovies(with: "king") { movies, errorMessage in
            if errorMessage != nil {
                XCTFail("Got the error: \(errorMessage!)")
            } else {
                XCTAssertNotNil(movies)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_moviesWithIMDb() {
        let expectation = XCTestExpectation.init(description: "Get IMDB Movies")
        movieService.fetchMovies(with: "king") { movie, errorMessage in
            if errorMessage != nil {
                XCTFail("Got the error: \(errorMessage!)")
            } else {
                XCTAssertNotNil(movie)
                XCTAssertEqual(movie?.imdbID, nil)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}
