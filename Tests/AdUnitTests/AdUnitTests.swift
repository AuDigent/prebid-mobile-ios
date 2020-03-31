/*   Copyright 2018-2019 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest
@testable import PrebidMobile

class AdUnitTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.

        Targeting.shared.clearUserKeywords()
    }

    func testFetchDemand() {
        //given
        let exception = expectation(description: "\(#function)")
        let testObject: AnyObject = () as AnyObject
        var result: ResultCode?
        
        let expected = ResultCode.prebidDemandFetchSuccess
        let adUnit: AdUnit = AdUnit.shared
        AdUnit.testScenario = expected
        
        //when
        adUnit.fetchDemand(adObject: testObject) { (resultCode: ResultCode) in
            result = resultCode
            exception.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        //then
        XCTAssertEqual(expected, result)
    }

    func testSetAutoRefreshMillis() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        
        //then
        XCTAssertNotNil(adUnit.dispatcher)
    }

    func testSetAutoRefreshMillisSmall() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 29_000)
        
        //then
        XCTAssertNil(adUnit.dispatcher)
    }
    
    func testStopAutoRefresh() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.setAutoRefreshMillis(time: 30_000)
        adUnit.stopDispatcher()
        
        //then
        XCTAssertNil(adUnit.dispatcher)
    }
    
    // MARK: - DEPRECATED adunit user keywords (user.keywords)
    func testAddUserKeyword() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeyword(key: "key2", value: "value2")
        let userKeywords = Targeting.shared.getUserKeywordsSet()
        
        //then
        XCTAssertEqual(2, userKeywords.count)
        XCTAssert(userKeywords.contains("value2") && userKeywords.contains("value1"))
    }

    func testAddUserKeywordSameValue() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeyword(key: "key2", value: "value1")
        let userKeywords = Targeting.shared.getUserKeywordsSet()
        
        //then
        XCTAssertEqual(1, userKeywords.count)
        XCTAssert(userKeywords.contains("value1"))
    }
    
    func testAddUserKeywords() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        let set: Set = ["value1", "value2"]
        
        //when
        adUnit.addUserKeywords(key: "key2", value: set)
        let userKeywords = Targeting.shared.getUserKeywordsSet()
        
        //then
        XCTAssertEqual(2, userKeywords.count)
        XCTAssert(userKeywords.contains("value2") && userKeywords.contains("value1"))
    }
    
    func testClearUserKeywords() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeyword(key: "key2", value: "value2")
        
        //when
        adUnit.clearUserKeywords()
        let userKeywords = Targeting.shared.getUserKeywordsSet()
        
        //then
        XCTAssertEqual(0, userKeywords.count)
    }

    func testRemoveUserKeyword() {
        //given
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addUserKeyword(key: "key1", value: "value1")
        adUnit.addUserKeyword(key: "key2", value: "value2")
        
        //when
        adUnit.removeUserKeyword(forKey: "value1")
        let userKeywords = Targeting.shared.getUserKeywordsSet()
        
        //then
        XCTAssertEqual(1, userKeywords.count)
        XCTAssert(userKeywords.contains("value2"))
    }
    
    // MARK: - adunit context data aka inventory data (imp[].ext.context.data)
    func testAddContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextData(key: key1, value: value1)
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testUpdateContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let set: Set = [value1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.updateContextData(key: key1, value: set)
        
        //when
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(1, dictionary.count)
        XCTAssertTrue((dictionary[key1]?.contains(value1))!)
    }
    
    func testRemoveContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextData(key: key1, value: value1)
        
        //when
        adUnit.removeContextData(forKey: key1)
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    func testClearContextData() {
        //given
        let key1 = "key1"
        let value1 = "value1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextData(key: key1, value: value1)
        
        //when
        adUnit.clearContextData()
        let dictionary = adUnit.getContextDataDictionary()
        
        //then
        XCTAssertEqual(0, dictionary.count)
    }
    
    // MARK: - adunit context keywords (imp[].ext.context.keywords)
    func testAddContextKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextKeyword(element1)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testAddContextKeywords() {
        //given
        let element1 = "element1"
        let inputSet: Set = [element1]
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        
        //when
        adUnit.addContextKeywords(inputSet)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(1, set.count)
        XCTAssertTrue(set.contains(element1))
    }
    
    func testRemoveContextKeyword() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextKeyword(element1)
        
        //when
        adUnit.removeContextKeyword(element1)
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
    
    func testClearContextKeywords() {
        //given
        let element1 = "element1"
        let adUnit = BannerAdUnit(configId: "1001-1", size: CGSize(width: 300, height: 250))
        adUnit.addContextKeyword(element1)
        
        //when
        adUnit.clearContextKeywords()
        let set = adUnit.getContextKeywordsSet()
        
        //then
        XCTAssertEqual(0, set.count)
    }
}
