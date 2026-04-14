////
////  SceneDelegate.swift
////  Project
////
////  Created by Vidit Saran Agarwal on 26/01/26.
////
//
//import UIKit
//
//class SceneDelegate: UIResponder, UIWindowSceneDelegate {
//
//    var window: UIWindow?
//
//
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//    }
//
//    func sceneDidDisconnect(_ scene: UIScene) {
//        // Called as the scene is being released by the system.
//        // This occurs shortly after the scene enters the background, or when its session is discarded.
//        // Release any resources associated with this scene that can be re-created the next time the scene connects.
//        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
//    }
//
//    func sceneDidBecomeActive(_ scene: UIScene) {
//        // Called when the scene has moved from an inactive state to an active state.
//        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
//    }
//
//    func sceneWillResignActive(_ scene: UIScene) {
//        // Called when the scene will move from an active state to an inactive state.
//        // This may occur due to temporary interruptions (ex. an incoming phone call).
//    }
//
//    func sceneWillEnterForeground(_ scene: UIScene) {
//        // Called as the scene transitions from the background to the foreground.
//        // Use this method to undo the changes made on entering the background.
//    }
//
//    func sceneDidEnterBackground(_ scene: UIScene) {
//        // Called as the scene transitions from the foreground to the background.
//        // Use this method to save data, release shared resources, and store enough scene-specific state information
//        // to restore the scene back to its current state.
//    }
//
//
//}
//


//
//  SceneDelegate.swift
//  wellSync
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let hasSeenAppOnboardingKey = "has_seen_app_onboarding"
    private let splashDisplayDuration: TimeInterval = 0.45

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Create the window
        window = UIWindow(windowScene: windowScene)

        showSplashAndRoute()
    }
    
    // MARK: - Session Check on App Launch
    @MainActor
    private func checkAndRestoreSession() async {
        // Step 1: Ask Supabase Auth if there's a valid session token
        guard let authID = await SupabaseManager.shared.getCurrentAuthUserID() else {
            // No valid auth session — stay on login screen
            showLoginScreen()
            return
        }
        
        // Step 2: We have a valid auth token — determine role
        do {
            let role = try await SupabaseManager.shared.resolveRole(authID: authID)
            
            switch role {
            case .doctor:
                let doctor = try await AccessSupabase.shared.fetchDoctorByAuthID(authID)
                SessionManager.shared.currentDoctor = doctor
                SessionManager.shared.saveSession(role: .doctor, doctorID: doctor.docID)
                showDoctorDashboard(doctor: doctor)
                
            case .patient:
                let patient = try await AccessSupabase.shared.fetchPatientByAuthID(authID)
                SessionManager.shared.currentPatient = patient
                SessionManager.shared.saveSession(role: .patient, patientID: patient.patientID)
                showPatientDashboard(patient: patient)
                
            case .none:
                showLoginScreen()
            }
        } catch {
            // Profile not found or network error — go to login
            print("Session restore failed: \(error)")
            showLoginScreen()
        }
    }
    
    private func showSplashAndRoute() {
        let splashStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
        let splashVC = splashStoryboard.instantiateInitialViewController() ?? UIViewController()

        setRootViewController(splashVC, animated: false)
        window?.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now() + splashDisplayDuration) { [weak self] in
            guard let self else { return }

            if self.shouldShowAppOnboarding() {
                self.showOnboardingScreen()
            } else {
                Task {
                    await self.checkAndRestoreSession()
                }
            }
        }
    }

    private func showOnboardingScreen() {
        let storyboard = UIStoryboard(name: "WellSyncOnboarding", bundle: nil)

        guard let onboardingVC = storyboard.instantiateInitialViewController()
                as? WellSyncOnboardingViewController else {
            Task { await checkAndRestoreSession() }
            return
        }

        onboardingVC.onFinish = { [weak self] in
            Task { @MainActor in
                self?.markAppOnboardingSeen()
                await self?.checkAndRestoreSession()
            }
        }

        setRootViewController(onboardingVC, animated: true)
    }
    // MARK: - Navigation Helpers
    private func showLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginVC = storyboard.instantiateViewController(withIdentifier: "login")
        let nav = UINavigationController(rootViewController: loginVC)
        nav.isNavigationBarHidden = true
        
        setRootViewController(nav, animated: true)
    }
    
    func showDoctorDashboard(doctor: Doctor) {
     
            let rootVC = UIStoryboard(name: "DoctorFrontPage", bundle: nil)
                .instantiateViewController(withIdentifier: "doctor")
     
            // The "doctor" storyboard root is usually a UINavigationController.
            // Walk the hierarchy to find HomeCollectionViewController and pass the doctor.
        if let nav = rootVC as? UINavigationController,
                   let home = nav.viewControllers.first as? HomeCollectionViewController {
                    home.doctor = doctor
                }
        setRootViewController(rootVC, animated: true)
        }
    
    func showPatientDashboard(patient: Patient) {
        let storyboard = UIStoryboard(name: "Patient_Dashboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Patient") as! TabBar
        vc.patient = patient
        setRootViewController(vc, animated: true)
    }

    private func shouldShowAppOnboarding() -> Bool {
        !UserDefaults.standard.bool(forKey: hasSeenAppOnboardingKey)
    }

    private func markAppOnboardingSeen() {
        UserDefaults.standard.set(true, forKey: hasSeenAppOnboardingKey)
    }

    private func setRootViewController(_ viewController: UIViewController, animated: Bool) {
        guard let window else { return }

        if animated, window.rootViewController != nil {
            UIView.transition(with: window, duration: 0.35, options: [.transitionCrossDissolve]) {
                let animationsEnabled = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = viewController
                UIView.setAnimationsEnabled(animationsEnabled)
            }
        } else {
            window.rootViewController = viewController
        }
    }

    // Keep the other SceneDelegate methods unchanged below...
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
