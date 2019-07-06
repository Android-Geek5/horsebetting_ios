//
//  Race.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

// MARK: - Race
struct Race: Codable {
    let id, trackID: Int?
    let trackRaceDateTime, trackRaceNumber, trackRaceHorseNumber, trackRaceHorseName: String?
    let trackRaceDescription, trackRaceIsGuestAvailable, trackRaceBetType, trackRacePaidAmount: String?
    let trackRaceRecentShow, trackRaceStatus, createdAt, updatedAt: String?
    let trackName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackID = "track_id"
        case trackRaceDateTime = "track_race_date_time"
        case trackRaceNumber = "track_race_number"
        case trackRaceHorseNumber = "track_race_horse_number"
        case trackRaceHorseName = "track_race_horse_name"
        case trackRaceDescription = "track_race_description"
        case trackRaceIsGuestAvailable = "track_race_is_guest_available"
        case trackRaceBetType = "track_race_bet_type"
        case trackRacePaidAmount = "track_race_paid_amount"
        case trackRaceRecentShow = "track_race_recent_show"
        case trackRaceStatus = "track_race_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case trackName = "track_name"
    }
}
