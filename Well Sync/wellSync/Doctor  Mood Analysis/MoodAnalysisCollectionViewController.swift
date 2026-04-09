////
////  MoodAnalysisCollectionViewController.swift
////  wellSync
////
////  Created by Vidit Agarwal on 04/02/26.
////
//
//import UIKit
//import FoundationModels
//
//
//private let reuseIdentifier = "Cell"
//
//class MoodAnalysisCollectionViewController: UICollectionViewController {
//
//    let cards = ["Segment","Calender","Mood Count","Mood Chart","Insights"]
//    private var selectedSegmentIndex: Int = 0
//    private var calendarCellHeight: CGFloat = 250
//    private var moodLogs: [MoodLog] = []
//    var currPatient: Patient?
//    var insign:String = ""
//    private var weeklyInsightCache: String?
//    private var monthlyInsightCache: String?
//    private var isInsightLoading = false
//    let model = SystemLanguageModel.default
//    // MARK: - Computed Filters
//
//    var weeklyMoodLog: [MoodLog] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        guard let startOfWeek = calendar.date(byAdding: .day, value: -6, to: now) else {
//            return []
//        }
//        
//        return moodLogs.filter {
//            $0.date >= calendar.startOfDay(for: startOfWeek) &&
//            $0.date <= now
//        }
//        .sorted { $0.date < $1.date }
//    }
//    var monthlyMoodLogs: [MoodLog] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        guard let startOfMonth = calendar.date(byAdding: .day, value: -29, to: now) else {
//            return []
//        }
//        
//        return moodLogs.filter {
//            $0.date >= calendar.startOfDay(for: startOfMonth) &&
//            $0.date <= now
//        }
//        .sorted { $0.date < $1.date }
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Register cell classes
//        self.collectionView.register(UINib(nibName: "CalendarCell1", bundle: nil), forCellWithReuseIdentifier: "calender")
//        self.collectionView.register(UINib(nibName: "MoodChartCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bar_cell")
////        self.collectionView.register(UINib(nibName: "MoodCountCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
//        self.collectionView.register(UINib(nibName: "MoodDistributionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
//        self.collectionView.register(UINib(nibName: "insightsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "insights_cell")
//        collectionView.collectionViewLayout = generateLayout()
//        load()
//        // Do any additional setup after loading the view.
//    }
//
//    func load(){
//        Task {
//            do {
//                let logs = try await AccessSupabase.shared.fetchMoodLogs(
//                    patientID: currPatient?.patientID ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
//                )
//                
//                await MainActor.run {
//                    self.moodLogs = logs
//                    self.collectionView.reloadData()
//                }
//                
//            } catch {
//                print("Error in mood Fetch", error)
//            }
//        }
//    }
//    func loadInsight(logs: [MoodLog], isWeekly: Bool) {
//        
//        if isInsightLoading { return }
//        
//        // ✅ Return cached if exists (NO reload here)
//        if isWeekly, let cache = weeklyInsightCache {
//            insign = cache
//            return
//        }
//        
//        if !isWeekly, let cache = monthlyInsightCache {
//            insign = cache
//            return
//        }
//        
//        isInsightLoading = true
//        
//        Task {
//            let result = await insightLocal(moodLog: logs)
//            
//            await MainActor.run {
//                if isWeekly {
//                    self.weeklyInsightCache = result
//                } else {
//                    self.monthlyInsightCache = result
//                }
//                
//                self.insign = result
//                self.isInsightLoading = false
//                
//                // ✅ SAFE reload (fixes crash)
//                DispatchQueue.main.async {
//                    self.collectionView.reloadSections(IndexSet(integer: 4))
//                }
//            }
//        }
//    }
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return cards.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 1
//    }
//
//    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        switch indexPath.section {
//        case 1:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calender", for: indexPath) as! CalendarCell1
//                        style(cell)
//            cell.moodLogs = monthlyMoodLogs
//                        cell.onHeightChange = { [weak self] newHeight in
//                            guard let self = self else { return }
//
//                            self.calendarCellHeight = newHeight + 16
//
//                            self.collectionView.collectionViewLayout = self.generateLayout()
//                        }
//                    
//                        cell.configure(segment: selectedSegmentIndex)
//                        return cell
//
//        case 2:
////            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "count_cell", for: indexPath) as! MoodCountCollectionViewCell
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "count_cell", for: indexPath) as! MoodDistributionCollectionViewCell
//            style(cell)
//            cell.configure(moodLogs: weeklyMoodLog)
//            return cell
//
//        case 3:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bar_cell", for: indexPath) as! MoodChartCollectionViewCell
//            style(cell)
//            cell.moodLogs = weeklyMoodLog
//            return cell
//        case 4:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "insights_cell", for: indexPath) as! insightsCollectionViewCell
//            
//            style(cell)
//            
//            cell.configur(with: insign.isEmpty ? "Analyzing Patient mood patterns..." : insign)
//            
//            loadInsight(
//                logs: selectedSegmentIndex == 0 ? weeklyMoodLog : monthlyMoodLogs,
//                isWeekly: selectedSegmentIndex == 0
//            )
//            
//            return cell
//        default:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "segment", for: indexPath)
//            return cell
//        }
//    }
//
//    func style(_ cell: UICollectionViewCell) {
//        cell.layer.cornerRadius = 16
//        cell.layer.masksToBounds = true
//    }
//
//    func generateLayout() -> UICollectionViewCompositionalLayout {
//
//        return UICollectionViewCompositionalLayout { sectionIndex, _ in
//
//            let height: NSCollectionLayoutDimension
//            
//            switch sectionIndex {
//            case 0:
//                height = .estimated(50)
//                let itemSize = NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: .fractionalHeight(1.0)
//                )
//
//                let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//                let groupSize = NSCollectionLayoutSize(
//                    widthDimension: .fractionalWidth(1.0),
//                    heightDimension: height
//                )
//
//                let group = NSCollectionLayoutGroup.vertical(
//                    layoutSize: groupSize,
//                    subitems: [item]
//                )
//                group.interItemSpacing = .fixed(12)
//                let section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 12
//                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//
//                return section
//            case 1:
//                height = .absolute(self.calendarCellHeight)
//            case 2:
//                height = .estimated(380)
//            case 3:
//                height = .estimated(240)
//            default:
//                height = .estimated(300)
//            }
//
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .fractionalHeight(1.0)
//            )
//
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: height
//            )
//
//            let group = NSCollectionLayoutGroup.vertical(
//                layoutSize: groupSize,
//                subitems: [item]
//            )
//            group.interItemSpacing = .fixed(8)
//            let section = NSCollectionLayoutSection(group: group)
//            section.interGroupSpacing = 8
//            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
//            
//
//            return section
//        }
//    }
//    
//    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
//        selectedSegmentIndex = sender.selectedSegmentIndex
//
//        if let calCell = collectionView.cellForItem(
//            at: IndexPath(item: 0, section: 1)
//        ) as? CalendarCell1 {
//            calCell.configure(segment: selectedSegmentIndex)
//        }
//
//        if let chartCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 3)) as? MoodChartCollectionViewCell {
//            chartCell.isWeekly = (selectedSegmentIndex == 0)
//            chartCell.moodLogs = selectedSegmentIndex == 0 ? weeklyMoodLog : monthlyMoodLogs
//        }
//
//        if let countCell = collectionView.cellForItem(at: IndexPath(item: 0, section: 2)) as? MoodDistributionCollectionViewCell {
//            countCell.configure(moodLogs: selectedSegmentIndex == 0 ? weeklyMoodLog : monthlyMoodLogs)
//        }
//
//        // ✅ Reset UI immediately
//        insign = ""
//        collectionView.reloadSections(IndexSet(integer: 4))
//
//        // ✅ Load correct insight
//        loadInsight(
//            logs: selectedSegmentIndex == 0 ? weeklyMoodLog : monthlyMoodLogs,
//            isWeekly: selectedSegmentIndex == 0
//        )
//    }
////    func insightLocal(moodLog: [MoodLog]) async -> String {
////        
////        guard !moodLog.isEmpty else {
////            return "No mood data available for clinical evaluation."
////        }
////        
////        // Convert logs into structured text (DO NOT analyze here)
////        let logsText = moodLog
////            .sorted { $0.date < $1.date }
////            .map { log in
////                
////                let date = log.date.formatted(date: .abbreviated, time: .omitted)
////                let mood = log.mood
////                let note = log.moodNote ?? "No note"
////                let feelings = log.selectedFeeling?.map { "\($0)" }.joined(separator: ", ") ?? "None"
////                
////                return """
////                Date: \(date)
////                Mood Score: \(mood)
////                Feelings: \(feelings)
////                Note: \(note)
////                """
////            }
////            .joined(separator: "\n\n")
////        
////        // Clinical prompt (IMPORTANT CHANGE)
////        let prompt = """
////        You are a clinical assistant helping a mental health professional.
////
////        Analyze the following patient mood logs and generate a concise clinical summary.
////
////        Instructions:
////        - Maximum 45 - 50 words
////        - Maintain a professional, objective tone
////        - Focus on patterns, variability, and notable observations
////        - Avoid giving advice directly to the patient
////        - Write as if reporting to a doctor
////
////        Mood Logs:
////        \(logsText)
////        """
////        
////        do {
////            let session = LanguageModelSession()
////            let response = try await session.respond(to: prompt)
////            
////            return response.content   // or outputText depending on SDK
////        } catch {
////            return "Clinical summary unavailable. Mood data present but analysis could not be generated."
////        }
////    }
//    func insightLocal(moodLog: [MoodLog]) async -> String {
//        
//        guard !moodLog.isEmpty else {
//            return "No mood data available for clinical evaluation."
//        }
//        
//        let sortedLogs = moodLog.sorted { $0.date < $1.date }
//        
//        let chunkSize = 6
//        let chunks: [[MoodLog]] = stride(from: 0, to: sortedLogs.count, by: chunkSize).map {
//            Array(sortedLogs[$0..<min($0 + chunkSize, sortedLogs.count)])
//        }
//        
//        var partialInsights: [String] = []
//        
//        for chunk in chunks {
//            
//            let logsText = chunk.map { log in
//                let date = log.date.formatted(date: .abbreviated, time: .omitted)
//                let mood = log.mood
//                let note = (log.moodNote ?? "No note").prefix(80)
//                let feelings = log.selectedFeeling?.map { "\($0)" }.joined(separator: ", ") ?? "None"
//                
//                return """
//                Date: \(date)
//                Mood: \(mood)
//                Feelings: \(feelings)
//                Note: \(note)
//                """
//            }
//            .joined(separator: "\n\n")
//            
//            let prompt = """
//            You are a clinical assistant supporting a mental health professional.
//
//            Analyze the following mood logs and generate a precise clinical observation.
//
//            Instructions:
//            - mood 1 - very bad, 2 - bad, 3 - neutral, 4 - happy, 5 - very happy
//            - Maximum 50 words
//            - Be specific and observational
//            - Avoid vague terms like "overall" or "seems"
//            - Highlight variability, emotional signals, or notable patterns
//            - Do NOT give advice
//
//            Mood Logs:
//            \(logsText)
//            """
//            
//            do {
//                let session = LanguageModelSession()
//                let response = try await session.respond(to: prompt)
//                partialInsights.append(response.content)
//            } catch {
//                continue
//            }
//        }
//        
//        // ✅ Final structured summary
//        let finalPrompt = """
//        You are a clinical assistant preparing a summary for a doctor.
//
//        Combine the following observations into a final clinical summary.
//
//        Instructions:
//        - Maximum 50 words
//        - Write in 2–3 sentences
//        - Use professional, objective tone
//        - Clearly describe:
//          • Mood pattern (stable / fluctuating / declining / improving)
//          • Emotional indicators (stress, low mood, etc.)
//          • Any noticeable changes across time
//        - Avoid generic phrases like "overall" or "seems"
//        - Do NOT give advice
//
//        Observations:
//        \(partialInsights.joined(separator: "\n"))
//        """
//        
//        do {
//            let session = LanguageModelSession()
//            let finalResponse = try await session.respond(to: finalPrompt)
//            return finalResponse.content
//        } catch {
//            print("Final Insight Error:", error)
//            return "\(error)"
//        }
//    }
//}
//
////
//////
//////  MoodAnalysisCollectionViewController.swift
//////  wellSync
//////
//////  Created by Vidit Agarwal on 04/02/26.
//////
////
////import UIKit
////
////class MoodAnalysisCollectionViewController: UICollectionViewController {
////
////    // MARK: - Properties
////
////    let cards = ["Segment", "Calender", "Mood Count", "Mood Chart", "Insights"]
////
////    private var selectedSegmentIndex: Int = 0
////    private var calendarCellHeight: CGFloat = 250
////
////    // All raw logs fetched once from Supabase
////    private var moodLogs: [MoodLog] = []
////
////    // The date range currently visible in the calendar cell.
////    // Starts as "current week" and updates whenever the user swipes or switches segment.
////    private var currentVisibleRange: ClosedRange<Date> = {
////        let cal   = Calendar.current
////        let today = cal.startOfDay(for: Date())
////        // Default to the current week (Sun–Sat)
////        let sun   = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
////        let sat   = cal.date(byAdding: .day, value: 6, to: sun)!
////        let endOfSat = cal.date(bySettingHour: 23, minute: 59, second: 59, of: sat)!
////        return sun...endOfSat
////    }()
////
////    var currPatient: Patient?
////
////    // MARK: - Helpers
////
////    /// Returns logs that fall inside `range`, sorted ascending by date.
////    private func filteredLogs(for range: ClosedRange<Date>) -> [MoodLog] {
////        return moodLogs
////            .filter { range.contains($0.date) }
////            .sorted { $0.date < $1.date }
////    }
////
////    // MARK: - View Lifecycle
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        collectionView.register(UINib(nibName: "CalendarCell1",                    bundle: nil), forCellWithReuseIdentifier: "calender")
////        collectionView.register(UINib(nibName: "MoodChartCollectionViewCell",      bundle: nil), forCellWithReuseIdentifier: "bar_cell")
////        collectionView.register(UINib(nibName: "MoodDistributionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
////        collectionView.register(UINib(nibName: "insightsCollectionViewCell",       bundle: nil), forCellWithReuseIdentifier: "insights_cell")
////
////        collectionView.collectionViewLayout = generateLayout()
////
////        Task {
////            do {
////                let logs = try await AccessSupabase.shared.fetchMoodLogs(
////                    patientID: currPatient?.patientID
////                        ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
////                )
////                await MainActor.run {
////                    self.moodLogs = logs
////                    self.collectionView.reloadData()
////                    // After reload, push the initial range data to all visible cells.
////                    self.refreshDataCells(for: self.currentVisibleRange,
////                                         isWeekly: self.selectedSegmentIndex == 0)
////                }
////            } catch {
////                print("Error fetching mood logs:", error)
////            }
////        }
////    }
////
////    // MARK: - Data Push  ← the single place that updates Distribution + Chart
////    //
////    // Called by:
////    //   • CalendarCell1Delegate when the user swipes to a new page
////    //   • viewDidLoad after the Supabase fetch completes
////    //   • sectionChanged when the segment toggle fires
////    //
////    // Uses prepare-style configure() on each cell — no closures, no callbacks.
////
////    private func refreshDataCells(for range: ClosedRange<Date>, isWeekly: Bool) {
////        currentVisibleRange = range
////
////        let filtered   = filteredLogs(for: range)
////        let rangeStart = range.lowerBound   // midnight of first visible day
////
////        // ── Distribution cell ─────────────────────────────────────────────────
////        if let countCell = collectionView.cellForItem(
////            at: IndexPath(item: 0, section: 2)
////        ) as? MoodDistributionCollectionViewCell {
////            countCell.configure(moodLogs: filtered)
////        }
////
////        // ── Chart cell ────────────────────────────────────────────────────────
////        if let chartCell = collectionView.cellForItem(
////            at: IndexPath(item: 0, section: 3)
////        ) as? MoodChartCollectionViewCell {
////            chartCell.configure(moodLogs: filtered,
////                                rangeStart: rangeStart,
////                                isWeekly: isWeekly)
////        }
////    }
////
////    // MARK: - UICollectionViewDataSource
////
////    override func numberOfSections(in collectionView: UICollectionView) -> Int {
////        return cards.count
////    }
////
////    override func collectionView(_ collectionView: UICollectionView,
////                                 numberOfItemsInSection section: Int) -> Int {
////        return 1
////    }
////
////    override func collectionView(_ collectionView: UICollectionView,
////                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        switch indexPath.section {
////
////        // ── Section 1: Calendar ───────────────────────────────────────────────
////        case 1:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "calender", for: indexPath
////            ) as! CalendarCell1
////            style(cell)
////
////            // Pass ALL logs — the cell uses them only for day colours.
////            cell.moodLogs = moodLogs
////
////            // Wire up our delegate (no closures).
////            cell.delegate = self
////
////            // Set scope to match current segment; this also fires
////            // calendarCell(_:didChangeVisibleRange:isWeekly:) immediately.
////            cell.configure(segment: selectedSegmentIndex)
////            return cell
////
////        // ── Section 2: Distribution ───────────────────────────────────────────
////        case 2:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "count_cell", for: indexPath
////            ) as! MoodDistributionCollectionViewCell
////            style(cell)
////            // Populate with whatever range is currently visible
////            cell.configure(moodLogs: filteredLogs(for: currentVisibleRange))
////            return cell
////
////        // ── Section 3: Chart ──────────────────────────────────────────────────
////        case 3:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "bar_cell", for: indexPath
////            ) as! MoodChartCollectionViewCell
////            style(cell)
////            cell.configure(
////                moodLogs:   filteredLogs(for: currentVisibleRange),
////                rangeStart: currentVisibleRange.lowerBound,
////                isWeekly:   selectedSegmentIndex == 0
////            )
////            return cell
////
////        // ── Section 4: Insights ───────────────────────────────────────────────
////        case 4:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "insights_cell", for: indexPath
////            ) as! insightsCollectionViewCell
////            style(cell)
////            return cell
////
////        // ── Section 0: Segment control (default) ─────────────────────────────
////        default:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "segment", for: indexPath)
////            return cell
////        }
////    }
////
////    // MARK: - IBAction: Segment Toggle
////    //
////    // Simplified: just tell the calendar cell to switch scope.
////    // CalendarCell1.configure() fires the delegate which calls refreshDataCells().
////    // No manual chart/count updating needed here.
////
////    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
////        selectedSegmentIndex = sender.selectedSegmentIndex
////
////        if let calCell = collectionView.cellForItem(
////            at: IndexPath(item: 0, section: 1)
////        ) as? CalendarCell1 {
////            calCell.configure(segment: selectedSegmentIndex)
////        }
////    }
////
////    // MARK: - Styling
////
////    func style(_ cell: UICollectionViewCell) {
////        cell.layer.cornerRadius  = 16
////        cell.layer.masksToBounds = true
////    }
////
////    // MARK: - Layout
////
////    func generateLayout() -> UICollectionViewCompositionalLayout {
////        return UICollectionViewCompositionalLayout { sectionIndex, _ in
////
////            let height: NSCollectionLayoutDimension
////
////            switch sectionIndex {
////            case 0:
////                // Segment control — compact height
////                let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
////                let item      = NSCollectionLayoutItem(layoutSize: itemSize)
////                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))
////                let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
////                group.interItemSpacing = .fixed(12)
////                let section   = NSCollectionLayoutSection(group: group)
////                section.interGroupSpacing = 12
////                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
////                return section
////
////            case 1:
////                height = .absolute(self.calendarCellHeight)
////            case 2:
////                height = .estimated(380)
////            case 3:
////                height = .estimated(240)
////            default:
////                height = .estimated(160)
////            }
////
////            let itemSize  = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
////            let item      = NSCollectionLayoutItem(layoutSize: itemSize)
////            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: height)
////            let group     = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
////            group.interItemSpacing = .fixed(8)
////            let section   = NSCollectionLayoutSection(group: group)
////            section.interGroupSpacing = 8
////            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
////            return section
////        }
////    }
////}
////
////// MARK: - CalendarCell1Delegate
//////
////// The calendar calls these two methods instead of the old onHeightChange closure.
////
////extension MoodAnalysisCollectionViewController: CalendarCell1Delegate {
////
////    /// Fires whenever the user swipes to a new week/month page, OR when
////    /// configure(segment:) is called (scope switch).  This is the single
////    /// data-sync trigger — no other call site needs to update the cells.
////    func calendarCell(_ cell: CalendarCell1,
////                      didChangeVisibleRange range: ClosedRange<Date>,
////                      isWeekly: Bool) {
////        refreshDataCells(for: range, isWeekly: isWeekly)
////    }
////
////    /// Fires during the week ↔ month animation so the layout can resize smoothly.
////    func calendarCell(_ cell: CalendarCell1,
////                      didChangeHeight height: CGFloat) {
////        calendarCellHeight = height + 16
////        collectionView.collectionViewLayout = generateLayout()
////    }
////}
//
////import UIKit
////
////class MoodAnalysisCollectionViewController: UICollectionViewController {
////
////    let cards = ["Segment", "Calender", "Mood Count", "Mood Chart", "Insights"]
////
////    private var selectedSegmentIndex: Int = 0
////    private var calendarCellHeight: CGFloat = 250
////
////    private var moodLogs: [MoodLog] = []
////
////    // ✅ IMPORTANT: no default calculation
////    private var currentVisibleRange: ClosedRange<Date>?
////
////    var currPatient: Patient?
////
////    // MARK: - Helpers
////
////    private func filteredLogs(for range: ClosedRange<Date>) -> [MoodLog] {
////        return moodLogs
////            .filter { range.contains($0.date) }
////            .sorted { $0.date < $1.date }
////    }
////
////    // MARK: - Lifecycle
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        collectionView.register(UINib(nibName: "CalendarCell1", bundle: nil), forCellWithReuseIdentifier: "calender")
////        collectionView.register(UINib(nibName: "MoodChartCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bar_cell")
////        collectionView.register(UINib(nibName: "MoodDistributionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "count_cell")
////        collectionView.register(UINib(nibName: "insightsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "insights_cell")
////
////        collectionView.collectionViewLayout = generateLayout()
////
////        Task {
////            do {
////                let logs = try await AccessSupabase.shared.fetchMoodLogs(
////                    patientID: currPatient?.patientID
////                        ?? UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
////                )
////
////                await MainActor.run {
////                    self.moodLogs = logs
////                    self.collectionView.reloadData()
////                }
////
////            } catch {
////                print("Error fetching mood logs:", error)
////            }
////        }
////    }
////
////    // MARK: - Data Refresh (CORE FIX)
////
////    private func refreshDataCells(for range: ClosedRange<Date>, isWeekly: Bool) {
////        currentVisibleRange = range
////
////        DispatchQueue.main.async {
////            self.collectionView.reloadSections(IndexSet(integer: 2))
////            self.collectionView.reloadSections(IndexSet(integer: 3))
////        }
////    }
////
////    // MARK: - DataSource
////
////    override func numberOfSections(in collectionView: UICollectionView) -> Int {
////        return cards.count
////    }
////
////    override func collectionView(_ collectionView: UICollectionView,
////                                 numberOfItemsInSection section: Int) -> Int {
////        return 1
////    }
////
////    override func collectionView(_ collectionView: UICollectionView,
////                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////
////        switch indexPath.section {
////
////        case 1:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "calender", for: indexPath
////            ) as! CalendarCell1
////
////            style(cell)
////
////            cell.moodLogs = moodLogs
////            cell.delegate = self
////
////            // ✅ THIS triggers correct range immediately
////            cell.configure(segment: selectedSegmentIndex)
////
////            return cell
////
////        case 2:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "count_cell", for: indexPath
////            ) as! MoodDistributionCollectionViewCell
////
////            style(cell)
////
////            if let range = currentVisibleRange {
////                cell.configure(moodLogs: filteredLogs(for: range))
////            } else {
////                cell.configure(moodLogs: [])
////            }
////
////            return cell
////
////        case 3:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "bar_cell", for: indexPath
////            ) as! MoodChartCollectionViewCell
////
////            style(cell)
////
////            if let range = currentVisibleRange {
////                cell.configure(
////                    moodLogs: filteredLogs(for: range),
////                    rangeStart: range.lowerBound,
////                    isWeekly: selectedSegmentIndex == 0
////                )
////            } else {
////                cell.configure(
////                    moodLogs: [],
////                    rangeStart: Date(),
////                    isWeekly: true
////                )
////            }
////
////            return cell
////
////        case 4:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "insights_cell", for: indexPath
////            ) as! insightsCollectionViewCell
////
////            style(cell)
////            return cell
////
////        default:
////            let cell = collectionView.dequeueReusableCell(
////                withReuseIdentifier: "segment", for: indexPath)
////            return cell
////        }
////    }
////
////    // MARK: - Segment Change
////
////    @IBAction func sectionChanged(_ sender: UISegmentedControl) {
////        selectedSegmentIndex = sender.selectedSegmentIndex
////
////        if let calCell = collectionView.cellForItem(
////            at: IndexPath(item: 0, section: 1)
////        ) as? CalendarCell1 {
////            calCell.configure(segment: selectedSegmentIndex)
////        }
////    }
////
////    // MARK: - Styling
////
////    func style(_ cell: UICollectionViewCell) {
////        cell.layer.cornerRadius = 16
////        cell.layer.masksToBounds = true
////    }
////
////    // MARK: - Layout
////
////    func generateLayout() -> UICollectionViewCompositionalLayout {
////        return UICollectionViewCompositionalLayout { sectionIndex, _ in
////
////            let height: NSCollectionLayoutDimension
////
////            switch sectionIndex {
////            case 0:
////                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                                      heightDimension: .fractionalHeight(1.0))
////                let item = NSCollectionLayoutItem(layoutSize: itemSize)
////
////                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                                       heightDimension: .estimated(50))
////                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
////
////                let section = NSCollectionLayoutSection(group: group)
////                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
////                return section
////
////            case 1:
////                height = .absolute(self.calendarCellHeight)
////            case 2:
////                height = .estimated(380)
////            case 3:
////                height = .estimated(240)
////            default:
////                height = .estimated(160)
////            }
////
////            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                                  heightDimension: .fractionalHeight(1.0))
////            let item = NSCollectionLayoutItem(layoutSize: itemSize)
////
////            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
////                                                   heightDimension: height)
////            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
////
////            let section = NSCollectionLayoutSection(group: group)
////            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
////
////            return section
////        }
////    }
////}
////
////// MARK: - Calendar Delegate
////
////extension MoodAnalysisCollectionViewController: CalendarCell1Delegate {
////
////    func calendarCell(_ cell: CalendarCell1,
////                      didChangeVisibleRange range: ClosedRange<Date>,
////                      isWeekly: Bool) {
////        refreshDataCells(for: range, isWeekly: isWeekly)
////    }
////
////    func calendarCell(_ cell: CalendarCell1,
////                      didChangeHeight height: CGFloat) {
////        calendarCellHeight = height + 16
////        collectionView.collectionViewLayout = generateLayout()
////    }
////}
//
//  MoodAnalysisCollectionViewController.swift
//  wellSync
//
//  Created by Vidit Agarwal on 04/02/26.
//

import UIKit
import FoundationModels

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
    let model = SystemLanguageModel.default

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

    func insightLocal(moodLog: [MoodLog]) async -> String {

        guard !moodLog.isEmpty else {
            return "No mood data available for clinical evaluation."
        }

        let sortedLogs = moodLog.sorted { $0.date < $1.date }
        let chunkSize  = 6
        let chunks: [[MoodLog]] = stride(from: 0, to: sortedLogs.count, by: chunkSize).map {
            Array(sortedLogs[$0..<min($0 + chunkSize, sortedLogs.count)])
        }

        var partialInsights: [String] = []

        for chunk in chunks {
            let logsText = chunk.map { log in
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
            You are a clinical assistant supporting a mental health professional.
            Analyze the following mood logs and generate a precise clinical observation.
            Instructions:
            - mood 1 - very bad, 2 - bad, 3 - neutral, 4 - happy, 5 - very happy
            - Maximum 50 words
            - Be specific and observational
            - Avoid vague terms like "overall" or "seems"
            - Highlight variability, emotional signals, or notable patterns
            - Do NOT give advice
            Mood Logs:
            \(logsText)
            """

            do {
                let session  = LanguageModelSession()
                let response = try await session.respond(to: prompt)
                partialInsights.append(response.content)
            } catch { continue }
        }

        let finalPrompt = """
        You are a clinical assistant preparing a summary for a doctor.
        Combine the following observations into a final clinical summary.
        Instructions:
        - Maximum 50 words
        - Write in 2–3 sentences
        - Use professional, objective tone
        - Clearly describe mood pattern, emotional indicators, and any noticeable changes
        - Avoid "overall" or "seems" — be specific
        - Do NOT give advice
        Observations:
        \(partialInsights.joined(separator: "\n"))
        """

        do {
            let session       = LanguageModelSession()
            let finalResponse = try await session.respond(to: finalPrompt)
            return finalResponse.content
        } catch {
            print("Final Insight Error:", error)
            return "\(error)"
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
