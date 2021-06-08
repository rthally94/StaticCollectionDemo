//
//  AllPodcastsViewController.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 6/8/21.
//

import UIKit

class AllPodcastsViewController: UIViewController {
    // MARK: - Properties
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    var allPodcasts: [Podcast] {
        store.allPodcasts
    }

    var store = PodcastsStore.shared

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: View Life Cycle
    override func loadView() {
        setupCollectionView()
        setupDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Your Podcasts"

        applyInitialSnapshot()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if collectionView.indexPathsForSelectedItems?.isEmpty == false {
            collectionView.indexPathsForSelectedItems?.forEach({ indexPath in
                collectionView.deselectItem(at: indexPath, animated: true)
            })
        }
    }

    // MARK: Actions
    private func showPodcastDetail(id: Podcast.ID) {
        let vc  = PodcastDetailViewController()
        vc.podcastID = id

        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Data Source Model
extension AllPodcastsViewController {
    enum ViewModel {
        enum Section: Hashable, CaseIterable {
            case all
        }

        enum Item: Hashable {
            case podcast(id: String)
        }
    }
}

// MARK: - Collection View Setup
extension AllPodcastsViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self

        view = collectionView
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]
            let section: NSCollectionLayoutSection
            switch sectionKind {
                case .all:
                    let config = UICollectionLayoutListConfiguration(appearance: .grouped)
                    section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            }

            return section
        }

        return layout
    }
}

// MARK: - Data Source Setup
extension AllPodcastsViewController {
    private func setupDataSource() {
        let podcastListCellRegistration = makeUICollectionListCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .podcast:
                return collectionView.dequeueConfiguredReusableCell(using: podcastListCellRegistration, for: indexPath, item: item)
            }
        })
    }

    private func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(Section.allCases)

        let items = allPodcasts.map {
            Item.podcast(id: $0.id)
        }
        snapshot.appendItems(items, toSection: .all)

        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Cell Registrations
extension AllPodcastsViewController {
    private func makeUICollectionListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {[unowned self] cell, indexPath, item in
            switch item {
            case.podcast(let id):
                guard let podcast = self.allPodcasts.first(where: { podcast in
                    podcast.id == id
                }) else {
                    break
                }

                var config = UIListContentConfiguration.subtitleCell()
                config.text = podcast.title
                let count = podcast.episodes.count
                config.secondaryText = "\(count) episode\(count == 1 ? "" : "s")"
                cell.contentConfiguration = config
                cell.accessories = [
                    .disclosureIndicator()
                ]
            }
        }
    }
}

// MARK: - Collection View Delegate
extension AllPodcastsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .podcast:
            return true
        default:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        switch item {
        case .podcast(let id):
            showPodcastDetail(id: id)
        default:
            break
        }
    }
}
