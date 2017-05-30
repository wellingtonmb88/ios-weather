//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by WELLINGTON BARBOSA on 30/05/17.
//  Copyright © 2017 WELLINGTON BARBOSA. All rights reserved.
//

import XCTest
@testable import Weather

class ForecastJsonParsingTests: XCTestCase {
    
    var forecastArray: [Forecast]?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let data = JsonFromFileLoader.readJson(fromFile: "WeatherJsonMock")
        
        forecastArray = ForecastMapper().map(data: data! as NSData)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        forecastArray = nil
    }
    
    func testForecastArrayIsNotNil() {
        XCTAssert(forecastArray != nil, "Forecast Array should not be nil")
    }
    
    func testForecastArrayCheckCount() {
        XCTAssert(forecastArray?.count == 10, "Forecast Array should have count equal 10")
    }
    
    func testForecastArrayCheckParse() {
        
        let forecast = forecastArray?[0]
        
        XCTAssert(forecast != nil, "Forecast should not be nil")
        
        XCTAssert(forecast?.date == "30 May 2017", "Forecast's date should be 30 May 2017")
        XCTAssert(forecast?.day == "Tue", "Forecast's day should be Tue")
        XCTAssert(forecast?.high == "18", "Forecast's high should be 18")
        XCTAssert(forecast?.low == "12", "Forecast's low should be 12")
        XCTAssert(forecast?.text == "Mostly Sunny", "Forecast's text should be Mostly Sunny")
        
    }
}
