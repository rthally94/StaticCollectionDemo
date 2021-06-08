//
//  Rating.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 6/8/21.
//

import Foundation

class Rating: ObservableObject, Identifiable {
    var id: UUID = UUID()

    var title: String
    var description: String
    var rating: Float

    init(title: String, description: String, rating: Float) {
        self.title = title
        self.description = description
        self.rating = rating
    }
}

extension Rating {
    static let demoRatings: [Rating] = [
        Rating(title: "Awful!", description: "Watching paint dry is a better use of time. Would give 0 stars if I could. 10/10 would not recommend.", rating: 1),
        Rating(title: "Meh...", description: "Nice way to keep busy while sitting in traffic. Descent background noice over the sound of car horns. Does the job.", rating: 3),
        Rating(title: "Love It!", description: "Its a realy great show! 10/10 would recommend!", rating: 5),
    ]
}
