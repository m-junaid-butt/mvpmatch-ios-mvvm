//
//  HomeViewController.swift
//  MVP Match
//
//  Created by Junaid Butt on 2/8/22.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let movieService = MovieService()
    private var movies: [Movie] = []
    private var favouriteMovies: [Movie] = []
    private var hiddenMovies: [Movie] = []
    let homeViewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.searchBar.delegate = self
        
        self.title = "Movies"
        homeViewModel.getFavouriteMovies()
        homeViewModel.getHiddenMovies()
        setupHomeViewModelObserver()
    }
    
    func setupHomeViewModelObserver() {
        homeViewModel.searchResults.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        homeViewModel.favouriteMovies.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        homeViewModel.hiddenMovies.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        homeViewModel.isSearching.bind { [weak self] (isSearching) in
            guard let isSearching = isSearching else { return }
            DispatchQueue.main.async {
                isSearching ? self?.showActivityView() : self?.hideActivityView()
            }
        }
        
        homeViewModel.errorMessage.bind { errorMessage in
            self.showAlert(title: "Error", message: errorMessage!)
        }
    }
}

//MARK: -  Collectionview Delegate & Datasource
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.text == "" {
            return homeViewModel.favouriteMovies.value?.count ?? 0
        }
        return homeViewModel.searchResults.value?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
        
        var movie: Movie?
        
        if searchBar.text == "" {
            movie = homeViewModel.favouriteMovies.value?[indexPath.row]
            cell.hiddenBtn.isHidden = true
        } else {
            movie = homeViewModel.searchResults.value?[indexPath.row]
            cell.hiddenBtn.isHidden = false
            
        }
        
        cell.configure(movie: movie)
        cell.delegate = self
        cell.indexPath = indexPath
        
        let imageName = (movie?.isFavourite ?? false) ? "star" : "star-empty"
        cell.addFavouriteBtn.setImage(UIImage(named: imageName), for: .normal)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MovieDetailViewController.instantiate()
        
        if searchBar.text == "" {
            vc.imdbID = homeViewModel.favouriteMovies.value?[indexPath.row].imdbID ?? ""
        } else {
            vc.imdbID = homeViewModel.searchResults.value?[indexPath.row].imdbID ?? ""
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Collectionview Flow Layout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let yourWidth = collectionView.bounds.width/2.0
        let yourHeight = yourWidth + 100
        
        return CGSize(width: yourWidth, height: yourHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - Home Collectionview Protocol
extension HomeViewController: HomeCollectionViewProtocol {
    
    //MARK: - Favourite Movies Delegate
    func favouriteMovies(indexPath: IndexPath) {
        self.homeViewModel.favouriteMovieTapped(indexPath: indexPath,
                                                searchBarText: searchBar.text!)
        
    }
    
    //MARK: - Hidden movies delegate
    func hideMovies(indexPath: IndexPath) {
        self.homeViewModel.hideMoviesTapped(indexPath: indexPath, searchBarText: searchBar.text!)
    }
}

//MARK: - UISearchBarDelegate
extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else {return}
        if Connectivity.isConnectedToInternet {
            self.homeViewModel.getSearchedMovies(with: searchBarText)
        } else {
            self.showAlert(title: "Network Error", message: "The internet Connection appears to be offline")
        }
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.homeViewModel.searchResults.value?.removeAll()
            self.homeViewModel.favouriteMovies.value?.removeAll()
            self.homeViewModel.getFavouriteMovies()
        }
    }
}
