//
//  RecentWins.swift
//  ThrillingPicks
//
//  Created by iOSDev on 6/5/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

// MARK: - Recent Win
struct Winning: Codable {
    let id: Int?
    let dateOfResult: String?
    let trackID: Int?
    let raceNumber, betType, selection, betTotal: String?
    let amountWon, raceConditions, createdAt, updatedAt: String?
    let winningStatus, trackName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case dateOfResult = "date_of_result"
        case trackID = "track_id"
        case raceNumber = "race_number"
        case betType = "bet_type"
        case selection
        case betTotal = "bet_total"
        case amountWon = "amount_won"
        case raceConditions = "race_conditions"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case winningStatus = "winning_status"
        case trackName = "track_name"
    }
}
