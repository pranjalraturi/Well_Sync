//
//  FeatureOnboardingSequence.swift
//  wellSync
//
//  Created by Codex on 10/04/26.
//

import UIKit

final class FeatureOnboardingSequence {

    private weak var viewController: UIViewController?
    private let storageKey: String
    private let stepsProvider: () -> [FeatureSpotlightStep]

    private var overlay: FeatureSpotlightView?
    private var steps: [FeatureSpotlightStep] = []
    private var currentIndex = 0
    private(set) var hasStarted = false

    init(viewController: UIViewController,
         storageKey: String,
         stepsProvider: @escaping () -> [FeatureSpotlightStep]) {
        self.viewController = viewController
        self.storageKey = storageKey
        self.stepsProvider = stepsProvider
    }

    func startIfNeeded() {
        guard !hasStarted else { return }
        guard FeatureOnboardingStore.shouldShow(for: storageKey) else { return }
        guard let viewController else { return }
        guard viewController.isViewLoaded, viewController.view.window != nil else { return }

        let configuredSteps = stepsProvider()
        guard !configuredSteps.isEmpty else { return }

        hasStarted = true
        steps = configuredSteps
        currentIndex = 0

        let hostView = viewController.tabBarController?.view ?? viewController.navigationController?.view ?? viewController.view!
        let overlay = FeatureSpotlightView(frame: hostView.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.configureSteps(count: configuredSteps.count)
        overlay.onTap = { [weak self] in
            self?.advance()
        }

        hostView.addSubview(overlay)
        self.overlay = overlay

        showCurrentStep()
    }

    private func advance() {
        currentIndex += 1
        if currentIndex >= steps.count {
            finish()
            return
        }
        showCurrentStep()
    }

    private func showCurrentStep() {
        guard let overlay else { return }

        showStep(at: currentIndex, in: overlay)
    }

    private func showStep(at index: Int, in overlay: FeatureSpotlightView) {
        guard index < steps.count else {
            finish()
            return
        }

        let step = steps[index]
        step.prepare?()

        DispatchQueue.main.async { [weak self, weak overlay] in
            guard let self, let overlay else { return }

            guard step.targetProvider() != nil else {
                self.currentIndex += 1
                self.showStep(at: self.currentIndex, in: overlay)
                return
            }

            overlay.display(step: step, at: index, total: self.steps.count, inside: overlay)
        }
    }

    private func finish() {
        FeatureOnboardingStore.markSeen(for: storageKey)
        UIView.animate(withDuration: 0.2, animations: {
            self.overlay?.alpha = 0
        }, completion: { _ in
            self.overlay?.removeFromSuperview()
            self.overlay = nil
        })
    }
}
