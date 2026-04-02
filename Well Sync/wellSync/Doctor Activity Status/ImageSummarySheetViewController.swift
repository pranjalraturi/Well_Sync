//
//  ImageSummarySheetViewController.swift
//  wellSync
//
//  Created by Rishika Mittal on 02/04/26.
//


import UIKit

class ImageSummarySheetViewController: UIViewController {
    
    // MARK: - Outlets (connect in storyboard)
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var summaryTextView: UITextView!
    
    // MARK: - Properties
    var image: UIImage?
    var entryTitle: String = "Journal Entry"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subtitleLabel.text = entryTitle
        summaryTextView.isHidden = true
        spinner.startAnimating()
        fetchSummary()
    }
    
    // MARK: - API
    
    private func fetchSummary() {
        guard let image,
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            showError(); return
        }
        
        let base64 = imageData.base64EncodedString()
        
        Task {
            do {
                let text = "Summarized text will appear here."
                DispatchQueue.main.async { self.showSummary(text) }
            } catch {
                DispatchQueue.main.async { self.showError() }
            }
        }
    }

    
    // MARK: - State
    
    private func showSummary(_ text: String) {
        spinner.stopAnimating()
        loadingLabel.isHidden = true
        summaryTextView.isHidden = false
        summaryTextView.text = text
    }
    
    private func showError() {
        spinner.stopAnimating()
        loadingLabel.text = "Could not generate summary. Please try again."
        loadingLabel.textColor = .systemRed
    }
}

//class ImageSummarySheetViewController: UIViewController {
//    
//    // MARK: - Properties
//    var image: UIImage?
//    var entryTitle: String = "Journal Entry"
//    
//    // MARK: - UI
//    
//    private let grabberView: UIView = {
//        let v = UIView()
//        v.backgroundColor = UIColor.systemGray4
//        v.layer.cornerRadius = 2.5
//        v.translatesAutoresizingMaskIntoConstraints = false
//        return v
//    }()
//    
//    private let titleLabel: UILabel = {
//        let l = UILabel()
//        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        l.textColor = .label
//        l.text = "AI Summary"
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//    
//    private let subtitleLabel: UILabel = {
//        let l = UILabel()
//        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
//        l.textColor = .secondaryLabel
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//    
//    private let loadingStack: UIStackView = {
//        let sv = UIStackView()
//        sv.axis = .vertical
//        sv.alignment = .center
//        sv.spacing = 12
//        sv.translatesAutoresizingMaskIntoConstraints = false
//        return sv
//    }()
//    
//    private let spinner: UIActivityIndicatorView = {
//        let ai = UIActivityIndicatorView(style: .medium)
//        ai.translatesAutoresizingMaskIntoConstraints = false
//        return ai
//    }()
//    
//    private let loadingLabel: UILabel = {
//        let l = UILabel()
//        l.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        l.textColor = .secondaryLabel
//        l.text = "Analyzing your journal entry..."
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//    
//    private let summaryTextView: UITextView = {
//        let tv = UITextView()
//        tv.font = UIFont.systemFont(ofSize: 16, weight: .regular)
//        tv.textColor = .label
//        tv.isEditable = false
//        tv.isScrollEnabled = true
//        tv.backgroundColor = .clear
//        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        tv.isHidden = true
//        return tv
//    }()
//    
//    private let errorLabel: UILabel = {
//        let l = UILabel()
//        l.font = UIFont.systemFont(ofSize: 15)
//        l.textColor = .secondaryLabel
//        l.textAlignment = .center
//        l.numberOfLines = 0
//        l.isHidden = true
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//    
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        fetchSummary()
//    }
//    
//    // MARK: - Setup
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//        
//        subtitleLabel.text = entryTitle
//        
//        // Loading stack
//        loadingStack.addArrangedSubview(spinner)
//        loadingStack.addArrangedSubview(loadingLabel)
//        spinner.startAnimating()
//        
//        view.addSubview(titleLabel)
//        view.addSubview(subtitleLabel)
//        view.addSubview(loadingStack)
//        view.addSubview(summaryTextView)
//        view.addSubview(errorLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 24),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            
//            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            
//            // Divider-style separator (invisible spacer, content below)
//            loadingStack.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
//            loadingStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            summaryTextView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
//            summaryTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
//            summaryTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
//            summaryTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
//            
//            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
//            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
//        ])
//    }
//    
//    // MARK: - Claude API
//    
//    private func fetchSummary() {
//        guard let image = image,
//              let imageData = image.jpegData(compressionQuality: 0.7) else {
//            showError("Could not process image.")
//            return
//        }
//        
//        let base64Image = imageData.base64EncodedString()
//        
//        Task {
//            do {
//                let summary = try await callClaudeAPI(base64Image: base64Image)
//                DispatchQueue.main.async {
//                    self.showSummary(summary)
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.showError("Failed to generate summary.\nPlease try again.")
//                }
//            }
//        }
//    }
//    
//    private func callClaudeAPI(base64Image: String) async throws -> String {
//        let url = URL(string: "https://api.anthropic.com/v1/messages")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        // API key is injected by the environment — do NOT hardcode it here
//        
//        let body: [String: Any] = [
//            "model": "claude-sonnet-4-20250514",
//            "max_tokens": 1000,
//            "messages": [
//                [
//                    "role": "user",
//                    "content": [
//                        [
//                            "type": "image",
//                            "source": [
//                                "type": "base64",
//                                "media_type": "image/jpeg",
//                                "data": base64Image
//                            ]
//                        ],
//                        [
//                            "type": "text",
//                            "text": """
//                            This is a patient's journal entry image (handwritten note or photo). 
//                            Please provide a warm, empathetic 2-3 sentence summary of what's expressed. 
//                            Focus on the emotional themes and key thoughts. Keep it concise and supportive.
//                            """
//                        ]
//                    ]
//                ]
//            ]
//        ]
//        
//        request.httpBody = try JSONSerialization.data(withJSONObject: body)
//        
//        let (data, response) = try await URLSession.shared.data(for: request)
//        
//        guard let httpResponse = response as? HTTPURLResponse,
//              httpResponse.statusCode == 200 else {
//            throw NSError(domain: "ClaudeAPI", code: -1,
//                          userInfo: [NSLocalizedDescriptionKey: "API request failed"])
//        }
//        
//        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//        let content = json?["content"] as? [[String: Any]]
//        let text = content?.first?["text"] as? String ?? "No summary available."
//        
//        return text
//    }
//    
//    // MARK: - State Transitions
//    
//    private func showSummary(_ text: String) {
//        loadingStack.isHidden = true
//        summaryTextView.isHidden = false
//        summaryTextView.text = text
//    }
//    
//    private func showError(_ message: String) {
//        loadingStack.isHidden = true
//        errorLabel.isHidden = false
//        errorLabel.text = message
//    }
//}
