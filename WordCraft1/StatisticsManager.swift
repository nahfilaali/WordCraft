//
//  StatisticsManager.swift
//  WordCraft1

import UIKit

class StatisticsManager {
    
    static let shared = StatisticsManager()
    private let userDefaults = UserDefaults.standard

    func saveStatistics(_ statistics: GameStatistics1, forSession sessionName: String) {
        do {
            let data = try JSONEncoder().encode(statistics)
            userDefaults.set(data, forKey: sessionName)
            print("Statistics saved for session \(sessionName): \(statistics)") // Log statement
        } catch {
            print("Error saving stats: \(error)")
        }
    }

    func loadStatistics(forSession sessionName: String) -> GameStatistics1? {
        guard let data = userDefaults.data(forKey: sessionName) else { return nil }
        return try? JSONDecoder().decode(GameStatistics1.self, from: data)
    }
}
