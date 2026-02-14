//
//  supabaseFunctions.swift
//  wellSync
//
//  Created by Vidit Agarwal on 14/02/26.
//

import Supabase
import UIKit

class AccessSupabase{
    
    func saveMood(){
            Task {
                do {
                    print("note saved")
                } catch {
                    print("Saving Error", error)
                }
            }
        }
    func fetchMood(){
        Task{
            do{
                print("note fetched")
            }
            catch{
                print("fetch error: \(error)")
            }
        }
    }
}
