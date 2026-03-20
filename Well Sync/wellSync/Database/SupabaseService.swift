//
//  SupabaseManager.swift
//  wellSync
//
//  Created by Rishika Mittal on 20/03/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient()
    }
}
