//
//  DemoStaticCollectionViewController.swift
//  StaticCollectionDemo
//
//  Created by Ryan Thally on 5/25/21.
//

import UIKit

class PodcastDetailViewController: UIViewController {
    // MARK: - Properties
    typealias Section = ViewModel.Section
    typealias Item = ViewModel.Item

    var podcastStore = PodcastsStore.shared
    var podcastID: Podcast.ID?

    var podcast: Podcast? {
        podcastStore.allPodcasts.first { podcast in
            podcast.id == podcastID
        }
    }

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - View Life Cycle
    override func loadView() {
        setupCollectionView()
        setupDataSource()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = podcast?.title
        applyInitialSnapshot()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if collectionView.indexPathsForSelectedItems?.isEmpty == false {
            collectionView.indexPathsForSelectedItems?.forEach({ indexPath in
                collectionView.deselectItem(at: indexPath, animated: true)
            })
        }
    }
}

// MARK: - Data Source Model
extension PodcastDetailViewController {
    enum ViewModel {
        enum Section: Hashable, CaseIterable {
            case episodes
            case hosts
            case ratings

            var headerText: String? {
                switch self {
                case .episodes:
                return "Episodes"
                case .hosts:
                return "Hosts"
                case .ratings:
                    return "Ratings"
                }
            }
        }

        enum Item: Hashable {
            case episode(id: String)
            case host(id: String)
            case rating(id: String)
        }
    }
}

// MARK: - Collection View Setup
extension PodcastDetailViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        view = collectionView
    }

    private func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let sectionKind = Section.allCases[sectionIndex]

            let section: NSCollectionLayoutSection
            switch sectionKind {
            case .episodes:
                var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                config.headerMode = sectionKind.headerText != nil ? .supplementary : .none
                section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            case .hosts:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalWidth(0.3))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

                section = NSCollectionLayoutSection(group: group)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [
                    header
                ]

                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 10

            case .ratings:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(150))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

                section = NSCollectionLayoutSection(group: group)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [
                    header
                ]

                section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 0)
                section.orthogonalScrollingBehavior = .groupPaging
                section.interGroupSpacing = 10

            default:
                fatalError("Unimplemented section identifier: \(sectionKind)")
            }
            return section
        }

        return layout
    }
}

// MARK: - Data Source Setup
extension PodcastDetailViewController {
    func setupDataSource() {
        let episodeCellRegistration = makeUICollectionListCellRegistration()
        let hostCellRegistration = makeUICollectionListCellRegistration()
        let ratingCellRegistration = makeUICollectionListCellRegistration()

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            switch item {
            case .episode:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: item)
            case .host:
                return collectionView.dequeueConfiguredReusableCell(using: hostCellRegistration, for: indexPath, item: item)
            case .rating:
                return collectionView.dequeueConfiguredReusableCell(using: ratingCellRegistration, for: indexPath, item: item)
            default:
                fatalError("Received an item with an unconfigured cell registration: \(item)")
            }
        })

        let prominentHeaderRegistration = makeProminentSectionHeaderRegistration()
        dataSource.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            switch elementKind {
            case UICollectionView.elementKindSectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: prominentHeaderRegistration, for: indexPath)
            default:
                return nil
            }
        }
    }

    func applyInitialSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let visibleSections = Section.allCases.filter { section in
            switch section {
            case .episodes:
                return podcast?.episodes.isEmpty == false
            case .hosts:
                return podcast?.hosts.isEmpty == false
            case .ratings:
                return podcast?.ratings.isEmpty == false
            }
        }

        snapshot.appendSections(visibleSections)

        if let episodeItems = podcast?.episodes.map({ episode in
            Item.episode(id: episode.id)
        }), !episodeItems.isEmpty {
            snapshot.appendItems(episodeItems, toSection: .episodes)
        }

        if let hostItems = podcast?.hosts.map({ host in
            Item.host(id: host)
        }), !hostItems.isEmpty {
            snapshot.appendItems(hostItems, toSection: .hosts)
        }

        if let ratingItems = podcast?.ratings.map({ rating in
            Item.rating(id: rating.id.uuidString)
        }), !ratingItems.isEmpty {
            snapshot.appendItems(ratingItems, toSection: .ratings)
        }

        UIView.performWithoutAnimation {
            self.dataSource.apply(snapshot)
        }
    }
}

// MARK: - Cell Registrations
extension PodcastDetailViewController {
    private func makeUICollectionListCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, Item> {
        UICollectionView.CellRegistration<UICollectionViewListCell, Item> {[unowned self] cell, indexPath, item in
            switch item {
            case .episode(let id):
                guard let episode = self.podcast?.episodes.first(where: { episode in
                    episode.id == id
                }) else {
                    break
                }

                var config = UIListContentConfiguration.valueCell()
                config.text = "\(episode.episodeNumber). \(episode.title)"
                config.secondaryText = episode.description

                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config
            case .host(let id):
                var config = UIListContentConfiguration.valueCell()
                config.text = id
                cell.contentConfiguration = config
                cell.layer.cornerRadius = 10
                cell.clipsToBounds = true

            case .rating(let id):
                guard let rating = self.podcast?.ratings.first(where: { rating in
                    rating.id.uuidString == id
                }) else {
                    break
                }

                var config = UIListContentConfiguration.valueCell()
                config.text = rating.title
                config.secondaryText = rating.description
                config.prefersSideBySideTextAndSecondaryText = false
                cell.contentConfiguration = config
                cell.layer.cornerRadius = 10
                cell.clipsToBounds = true

            default:
                fatalError("Received an item identifier with an unhandled configuration: \(item)")
            }
        }
    }

    func makeProminentSectionHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { cell, elementKind, indexPath in
            let sectionKind = Section.allCases[indexPath.section]

            var config = UIListContentConfiguration.plainHeader()
            config.text = sectionKind.headerText
            cell.contentConfiguration = config
        }
    }
}

// MARK: - UI Collection View Delegate
extension PodcastDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
}
