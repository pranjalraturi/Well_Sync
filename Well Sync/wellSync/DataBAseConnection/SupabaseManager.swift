//
//  SupabaseManager.swift
//  connectDataBase
//
//  Created by Vidit Agarwal on 05/02/26.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient()
    }
}
