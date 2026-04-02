//
//  JournalImageViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 02/04/26.
//


import UIKit

class JournalImageViewController: UIViewController, UIScrollViewDelegate {
    
//    // MARK: - Properties
//    var journalEntry: JournalEntry?
//    var image: UIImage?
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    // MARK: - UI
//    private let scrollView: UIScrollView = {
//        let sv = UIScrollView()
//        sv.minimumZoomScale = 1.0
//        sv.maximumZoomScale = 5.0
//        sv.showsHorizontalScrollIndicator = false
//        sv.showsVerticalScrollIndicator = false
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        sv.backgroundColor = .black
//        return sv
//    }()
    
    @IBOutlet weak var imageView: UIImageView!
//    private let imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFill  // changed — frame handles fit now
//        return iv
//    }()
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
//    private let loadingIndicator: UIActivityIndicatorView = {
//        let ai = UIActivityIndicatorView(style: .large)
//        ai.color = .white
//        ai.translatesAutoresizingMaskIntoConstraints = false
//        ai.hidesWhenStopped = true
//        return ai
//    }()
    
    @IBOutlet weak var summaryButton: UIButton!
//    private let summaryButton: UIButton = {
//        var config = UIButton.Configuration.filled()
//        config.title = "✦ Summary"
//        config.baseForegroundColor = .white
//        config.baseBackgroundColor = UIColor.systemOrange
//        config.cornerStyle = .capsule
//        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28)
//        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
//            var outgoing = incoming
//            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//            return outgoing
//        }
//        let btn = UIButton(configuration: config)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        // Shadow
//        btn.layer.shadowColor = UIColor.black.cgColor
//        btn.layer.shadowOpacity = 0.3
//        btn.layer.shadowRadius = 8
//        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
//        return btn
//    }()
    
    // MARK: - Lifecycle
    var journalEntry: JournalEntry?
        var loadedImage: UIImage?
        
        // MARK: - Lifecycle
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupScrollView()
            setupNavigationBar()
            setupSummaryButton()
            loadImage()
            
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            scrollView.addGestureRecognizer(doubleTap)
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            fitImageInScrollView()
        }
        
        // MARK: - Setup
        
        private func setupScrollView() {
            scrollView.delegate = self
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 5.0
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.backgroundColor = .black
        }
        
        private func setupNavigationBar() {
            title = journalEntry?.title ?? "Journal"
            navigationController?.navigationBar.tintColor = .white
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
        private func setupSummaryButton() {
            summaryButton.isHidden = true
            // Title set in storyboard, just ensure color
            summaryButton.tintColor = .white
            summaryButton.setTitleColor(.white, for: .normal)
        }
        
        // MARK: - Image Fitting
        
        private func fitImageInScrollView() {
            guard let image = imageView.image else { return }
            
            let insets = view.safeAreaInsets
            let availableSize = CGSize(
                width: scrollView.bounds.width,
                height: scrollView.bounds.height - insets.top - insets.bottom
            )
            
            let widthScale  = availableSize.width  / image.size.width
            let heightScale = availableSize.height / image.size.height
            let scale = min(widthScale, heightScale)
            
            let fittedWidth  = image.size.width  * scale
            let fittedHeight = image.size.height * scale
            
            imageView.frame = CGRect(
                x: (scrollView.bounds.width - fittedWidth) / 2,
                y: insets.top + (availableSize.height - fittedHeight) / 2,
                width: fittedWidth,
                height: fittedHeight
            )
            
            scrollView.contentSize = scrollView.bounds.size
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 5.0
        }
        
        // MARK: - Image Loading
        
        private func loadImage() {
            guard let path = journalEntry?.uploadPath else {
                showPlaceholder(); return
            }
            
            loadingIndicator.startAnimating()
            summaryButton.isHidden = true
            
            Task {
                do {
                    let data  = try await AccessSupabase.shared.downloadFile(path: path)
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.imageView.image = image
                        self.loadedImage = image
                        self.fitImageInScrollView()
                        self.summaryButton.isHidden = false
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.loadingIndicator.stopAnimating()
                        self.showPlaceholder()
                    }
                }
            }
        }
        
        private func showPlaceholder() {
            imageView.image = UIImage(systemName: "photo.fill")
            imageView.tintColor = .systemGray
            imageView.contentMode = .scaleAspectFit
            summaryButton.isHidden = false
        }
        
        // MARK: - Actions
        
        @IBAction func summaryTapped(_ sender: UIButton) {
            guard let image = imageView.image else { return }
            
            let sb = UIStoryboard(name: "JournalImageView", bundle: nil)
            print("🔴 Trying to load ImageSummarySheetViewController")
            let summaryVC = sb.instantiateViewController(withIdentifier: "ImageSummarySheetViewController")
                            as! ImageSummarySheetViewController
            
            summaryVC.image = image
            summaryVC.entryTitle = journalEntry?.title ?? "Journal Entry"
            
            if let sheet = summaryVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 24
            }
            
            present(summaryVC, animated: true)
        }
        
        @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            if scrollView.zoomScale > 1.0 {
                scrollView.setZoomScale(1.0, animated: true)
            } else {
                let point = gesture.location(in: imageView)
                let rect  = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
                scrollView.zoom(to: rect, animated: true)
            }
        }
        
        // MARK: - UIScrollViewDelegate
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            let offsetX = max((scrollView.bounds.width  - scrollView.contentSize.width)  / 2, 0)
            let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
            imageView.center = CGPoint(
                x: scrollView.contentSize.width  / 2 + offsetX,
                y: scrollView.contentSize.height / 2 + offsetY
            )
        }
    }

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupNavigationBar()
//        loadImage()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupUI() {
//        view.backgroundColor = .black
//        
//        scrollView.frame = view.bounds
//        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        scrollView.delegate = self
//        view.addSubview(scrollView)
//        
//        imageView.frame = scrollView.bounds
//        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        imageView.contentMode = .scaleAspectFit
//        scrollView.addSubview(imageView)
//        
//        // Loading
//        view.addSubview(loadingIndicator)
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
//        
//        // Summary button
//        view.addSubview(summaryButton)
//        summaryButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            summaryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            summaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
//        ])
//        summaryButton.addTarget(self, action: #selector(summaryTapped), for: .touchUpInside)
//        
//        // Double-tap to zoom
//        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//        doubleTap.numberOfTapsRequired = 2
//        scrollView.addGestureRecognizer(doubleTap)
//    }
//    
//    private func setupNavigationBar() {
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.barStyle = .black
//        
//        // Transparent nav bar over black image
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithTransparentBackground()
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//        
//        title = journalEntry?.title ?? "Journal"
//    }
//    
//    // MARK: - Image Loading
//    
//    private func loadImage() {
//        // If image already passed directly, use it
//        if let image = image {
//            imageView.image = image
//            return
//        }
//        
//        // Otherwise load from Supabase uploadPath
//        guard let path = journalEntry?.uploadPath else {
//            showPlaceholder()
//            return
//        }
//        
//        loadingIndicator.startAnimating()
//        summaryButton.isHidden = true
//        
//        Task {
//            do {
//                let imageData = try await AccessSupabase.shared.downloadFile(path: path)
//                let loadedImage = UIImage(data: imageData)
//                
//                DispatchQueue.main.async {
//                    self.loadingIndicator.stopAnimating()
//                    self.imageView.image = loadedImage
//                    self.image = loadedImage
//                    self.fitImageInScrollView()  // ← ADD THIS
//                    self.summaryButton.isHidden = false
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.loadingIndicator.stopAnimating()
//                    self.showPlaceholder()
//                    print("Failed to load image: \(error)")
//                }
//            }
//        }
//    }
//    
//    private func showPlaceholder() {
//        imageView.image = UIImage(systemName: "photo.fill")
//        imageView.tintColor = .systemGray
//        summaryButton.isHidden = false
//    }
//    
//    // MARK: - Actions
//    
//    @IBAction func summaryTapped(_ sender: UIButton) {
//        guard let image = imageView.image else { return }
//        
//        let summaryVC = ImageSummarySheetViewController()
//        summaryVC.image = image
//        summaryVC.entryTitle = journalEntry?.title ?? "Journal Entry"
//        
//        // Half-screen sheet
//        if let sheet = summaryVC.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//            sheet.prefersGrabberVisible = true
//            sheet.preferredCornerRadius = 24
//        }
//        
//        present(summaryVC, animated: true)
//    }
////    @objc private func summaryTapped() {
////        guard let image = imageView.image else { return }
////        
////        let summaryVC = ImageSummarySheetViewController()
////        summaryVC.image = image
////        summaryVC.entryTitle = journalEntry?.title ?? "Journal Entry"
////        
////        // Half-screen sheet
////        if let sheet = summaryVC.sheetPresentationController {
////            sheet.detents = [.medium(), .large()]
////            sheet.prefersGrabberVisible = true
////            sheet.preferredCornerRadius = 24
////        }
////        
////        present(summaryVC, animated: true)
////    }
//    
//    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
//        if scrollView.zoomScale > 1.0 {
//            scrollView.setZoomScale(1.0, animated: true)
//        } else {
//            let point = gesture.location(in: imageView)
//            let rect = CGRect(x: point.x - 50, y: point.y - 50, width: 100, height: 100)
//            scrollView.zoom(to: rect, animated: true)
//        }
//    }
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
//        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
//        imageView.center = CGPoint(
//            x: scrollView.contentSize.width / 2 + offsetX,
//            y: scrollView.contentSize.height / 2 + offsetY
//        )
//    }
//    // MARK: - UIScrollViewDelegate
//    
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return imageView
//    }
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.frame = view.bounds
//        fitImageInScrollView()
//    }
//    private func fitImageInScrollView() {
//        guard let image = imageView.image else { return }
//        
//        let scrollSize = scrollView.bounds.size
//        let imageSize = image.size
//        
//        // Calculate scale to fit image within screen
//        let widthScale = scrollSize.width / imageSize.width
//        let heightScale = scrollSize.height / imageSize.height
//        let scale = min(widthScale, heightScale)
//        
//        // Size the imageView to the scaled image size
//        let fittedWidth = imageSize.width * scale
//        let fittedHeight = imageSize.height * scale
//        
//        imageView.frame = CGRect(
//            x: (scrollSize.width - fittedWidth) / 2,   // center horizontally
//            y: (scrollSize.height - fittedHeight) / 2,  // center vertically
//            width: fittedWidth,
//            height: fittedHeight
//        )
//        
//        scrollView.contentSize = scrollSize
//        scrollView.minimumZoomScale = 1.0
//        scrollView.maximumZoomScale = 5.0
//        scrollView.zoomScale = 1.0
//    }
//}
