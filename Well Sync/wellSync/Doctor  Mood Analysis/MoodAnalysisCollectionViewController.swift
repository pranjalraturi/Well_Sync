//
//  MoodAnalysisCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import FirebaseCore
import FirebaseAILogic

class MoodAnalysisCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    let cards = ["Segment", "Calender", "Mood Count", "Mood Chart", "Insights"]
    
    private var selectedSegmentIndex: Int = 0
    private var calendarCellHeight: CGFloat = 250
    
    private var moodLogs: [MoodLog] = []
    
    private var currentVisibleRange: ClosedRange<Date>?
    
    var currPatient: Patient?
    
    var insign: String = ""
    private var insightCache: [String: String] = [:]
    private var isInsightLoading = false
    //    let model = SystemLanguageModel.default
    
    private let rangeCacheKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "CalendarCell1",                      bundle: nil), forCellWithReuseIdentifier: "calender")
        collectionView.register(UINib(nibName: "MoodChartCollectionViewCell",        bundle: nil), forCellWithReuseIdentifier: "bar_cell")
        collectionView.register(UINib(nibName: "MoodDistributionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
        collectionView.register(UINib(nibName: "insightsCollectionViewCell",         bundle: nil), forCellWithReuseIdentifier: "insights_cell")
        
        collectionView.collectionViewLayout = generateLayout()
        load()
    }
    
    // MARK: - Data Loading
    
    func load() {
        Task {
            do {
                let logs = try await AccessSupabase.shared.fetchMoodLogs(
                    patientID: currPatient?.patientID
                    ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                )
                await MainActor.run {
                    self.moodLogs = logs
                    self.insightCache = [:]
                    self.insign = ""
                    
                    self.collectionView.reloadData()
                    // After reloadData the calendar cell re-configures itself,
                    // fires the delegate, and refreshDataCells() runs again
                    // — this time with the real moodLogs.
                }
            } catch {
                print("Error fetching mood logs:", error)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func filteredLogs(for range: ClosedRange<Date>) -> [MoodLog] {
        return moodLogs
            .filter { range.contains($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    private func refreshDataCells(for range: ClosedRange<Date>, isWeekly: Bool) {
        currentVisibleRange = range
        let filtered   = filteredLogs(for: range)
        let rangeStart = range.lowerBound
        let cacheKey   = rangeCacheKeyFormatter.string(from: rangeStart)
        
        if let countCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 2)
        ) as? MoodDistributionCollectionViewCell {
            countCell.configure(moodLogs: filtered)
        }
        
        if let chartCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 3)
        ) as? MoodChartCollectionViewCell {
            chartCell.configure(moodLogs: filtered, rangeStart: rangeStart, isWeekly: isWeekly)
        }
        
        if let cached = insightCache[cacheKey] {
            // Previously seen range — show instantly.
            insign = cached
            if let insightCell = collectionView.cellForItem(
                at: IndexPath(item: 0, section: 4)
            ) as? insightsCollectionViewCell {
                insightCell.configur(with: cached)
            }
        } else if filtered.isEmpty {
            insign = "No mood logs recorded for this period."
            if let insightCell = collectionView.cellForItem(
                at: IndexPath(item: 0, section: 4)
            ) as? insightsCollectionViewCell {
                insightCell.configur(with: insign)
            }
        } else {
            insign = ""
            if let insightCell = collectionView.cellForItem(
                at: IndexPath(item: 0, section: 4)
            ) as? insightsCollectionViewCell {
                insightCell.configur(with: "Analyzing patient mood patterns…")
            }
            loadInsight(logs: filtered, rangeKey: cacheKey)
        }
    }
    
    private func loadInsight(logs: [MoodLog], rangeKey: String) {
        
        guard !isInsightLoading else { return }
        isInsightLoading = true
        
        Task {
            let result = await insightLocal(moodLog: logs)
            
            await MainActor.run {
                self.insightCache[rangeKey] = result
                self.isInsightLoading = false
                
                // Only update the UI if the user is still on this range.
                let currentKey = self.currentVisibleRange.map {
                    self.rangeCacheKeyFormatter.string(from: $0.lowerBound)
                }
                guard currentKey == rangeKey else { return }
                
                self.insign = result
                DispatchQueue.main.async {
                    self.collectionView.reloadSections(IndexSet(integer: 4))
                }
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cards.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
            
        case 1:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "calender", for: indexPath
            ) as! CalendarCell1
            style(cell)
            cell.moodLogs = moodLogs
            cell.delegate = self
            cell.configure(segment: selectedSegmentIndex)
            cell.onHeightChange = { [weak self] newHeight in
                guard let self = self else { return }
                self.calendarCellHeight = newHeight + 16
                self.collectionView.collectionViewLayout = self.generateLayout()
            }
            return cell
            
        case 2:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "count_cell", for: indexPath
            ) as! MoodDistributionCollectionViewCell
            style(cell)
            if let range = currentVisibleRange {
                cell.configure(moodLogs: filteredLogs(for: range))
            } else {
                cell.configure(moodLogs: [])
            }
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "bar_cell", for: indexPath
            ) as! MoodChartCollectionViewCell
            style(cell)
            if let range = currentVisibleRange {
                cell.configure(
                    moodLogs:   filteredLogs(for: range),
                    rangeStart: range.lowerBound,
                    isWeekly:   selectedSegmentIndex == 0
                )
            } else {
                cell.configure(
                    moodLogs:   [],
                    rangeStart: Calendar.current.startOfDay(for: Date()),
                    isWeekly:   selectedSegmentIndex == 0
                )
            }
            return cell
            
        case 4:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "insights_cell", for: indexPath
            ) as! insightsCollectionViewCell
            style(cell)
            cell.configur(with: insign.isEmpty ? "Analyzing patient mood patterns…" : insign)
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "segment", for: indexPath)
            return cell
        }
    }
    
    // MARK: - Segment Changed
    
    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        if let calCell = collectionView.cellForItem(
            at: IndexPath(item: 0, section: 1)
        ) as? CalendarCell1 {
            calCell.configure(segment: selectedSegmentIndex)
        }
    }
    
    // MARK: - Styling
    
    func style(_ cell: UICollectionViewCell) {
        cell.layer.cornerRadius  = 16
        cell.layer.masksToBounds = true
    }
    
    // MARK: - Layout
    
    func generateLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let height: NSCollectionLayoutDimension
            
            switch sectionIndex {
            case 0:
                let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item      = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
                let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(12)
                let section   = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                return section
            case 1:  height = .absolute(self.calendarCellHeight)
            case 2:  height = .estimated(380)
            case 3:  height = .estimated(240)
            default: height = .estimated(300)
            }
            
            let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item      = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
            let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(8)
            let section   = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
            return section
        }
    }
    
    // MARK: - AI Insight (chunked on-device model)
    
    //    func insightLocal(moodLog: [MoodLog]) async -> String {
    //
    //        guard !moodLog.isEmpty else {
    //            return "No mood data available for clinical evaluation."
    //        }
    //
    //        let sortedLogs = moodLog.sorted { $0.date < $1.date }
    //        let chunkSize  = 6
    //        let chunks: [[MoodLog]] = stride(from: 0, to: sortedLogs.count, by: chunkSize).map {
    //            Array(sortedLogs[$0..<min($0 + chunkSize, sortedLogs.count)])
    //        }
    //
    //        var partialInsights: [String] = []
    //
    //        for chunk in chunks {
    //            let logsText = chunk.map { log in
    //                let date     = log.date.formatted(date: .abbreviated, time: .omitted)
    //                let note     = (log.moodNote ?? "No note").prefix(80)
    //                let feelings = log.selectedFeeling?.map { "\($0)" }.joined(separator: ", ") ?? "None"
    //                return """
    //                Date: \(date)
    //                Mood: \(log.mood)
    //                Feelings: \(feelings)
    //                Note: \(note)
    //                """
    //            }.joined(separator: "\n\n")
    //
    //            let prompt = """
    //            You are a clinical assistant supporting a mental health professional.
    //            Analyze the following mood logs and generate a precise clinical observation.
    //            Instructions:
    //            - mood 1 - very bad, 2 - bad, 3 - neutral, 4 - happy, 5 - very happy
    //            - Maximum 50 words
    //            - Be specific and observational
    //            - Avoid vague terms like "overall" or "seems"
    //            - Highlight variability, emotional signals, or notable patterns
    //            - Do NOT give advice
    //            Mood Logs:
    //            \(logsText)
    //            """
    //
    //            do {
    //                let session  = LanguageModelSession()
    //                let response = try await session.respond(to: prompt)
    //                partialInsights.append(response.content)
    //            } catch { continue }
    //        }
    //
    //        let finalPrompt = """
    //        You are a clinical assistant preparing a summary for a doctor.
    //        Combine the following observations into a final clinical summary.
    //        Instructions:
    //        - Maximum 50 words
    //        - Write in 2–3 sentences
    //        - Use professional, objective tone
    //        - Clearly describe mood pattern, emotional indicators, and any noticeable changes
    //        - Avoid "overall" or "seems" — be specific
    //        - Do NOT give advice
    //        Observations:
    //        \(partialInsights.joined(separator: "\n"))
    //        """
    //
    //        do {
    //            let session       = LanguageModelSession()
    //            let finalResponse = try await session.respond(to: finalPrompt)
    //            return finalResponse.content
    //        } catch {
    //            print("Final Insight Error:", error)
    //            return "\(error)"
    //        }
    //    }
    //}
    
    // MARK: - AI Insight (Gemini via Firebase AI Logic)
    
    func insightLocal(moodLog: [MoodLog]) async -> String {
        
        guard !moodLog.isEmpty else {
            return "No mood data available for clinical evaluation."
        }
        
        let sortedLogs = moodLog.sorted { $0.date < $1.date }
        
        let logsText = sortedLogs.map { log -> String in
            let date     = log.date.formatted(date: .abbreviated, time: .omitted)
            let note     = (log.moodNote ?? "No note").prefix(80)
            let feelings = log.selectedFeeling?.map { "\($0)" }.joined(separator: ", ") ?? "None"
            return """
            Date: \(date)
            Mood: \(log.mood)
            Feelings: \(feelings)
            Note: \(note)
            """
        }.joined(separator: "\n\n")
        
        let prompt = """
        You are a clinical assistant preparing a summary for a doctor.
        Analyze the following mood logs and write a clinical summary.
        Instructions:
        - Mood scale: 1 = very bad, 2 = bad, 3 = neutral, 4 = happy, 5 = very happy
        - Maximum 60 words
        - Write in 2–3 sentences
        - Use professional, objective tone
        - Describe mood pattern, emotional indicators, and any noticeable changes
        - Avoid words like "overall" or "seems" — be specific
        - Do NOT give advice or recommendations
        
        Mood Logs:
        \(logsText)
        """
        
        do {
            let response = try await Summarise.summarise.model.generateContent(prompt)
            return response.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? "Could not generate insight."
        } catch {
            print("Gemini insight error:", error)
            return "Insight unavailable. Please try again later."
        }
    }
}
// MARK: - CalendarCell1Delegate

extension MoodAnalysisCollectionViewController: CalendarCell1Delegate {

    func calendarCell(_ cell: CalendarCell1,
                      didChangeVisibleRange range: ClosedRange<Date>,
                      isWeekly: Bool) {
        refreshDataCells(for: range, isWeekly: isWeekly)
    }

    func calendarCell(_ cell: CalendarCell1,
                      didChangeHeight height: CGFloat) {
        calendarCellHeight = height + 16
        collectionView.collectionViewLayout = generateLayout()
    }
}
