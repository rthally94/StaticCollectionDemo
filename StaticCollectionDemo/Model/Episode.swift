//
//  Episode.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 6/8/21.
//

import Foundation

class Episode: ObservableObject, Identifiable {
    var id: String = UUID().uuidString

    var episodeNumber: Int
    var title: String
    var description: String

    init(number: Int, title: String, description: String) {
        episodeNumber = number
        self.title = title
        self.description = description
    }
}
