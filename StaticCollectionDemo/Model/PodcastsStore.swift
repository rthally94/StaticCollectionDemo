//
//  PodcastsStore.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 6/8/21.
//

import Foundation

class PodcastsStore: ObservableObject {
    static var shared = PodcastsStore()

    @Published var allPodcasts: [Podcast] = [
        Podcast(
            title: "Unrated Podcast",
            category: "Technology",
            episodes: [
                Episode(number: 1, title: "The First One", description: "Description."),
            ],
            hosts: ["Host 1"],
            ratings: []
        ),
        Podcast(
            title: "A Rated Podcast",
            category: "Technology",
            episodes: [
                Episode(number: 1, title: "The First One", description: "Description."),
                Episode(number: 2, title: "The One That Comes Next", description: "A longer Description.")
            ],
            hosts: ["Host 2"],
            ratings: ["Love this one!"]
        ),
        Podcast(
            title: "A Proper One",
            category: "Technology",
            episodes: [
                Episode(number: 1, title: "The First One", description: "Description."),
                Episode(number: 2, title: "The One That Comes Next", description: "A longer Description."),
                Episode(number: 3, title: "The Forgotten One", description: "A really, really, really long description.")
            ],
            hosts: ["Host 1", "Host 2"],
            ratings: ["Love this one!", "Can't get enough!"]
        ),
    ]
}
