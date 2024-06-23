//
//  ContentView.swift
//  WeatherApp
//
//  Created by Ryan S on 6/22/24.
//

import SwiftUI


struct ContentView: View {
    
    
    @State private var results = [ForecastDay]()
    @State var backgroundColor = Color.init(red: 37/255, green: 150/255, blue: 190/255)
    @State var weatherEmoji = "☀️"
    @State var currentTemp = 0
    @State var conditionText = "Slightly Overcast"
    @State var cityName = "Huntington Beach"
    @State var loading = true
    @State var hourlyForecast = [Hour]()
    @State var query: String = ""
    @State var contentSize: CGSize = .zero
    @State var textFieldHeight = 15.0
    var body: some View {
        if loading{
            ZStack {
                Color.init(backgroundColor)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(2, anchor: .center)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .task {
                        do {
                            try await fetchWeather(query: query)
                        } catch {
                            print("error")
                        }
                    }
            }
        } else {
            
            
            VStack {
                Spacer()
                TextField("Enter city or zipcode", text: $query, onEditingChanged: getFocus)
                    .textFieldStyle(PlainTextFieldStyle())
                    .background(
                        Rectangle()
                            .foregroundColor(.white.opacity(0.2))
                            .cornerRadius(25)
                            .frame(height: 50)
                    )
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, textFieldHeight)
                    .padding(.bottom, 15)
                    .multilineTextAlignment(.center)
                    .font(Font.system(size: 20))
                    .onSubmit {
                        Task {
                            try await fetchWeather(query: query)
                        }
                        withAnimation {
                            textFieldHeight = 15
                        }
                    }
                
                Text(cityName)
                    .font(.system(size: 35))
                    .bold()
                Text("\(Date().formatted(date: .complete, time: .omitted))")
                    .font(.system(size: 18))
                Text(weatherEmoji)
                    .font(.system(size: 130))
                    .shadow(radius: 75)
                Text("\(currentTemp)°C")
                    .font(.system(size: 60))
                    .bold()
                Text("\(conditionText)")
                    .font(.system(size: 22))
                Spacer()
                Text("Hourly Forecast")
                    .font(.system(size: 17))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 2)
                    .bold()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Spacer()
                        ForEach(hourlyForecast) { forcast in
                            VStack{
                                Text("\(getShortTime(time: forcast.time))")
                                    .shadow(color:.black.opacity(0.2), radius: 1, x: 0, y: 0)
                                Text("\(getWeatherEmoji(code: forcast.condition.code))")
                                    .frame(width: 50, height: 14)
                                    .shadow(color:.black.opacity(0.2), radius: 1, x: 0, y: 0)
                                Text("\(Int(forcast.temp_c))°C")
                                    .shadow(color:.black.opacity(0.2), radius: 1, x: 0, y: 0)
                            }
                            .frame(width: 50, height: 90)
                        }
                        Spacer()
                    }
                    .background(Color.white.blur(radius: 75).opacity(0.35))
                    .cornerRadius(15)
                }
                .padding()
                Spacer()
                Text("3 Day Forcast")
                    .font(.system(size: 17))
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 2)
                    .bold()
                List (results){ forecast in
                    HStack(alignment: .center, spacing: nil) {
                        Text("\(getShortDate(epoch: forecast.date_epoch))")
                            .frame(maxWidth: 50, alignment: .leading)
                            .bold()
                        Text("\(getWeatherEmoji(code: forecast.day.condition.code))")
                            .frame(maxWidth: 30, alignment: .leading)
                        Text("\(Int(forecast.day.avgtemp_c))°C")
                            .frame(maxWidth: 50, alignment: .leading)
                        Spacer()
                        Text("\(forecast.day.condition.text)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .listRowBackground(Color.white.blur(radius: 70).opacity(0.5))
                    
                }
                .contentMargins(.vertical, 0)
                .scrollContentBackground(.hidden)
                .preferredColorScheme(.dark)
                Spacer()
                Text("Data from weatherapi.com")
                    .font(.system(size: 14))
            }
            .background(backgroundColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .task {
                do {
                    try await fetchWeather(query: query)
                } catch {
                    print("error calling in task")
                }
            }
        }
        
    }
    func getFocus(focused: Bool) {
        withAnimation {
            textFieldHeight = 130
        }
    }
    
    func fetchWeather(query: String) async throws {
        var endpoint = "http://api.weatherapi.com/v1/forecast.json?key=[key]&q=Jamaica&days=3&aqi=no&alerts=no"
        
        if (query != "") {
            endpoint = "http://api.weatherapi.com/v1/forecast.json?key=[key]&q=\(query)&days=3&aqi=no&alerts=no"
        }

        
        guard let url = URL(string: endpoint)
        else {
            print("Invalid URL")
            return
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(Weather.self, from: data)
        cityName = decodedResponse.location.name
        results = decodedResponse.forecast.forecastday
        currentTemp = Int(results[0].day.avgtemp_c)
        backgroundColor = getBackgroundColor(code: results[0].day.condition.code)
        weatherEmoji = getWeatherEmoji(code: results[0].day.condition.code)
        conditionText = results[0].day.condition.text
        hourlyForecast = results[0].hour
        loading = false
        
        
    }

    
    
}

#Preview {
    ContentView()
}
