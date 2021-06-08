//
//  Podcast.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 6/8/21.
//

import Foundation

class Podcast: ObservableObject, Identifiable {
    var id: String = UUID().uuidString

    var title: String
    var category: String

    var episodes: [Episode]

    var hosts: [String]

    var ratings: [Rating]

    init(title: String, category: String, episodes: [Episode], hosts: [String], ratings: [Rating]) {
        self.title = title
        self.category = category

        self.episodes = episodes
        self.hosts = hosts
        self.ratings = ratings
    }
}
