//
//  DetailSessionCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 11/03/26.
//

import UIKit
import AVFoundation

class DetailSessionCollectionViewController: UICollectionViewController {
    
    var session: SessionNote?

    var images: [UIImage] = []
    var audioURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = generateLayout()

        Task {
            await loadMedia()
        }
    }

//    func loadMedia() async {
//        guard let session = session else { return }
//
//        await withTaskGroup(of: Void.self) { group in
//
//            // Images
//            if let imagePaths = session.images {
//                for path in imagePaths {
//                    group.addTask {
//                        do {
//                            let img = try await SupabaseManager.shared.downloadSessionImage(from: path)
//                            await MainActor.run {
//                                self.images.append(img)
//                                self.collectionView.reloadSections(IndexSet(integer: 1))
//                            }
//                        } catch {
//                            print("❌ Image load error:", error)
//                        }
//                    }
//                }
//            }
//
//            // Audio
//            if let audioPaths = session.voice {
//                for path in audioPaths {
//                    group.addTask {
//                        do {
//                            let url = try await SupabaseManager.shared.downloadAudioToLocal(from: path)
//                            await MainActor.run {
//                                self.audioURLs.append(url)
//                                self.collectionView.reloadSections(IndexSet(integer: 0))
//                            }
//                        } catch {
//                            print("❌ Audio load error:", error)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func loadMedia() async {
        guard let session = session else { return }

        do {
            // Images
            if let imagePaths = session.images {
                for path in imagePaths {
                    let img = try await SupabaseManager.shared.downloadSessionImage(from: path)
                    images.append(img)
                }
            }

            // Audio
            if let audioPaths = session.voice {
                for path in audioPaths {
                    let localURL = try await SupabaseManager.shared.downloadAudioToLocal(from: path)
                    audioURLs.append(localURL)
                }
            }

            await MainActor.run {
                self.collectionView.reloadData()
            }

        } catch {
            print("❌ Media load error:", error)
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView,
                                numberOfItemsInSection section: Int) -> Int {

        switch section {
        case 1:
            return audioURLs.isEmpty ? 0 : audioURLs.count
        case 2:
            return images.isEmpty ? 0 : images.count
        case 0:
            return session?.notes == nil ? 0 : 1
        default:
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "recording",
                for: indexPath
            ) as! deatilCollectionViewCell

            let url = audioURLs[indexPath.item]
            cell.configure(with: url)

            return cell
        }
        if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "images",
                for: indexPath
            ) as! ImageCollectionViewCell

            cell.configure(with: images[indexPath.item])
            return cell
        }
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "textNote",
                for: indexPath
            ) as! textCollectionViewCell

            cell.textNote.text = session?.notes
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recording", for: indexPath)
    
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let vc = FullScreenImagePagerViewController(images: self.images, startIndex: indexPath.item)
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
        }
    }
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout {
 sectionIndex,
 environment in
            if sectionIndex == 1 {

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(150)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(150)
                )

                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 16, trailing: 10)
                section.interGroupSpacing = 4
                section.orthogonalScrollingBehavior = .groupPagingCentered

                return section
            }
            if sectionIndex == 2 {
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(150)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(150)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitem: item,
                    count: 2
                )

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 16, trailing: 10)
                section.interGroupSpacing = 4
                section.orthogonalScrollingBehavior = .groupPagingCentered

                return section
            }
            if sectionIndex == 0{
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension:
                        .estimated(0))
         
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
           
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension:
                        .estimated(0))
    
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//                group.interItemSpacing = .flexible(10)
                
            
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 16, trailing: 10)
                section.interGroupSpacing = 4
                
                return section
            }
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(150))
            
       
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
         
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(150))
        
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .flexible(10)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 16, trailing: 10)
            section.interGroupSpacing = 4
            
            return section
        }
    }
}

class FullScreenImagePagerViewController: UIViewController, UIScrollViewDelegate {
    let images: [UIImage]
    var startingIndex: Int
    let scrollView = UIScrollView()
    
    private var isSetup = false
    
    init(images: [UIImage], startIndex: Int) {
        self.images = images
        self.startingIndex = startIndex
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24)), for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let pageWidth = scrollView.bounds.width
        let pageHeight = scrollView.bounds.height
        
        // Don't setup if bounds are 0
        guard pageWidth > 0 && pageHeight > 0 else { return }
        
        if !isSetup {
            isSetup = true
            scrollView.contentSize = CGSize(width: pageWidth * CGFloat(images.count), height: pageHeight)
            
            for (i, image) in images.enumerated() {
                let inner = UIScrollView(frame: CGRect(x: pageWidth * CGFloat(i), y: 0, width: pageWidth, height: pageHeight))
                inner.minimumZoomScale = 1.0
                inner.maximumZoomScale = 5.0
                inner.delegate = self
                inner.showsHorizontalScrollIndicator = false
                inner.showsVerticalScrollIndicator = false
                inner.tag = i
                inner.contentInsetAdjustmentBehavior = .never
                
                let iv = UIImageView(image: image)
                iv.contentMode = .scaleAspectFit
                iv.frame = inner.bounds
                iv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                iv.tag = 100 + i
                inner.addSubview(iv)
                
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
                doubleTap.numberOfTapsRequired = 2
                inner.addGestureRecognizer(doubleTap)
                
                scrollView.addSubview(inner)
            }
            
            scrollView.contentOffset = CGPoint(x: pageWidth * CGFloat(startingIndex), y: 0)
        } else {
            // Handle rotation or final bounds assignment
            scrollView.contentSize = CGSize(width: pageWidth * CGFloat(images.count), height: pageHeight)
            for inner in scrollView.subviews {
                if let innerScroll = inner as? UIScrollView {
                    let pageIndex = innerScroll.tag
                    innerScroll.frame = CGRect(x: pageWidth * CGFloat(pageIndex), y: 0, width: pageWidth, height: pageHeight)
                    if let iv = innerScroll.viewWithTag(100 + pageIndex) as? UIImageView {
                        iv.frame = innerScroll.bounds
                    }
                }
            }
        }
    }
    
    @objc func closeTapped() { dismiss(animated: true) }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let inner = gesture.view as? UIScrollView, let iv = inner.viewWithTag(100 + inner.tag) else { return }
        if inner.zoomScale > 1.0 {
            inner.setZoomScale(1.0, animated: true)
        } else {
            let point = gesture.location(in: iv)
            let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
            inner.zoom(to: rect, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard scrollView != self.scrollView else { return nil }
        return scrollView.viewWithTag(100 + scrollView.tag)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView != self.scrollView, let iv = scrollView.viewWithTag(100 + scrollView.tag) else { return }
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        iv.center = CGPoint(
            x: scrollView.contentSize.width / 2 + offsetX,
            y: scrollView.contentSize.height / 2 + offsetY
        )
    }
}
