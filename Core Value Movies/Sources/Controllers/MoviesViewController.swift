//
//  MoviesViewController.swift
//  Core Value Movies
//
//  Created by Leandro Perez on 2/10/17.
//  Copyright © 2017 Leandro Perez. All rights reserved.
//

import UIKit
import Dip_UI

class MoviesViewController : InjectedViewController, StoryboardInstantiatable, UITableViewDataSource {

    var database : Database! //Injected
    var movies : [Movie]!
    var directors : [Director]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.database != nil) //Injected by the container, See AppDependencies
        
        self.movies = self.database.all()
        self.directors = self.database.all()
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {

        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return self.movies.count
        }
        return self.directors.count
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellID.MovieCell.cell(for:tableView, at: indexPath)
        if indexPath.section == 0 {
            self.configure(cell: cell, movie: self.movies[indexPath.row])
        }
        else{
            self.configure(cell: cell, director: self.directors[indexPath.row])
        }
        
        return cell
    }
    
    private func configure(cell:UITableViewCell, movie: Movie){
        cell.textLabel?.text = movie.name
        cell.detailTextLabel?.text = movie.objectID?.uriRepresentation().absoluteString
    }
    
    private func configure(cell:UITableViewCell, director: Director){
        cell.textLabel?.text = director.name
        cell.detailTextLabel?.text = director.objectID?.uriRepresentation().absoluteString
    }
    
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Movies"  : "Directors"
    }

}


enum CellID : String{
    case MovieCell
    
    func cell(for tableView: UITableView, at indexPath: IndexPath) ->UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: self.rawValue, for: indexPath)
        return cell
    }
}



