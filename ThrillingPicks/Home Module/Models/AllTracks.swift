//
//  AllTracks.swift
//  ThrillingPicks
//
//  Created by iOSDev on 5/30/19.
//  Copyright © 2019 iOSDeveloper. All rights reserved.
//

import UIKit

// MARK: - Tracks
struct Tracks: Codable {
    let today, tomorrow: [Today]?
    let recentPicks: [RecentPick]?
    
    enum CodingKeys: String, CodingKey {
        case today, tomorrow
        case recentPicks = "recent_picks"
    }
}

// MARK: - Today
struct Today: Codable {
    let trackName, trackRaceIsGuestAvailable: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case trackName = "track_name"
        case trackRaceIsGuestAvailable = "track_race_is_guest_available"
        case id
    }
}

// MARK: - RecentPick
struct RecentPick: Codable {
    let id: Int?
    let trackRaceDateTime, trackRaceRecentShow, trackRacePaidAmount, trackRaceBetType: String?
    let trackName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case trackRaceDateTime = "track_race_date_time"
        case trackRaceRecentShow = "track_race_recent_show"
        case trackRacePaidAmount = "track_race_paid_amount"
        case trackRaceBetType = "track_race_bet_type"
        case trackName = "track_name"
    }
}
