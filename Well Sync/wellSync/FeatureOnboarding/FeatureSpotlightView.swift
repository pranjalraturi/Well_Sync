//
//  FeatureSpotlightView.swift
//  wellSync
//
//  Created by Codex on 10/04/26.
//

import UIKit

enum FeatureTooltipPlacement {
    case automatic
    case above
    case below
}

struct FeatureSpotlightStep {
    let title: String
    let message: String
    let placement: FeatureTooltipPlacement
    let prepare: (() -> Void)?
    let targetProvider: () -> UIView?

    init(title: String,
         message: String,
         placement: FeatureTooltipPlacement,
         prepare: (() -> Void)? = nil,
         targetProvider: @escaping () -> UIView?) {
        self.title = title
        self.message = message
        self.placement = placement
        self.prepare = prepare
        self.targetProvider = targetProvider
    }
}

final class FeatureSpotlightView: UIView {

    var onTap: (() -> Void)?

    private enum Style {
        static let cornerRadius: CGFloat = 16
        static let tooltipInset: CGFloat = 20
        static let spotlightPadding: CGFloat = 4
        static let dimAlpha: CGFloat = 0.58
        static let accentColor = UIColor(red: 0.33, green: 0.60, blue: 0.98, alpha: 1)
    }

    private let dimView = UIView()
    private let maskLayer = CAShapeLayer()
    private let highlightLayer = CAShapeLayer()

    private let tooltipView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = Style.cornerRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 24
        view.alpha = 0
        return view
    }()

    private let accentBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Style.accentColor
        view.layer.cornerRadius = 1.5
        return view
    }()

    private let stepLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.textColor = Style.accentColor
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    private let divider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray4
        return view
    }()

    private let progressStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.78)
        label.text = "Tap anywhere to continue"
        return label
    }()

    private var tooltipTopConstraint: NSLayoutConstraint?
    private var tooltipBottomConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear

        dimView.frame = bounds
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.backgroundColor = UIColor.black.withAlphaComponent(Style.dimAlpha)
        dimView.layer.mask = maskLayer
        addSubview(dimView)

        highlightLayer.fillColor = UIColor.clear.cgColor
        highlightLayer.strokeColor = UIColor.white.cgColor
        highlightLayer.lineWidth = 4
        layer.addSublayer(highlightLayer)

        tooltipView.addSubview(accentBar)
        tooltipView.addSubview(stepLabel)
        tooltipView.addSubview(titleLabel)
        tooltipView.addSubview(messageLabel)
        tooltipView.addSubview(divider)
        tooltipView.addSubview(progressStack)
        addSubview(tooltipView)
        addSubview(hintLabel)

        tooltipTopConstraint = tooltipView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16)
        tooltipBottomConstraint = tooltipView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32)

        NSLayoutConstraint.activate([
            tooltipView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Style.tooltipInset),
            tooltipView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Style.tooltipInset),

            accentBar.leadingAnchor.constraint(equalTo: tooltipView.leadingAnchor, constant: 16),
            accentBar.topAnchor.constraint(equalTo: tooltipView.topAnchor, constant: 16),
            accentBar.bottomAnchor.constraint(equalTo: tooltipView.bottomAnchor, constant: -16),
            accentBar.widthAnchor.constraint(equalToConstant: 3),

            stepLabel.topAnchor.constraint(equalTo: tooltipView.topAnchor, constant: 16),
            stepLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            stepLabel.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -16),

            titleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            messageLabel.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -16),

            divider.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: accentBar.trailingAnchor, constant: 12),
            divider.trailingAnchor.constraint(equalTo: tooltipView.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),

            progressStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 12),
            progressStack.centerXAnchor.constraint(equalTo: tooltipView.centerXAnchor),
            progressStack.bottomAnchor.constraint(equalTo: tooltipView.bottomAnchor, constant: -14),
            progressStack.heightAnchor.constraint(equalToConstant: 8),

            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    func configureSteps(count: Int) {
        progressStack.arrangedSubviews.forEach { subview in
            progressStack.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        for _ in 0..<count {
            let dot = UIView()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.layer.cornerRadius = 4
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8)
            ])
            progressStack.addArrangedSubview(dot)
        }
    }

    func display(step: FeatureSpotlightStep, at index: Int, total: Int, inside overlayView: UIView) {
        guard let targetView = step.targetProvider() else { return }

        layoutIfNeeded()
        overlayView.layoutIfNeeded()

        let targetFrame = targetView.convert(targetView.bounds, to: self)
        let spotlightFrame = targetFrame.insetBy(dx: -Style.spotlightPadding, dy: -Style.spotlightPadding)
        let spotlightPath = UIBezierPath(roundedRect: spotlightFrame, cornerRadius: Style.cornerRadius)
        let fullPath = UIBezierPath(rect: bounds)
        fullPath.append(spotlightPath)
        fullPath.usesEvenOddFillRule = true

        maskLayer.frame = bounds
        maskLayer.path = fullPath.cgPath
        maskLayer.fillRule = .evenOdd

        highlightLayer.path = spotlightPath.cgPath

        stepLabel.text = "STEP \(index + 1) OF \(total)"
        titleLabel.text = step.title
        messageLabel.text = step.message

        for (dotIndex, dot) in progressStack.arrangedSubviews.enumerated() {
            dot.backgroundColor = dotIndex == index ? Style.accentColor : UIColor.systemGray4
            dot.alpha = dotIndex == index ? 1 : 0.7
        }

        tooltipTopConstraint?.isActive = false
        tooltipBottomConstraint?.isActive = false

        let desiredWidth = bounds.width - (Style.tooltipInset * 2)
        let tooltipSize = tooltipView.systemLayoutSizeFitting(
            CGSize(width: desiredWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let spaceBelow = bounds.maxY - targetFrame.maxY - 80
        let spaceAbove = targetFrame.minY - safeAreaInsets.top - 20

        let useBelow: Bool
        switch step.placement {
        case .below:
            useBelow = true
        case .above:
            useBelow = false
        case .automatic:
            useBelow = spaceBelow >= tooltipSize.height || spaceBelow >= spaceAbove
        }

        if useBelow {
            tooltipTopConstraint = tooltipView.topAnchor.constraint(equalTo: topAnchor, constant: min(targetFrame.maxY + 18, bounds.height - tooltipSize.height - 40))
            tooltipTopConstraint?.isActive = true
        } else {
            tooltipBottomConstraint = tooltipView.bottomAnchor.constraint(equalTo: topAnchor, constant: max(targetFrame.minY - 18, tooltipSize.height + safeAreaInsets.top + 12))
            tooltipBottomConstraint?.isActive = true
        }

        layoutIfNeeded()

        UIView.animate(withDuration: 0.22) {
            self.tooltipView.alpha = 1
            self.hintLabel.alpha = 1
        }
    }

    @objc private func handleTap() {
        onTap?()
    }
}
