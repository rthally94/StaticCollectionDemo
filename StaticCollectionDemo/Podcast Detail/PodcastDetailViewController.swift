//
//  DemoStaticCollectionViewController.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 5/25/21.
//

import UIKit
import StaticCollection

class PodcastDetailViewController: UIViewController {
    // MARK: - Properties
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    var podcastStore = PodcastsStore.shared

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - View Life Cycle
    override func loadView() {
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = collectionView
    }
}

// MARK: - Data Source Model
extension PodcastDetailViewController {
    enum ViewModel {
        enum Section: Hashable {
            case episodes
            case hosts
            case ratings
        }

        enum Item: Hashable {
            case episode(id: String)
            case host(id: String)
            case rating(id: String)
        }
    }
}

// MARK: - Collection View Setup
extension PodcastDetailViewController
