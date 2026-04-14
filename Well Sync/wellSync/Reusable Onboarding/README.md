# Reusable Onboarding

This folder now contains the onboarding used at app launch.

It is built mainly with storyboard components and a small UIKit controller for:

- page switching
- shared onboarding data
- skip / continue behavior

Files:

- `WellSyncOnboarding.storyboard`
- `WellSyncOnboardingViewController.swift`

The app launch flow is already wired through `SceneDelegate`, so running the app will show this onboarding first.
