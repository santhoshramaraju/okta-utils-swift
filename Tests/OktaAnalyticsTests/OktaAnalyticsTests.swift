/*
 * Copyright (c) 2020-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import XCTest
@testable import OktaAnalytics
import OktaLogger
import AppCenterAnalytics

class OktaAnalyticsTests: XCTestCase {

    override class func setUp() {
        let appCenterAnalyticsProvider: AnalyticsProviderProtocol = {
            let logger = OktaLogger()
            logger.addDestination(
                OktaLoggerConsoleLogger(
                    identifier: "com.okta.loggerDemo.console",
                    level: OktaLoggerLogLevel.debug,
                    defaultProperties: nil
                )
            )
            let appCenterAnalyticsProvider = AppCenterAnalyticsProvider(name: "AppCenter", logger: logger)
            appCenterAnalyticsProvider.start(withAppSecret: "App Secret", services: [AppCenterAnalytics.Analytics.self])
            return appCenterAnalyticsProvider
        }()
        OktaAnalytics.initializeStorageWith(securityAppGroupIdentifier: "")
        OktaAnalytics.addProvider(appCenterAnalyticsProvider)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testScenario() throws {
        let count = 30
        var insertExpectations = [XCTestExpectation]()
        var deleteExpectations = [XCTestExpectation]()
        for i in 0..<count {
            insertExpectations.append(XCTestExpectation(description: "\(i)"))
            deleteExpectations.append(XCTestExpectation(description: "\(i)"))
        }

        DispatchQueue.concurrentPerform(iterations: count) { index in
            var scenarioID = ""

            OktaAnalytics.startScenario(ScenarioEvent(name: "Test \(index)", displayName: " \(index)")) {
                scenarioID = $0 ?? ""
            }
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test1", value: "1")])
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test2", value: "2")])
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test3", value: "3")])

            Thread.sleep(forTimeInterval: 0.5)
            OktaAnalytics.getScenarioEventByID(scenarioID) {
                XCTAssertNotNil($0)
                insertExpectations[index].fulfill()
            }

            OktaAnalytics.endScenario(scenarioID, eventDisplayName: "Test\(index)")

            Thread.sleep(forTimeInterval: 0.5)
            OktaAnalytics.getScenarioEventByID(scenarioID) {
                XCTAssertNil($0)
                deleteExpectations[index].fulfill()
            }
        }

        wait(for: insertExpectations + deleteExpectations, timeout: 20)
    }

    func testScenarioWithScenarioIDFromClient() throws {
        let count = 30
        var insertExpectations = [XCTestExpectation]()
        var deleteExpectations = [XCTestExpectation]()
        for i in 0..<count {
            insertExpectations.append(XCTestExpectation(description: "\(i)"))
            deleteExpectations.append(XCTestExpectation(description: "\(i)"))
        }

        DispatchQueue.concurrentPerform(iterations: count) { index in
            var scenarioID = ""

            OktaAnalytics.startScenario(ScenarioEvent(scenarioID: UUID().uuidString, name: "Test \(index)", displayName: " \(index)")) {
                scenarioID = $0 ?? ""
            }
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test1", value: "1")])
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test2", value: "2")])
            OktaAnalytics.updateScenario(scenarioID, [Property(key: "Test3", value: "3")])

            Thread.sleep(forTimeInterval: 0.5)
            OktaAnalytics.getScenarioEventByID(scenarioID) {
                XCTAssertNotNil($0)
                insertExpectations[index].fulfill()
            }

            OktaAnalytics.endScenario(scenarioID, eventDisplayName: "Test\(index)")

            Thread.sleep(forTimeInterval: 0.5)
            OktaAnalytics.getScenarioEventByID(scenarioID) {
                XCTAssertNil($0)
                deleteExpectations[index].fulfill()
            }
        }

        wait(for: insertExpectations + deleteExpectations, timeout: 40)
    }

    override class func tearDown() {
        OktaAnalytics.disposeAll()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
