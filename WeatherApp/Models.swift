//
//  Models.swift
//  WeatherApp
//
//  Created by Ryan S on 6/22/24.
//

import Foundation

struct Weather: Codable {
    var location: Location
    var forecast: Forecast
}

struct Location: Codable {
    var name: String
}

struct Forecast: Codable {
    var forecastday: [ForecastDay]
}

struct ForecastDay: Codable, Identifiable {
    var date_epoch: Int
    var id: Int { date_epoch }
    var day: Day
    var hour: [Hour]
}

struct Day: Codable {
    var avgtemp_c: Double
    var condition: Condition
}

struct Condition: Codable {
    var text: String
    var code: Int
}

struct Hour: Codable, Identifiable {
    var time_epoch: Int
    var id: Int { time_epoch }
    var time: String
    var temp_c: Double
    var condition: Condition
    
}

