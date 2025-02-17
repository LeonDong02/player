import Foundation
import XCTest
@testable import PlayerUI

class StageRevertDataPluginTests: XCTestCase {
    let json = """
    {
      "id": "minimal",
      "views": [
        {
          "id": "view-1",
          "type": "text",
          "value": "{{name}}"
        },
        {
          "id": "view-2",
          "type": "text",
          "value": "{{name}}"
        },
        {
          "id": "view-3",
          "type": "text",
          "value": "{{name}}"
        }
      ],
      "navigation": {
        "BEGIN": "FLOW_1",
        "FLOW_1": {
          "VIEW_1": {
            "ref": "view-1",
            "state_type": "VIEW",
            "transitions": {
              "clear": "VIEW_3",
              "commit": "VIEW_2",
              "*": "END_Done"
            },
            "attributes": {
              "stageData": true,
              "commitTransitions": ["VIEW_2"]
            }
          },
          "VIEW_2": {
            "ref": "view-2",
            "state_type": "VIEW",
            "transitions": {
              "*": "END_Done"
            }
          },
          "VIEW_3": {
            "ref": "view-3",
            "state_type": "VIEW",
            "transitions": {
              "*": "END_Done"
            }
          },
          "startState": "VIEW_1"
        }
      },
      "data": {
        "name": "default"
      }
    }
    """
    func testStageRevertDataPluginStagesData() {
        let expected = XCTestExpectation(description: "data did not change")
        let player = HeadlessPlayerImpl(plugins: [PrintLoggerPlugin(level: .trace), StageRevertDataPlugin()])

        player.hooks?.viewController.tap { viewController in
            viewController.hooks.view.tap { view in
                guard view.id == "view-3" else {
                    (player.state as? InProgressState)?.controllers?.data.set(transaction: ["name": "Test"])
                    (player.state as? InProgressState)?.controllers?.flow.transition(with: "clear")
                    return
                }
                view.hooks.onUpdate.tap { value in
                    let labelValue = value.objectForKeyedSubscript("value").toString()

                    XCTAssertEqual(labelValue, "default")
                    expected.fulfill()
                }
            }
        }

        player.start(flow: json, completion: {_ in})
        wait(for: [expected], timeout: 1)
    }

    func testStageRevertDataPluginCommitsData() {
        let expected = XCTestExpectation(description: "data did not change")
        let player = HeadlessPlayerImpl(plugins: [PrintLoggerPlugin(level: .trace), StageRevertDataPlugin()])

        player.hooks?.viewController.tap { viewController in
            viewController.hooks.view.tap { view in
                guard view.id == "view-2" else {
                    (player.state as? InProgressState)?.controllers?.data.set(transaction: ["name": "Test"])
                    (player.state as? InProgressState)?.controllers?.flow.transition(with: "commit")
                    return
                }
                view.hooks.onUpdate.tap { value in
                    let labelValue = value.objectForKeyedSubscript("value").toString()

                    XCTAssertEqual(labelValue, "Test")
                    expected.fulfill()
                }
            }
        }

        player.start(flow: json, completion: {_ in})
        wait(for: [expected], timeout: 1)
    }
}
