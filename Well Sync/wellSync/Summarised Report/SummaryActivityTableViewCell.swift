//
//  SummaryActivityTableViewCell.swift
//  wellSync
//
//  Created by Rishika Mittal on 07/02/26.
//

import UIKit

class SummaryActivityTableViewCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 16, right: 20)
        stackView.axis    = .vertical
        stackView.spacing = 16
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80).isActive = true
    }

    func configure(for patientID: UUID) async {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        do {
            // Was: assignedActivities.filter
            let allAssignments = try await AccessSupabase.shared.fetchAssignments(for: patientID)
            let activeAssignments = allAssignments.filter { $0.status == .active }

            // Was: activityLogs.filter
            let allLogs = try await AccessSupabase.shared.fetchLogs(for: patientID)

            for (index, assignment) in activeAssignments.enumerated() {

                // Was: activityCatalog.first(where:)
                guard let activity = try await AccessSupabase.shared.fetchActivityByID(
                    assignment.activityID
                ) else { continue }

                let today          = Date()
                let end            = min(assignment.endDate, today)
                let days           = Calendar.current.dateComponents(
                                         [.day], from: assignment.startDate, to: end
                                     ).day ?? 0
                let totalExpected  = max(1, (days + 1) * assignment.frequency)
                let totalCompleted = allLogs.filter {
                    $0.assignedID == assignment.assignedID
                }.count
                let ratio = min(Float(totalCompleted) / Float(totalExpected), 1.0)

                let rowView = buildActivityRow(
                    activity:       activity,
                    totalCompleted: totalCompleted,
                    totalExpected:  totalExpected,
                    ratio:          ratio
                )

                // UI updates must be on main thread
                DispatchQueue.main.async {
                    self.stackView.addArrangedSubview(rowView)

                    if index < activeAssignments.count - 1 {
                        let divider             = UIView()
                        divider.backgroundColor = UIColor.separator
                        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                        self.stackView.addArrangedSubview(divider)
                    }
                }
            }

        } catch {
            print("SummaryActivityTableViewCell configure error:", error)
        }
    }

    private func buildActivityRow(activity: Activity,
                                   totalCompleted: Int,
                                   totalExpected: Int,
                                   ratio: Float) -> UIView {

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iconView   = UIImageView(image: UIImage(systemName: activity.iconName,
                                                    withConfiguration: iconConfig))
        iconView.tintColor    = .systemBlue
        iconView.contentMode  = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28)
        ])

        let titleLabel       = UILabel()
        titleLabel.text      = activity.name
        titleLabel.font      = UIFont.preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label

        let percentLabel     = UILabel()
        percentLabel.text    = "\(Int(ratio * 100))%"
        percentLabel.font    = UIFont.preferredFont(forTextStyle: .headline)
        percentLabel.textColor = .systemBlue
        percentLabel.setContentHuggingPriority(.required, for: .horizontal)

        let titleRow          = UIStackView(arrangedSubviews: [iconView, titleLabel, percentLabel])
        titleRow.axis         = .horizontal
        titleRow.spacing      = 10
        titleRow.alignment    = .center
        titleRow.distribution = .fill

        let progress               = UIProgressView(progressViewStyle: .default)
        progress.progress          = ratio
        progress.progressTintColor = .systemBlue
        progress.trackTintColor    = UIColor.systemGray5
        progress.transform         = progress.transform.scaledBy(x: 1, y: 2)
        progress.layer.cornerRadius = 3
        progress.clipsToBounds      = true

        let sessionLabel       = UILabel()
        sessionLabel.text      = "\(totalCompleted) of \(totalExpected) sessions done"
        sessionLabel.font      = UIFont.preferredFont(forTextStyle: .footnote)
        sessionLabel.textColor = .secondaryLabel
        let vertical     = UIStackView(arrangedSubviews: [titleRow, progress, sessionLabel])
        vertical.axis    = .vertical
        vertical.spacing = 8

        return vertical
    }
    
}
