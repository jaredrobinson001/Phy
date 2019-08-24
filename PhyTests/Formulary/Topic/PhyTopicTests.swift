//  Created by dasdom on 23.08.19.
//  
//

import XCTest
@testable import Phy

class PhyTopicTests: XCTestCase {

  func test_decode() {
    let topicDict = ["title": "Foo", "json": "json"]
    let data = try! JSONSerialization.data(withJSONObject: topicDict, options: [])
    
    let result = try! JSONDecoder().decode(PhyTopic.self, from: data)
    
    let expected = PhyTopic(title: "Foo", json: "json")
    XCTAssertEqual(expected, result)
  }

}