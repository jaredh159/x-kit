import Vapor
import XCTVapor

@testable import GraphQLKit

public enum ExpectedError {
  case withStatus(HTTPStatus)
  case matching(String)
}

public enum ExpectedData {
  case exactlyMatches(String) // match
  case contains(String)
  case containsAll([String])
  case containsAllUUIDs([UUID]) // containsUUIDs
  case isExactJson(String) // exactJson
  case containsJson(String)
  case containsKeyValuePairs([String: Any]) // containsKVPs
}

enum Expectation {
  case success(ExpectedData)
  case error(ExpectedError)
}

public enum Auth {
  case bearer(String)
}

public func assertGraphQLResponse(
  to operation: String,
  path: String = "/graphql",
  auth: Auth? = nil,
  addingHeaders headers: [HTTPHeaders.Name: String]? = nil,
  withInput input: Map? = nil,
  on application: Application,
  _ expectedData: ExpectedData,
  file: StaticString = #file,
  line: UInt = #line
) {
  _assertGraphQLResponse(
    to: operation,
    path: path,
    auth: auth,
    addingHeaders: headers,
    withVariables: input.map { ["input": $0] },
    matchesExpectation: .success(expectedData),
    on: application,
    file: file,
    line: line
  )
}

public func assertGraphQLResponse(
  to operation: String,
  path: String = "/graphql",
  auth: Auth? = nil,
  addingHeaders headers: [HTTPHeaders.Name: String]? = nil,
  withVariables variables: [String: Map]? = nil,
  on application: Application,
  _ expectedData: ExpectedData,
  file: StaticString = #file,
  line: UInt = #line
) {
  _assertGraphQLResponse(
    to: operation,
    path: path,
    auth: auth,
    addingHeaders: headers,
    withVariables: variables,
    matchesExpectation: .success(expectedData),
    on: application,
    file: file,
    line: line
  )
}

public func assertGraphQLResponse(
  to operation: String,
  path: String = "/graphql",
  auth: Auth? = nil,
  addingHeaders headers: [HTTPHeaders.Name: String]? = nil,
  withInput input: Map? = nil,
  on application: Application,
  isError expectedError: ExpectedError,
  file: StaticString = #file,
  line: UInt = #line
) {
  _assertGraphQLResponse(
    to: operation,
    path: path,
    auth: auth,
    addingHeaders: headers,
    withVariables: input.map { ["input": $0] },
    matchesExpectation: .error(expectedError),
    on: application,
    file: file,
    line: line
  )
}

public func assertGraphQLResponse(
  to operation: String,
  path: String = "/graphql",
  auth: Auth? = nil,
  addingHeaders headers: [HTTPHeaders.Name: String]? = nil,
  withVariables variables: [String: Map]? = nil,
  on application: Application,
  isError expectedError: ExpectedError,
  file: StaticString = #file,
  line: UInt = #line
) {
  _assertGraphQLResponse(
    to: operation,
    path: path,
    auth: auth,
    addingHeaders: headers,
    withVariables: variables,
    matchesExpectation: .error(expectedError),
    on: application,
    file: file,
    line: line
  )
}

func _assertGraphQLResponse(
  to operation: String,
  path: String = "/graphql",
  auth: Auth? = nil,
  addingHeaders headers: [HTTPHeaders.Name: String]? = nil,
  withVariables variables: [String: Map]? = nil,
  matchesExpectation expectation: Expectation,
  on app: Application,
  file: StaticString = #file,
  line: UInt = #line
) {
  let queryRequest = QueryRequest(query: operation, operationName: nil, variables: variables)
  let data = String(data: try! JSONEncoder().encode(queryRequest), encoding: .utf8)!

  var body = ByteBufferAllocator().buffer(capacity: 0)
  body.writeString(data)

  var reqHeaders = HTTPHeaders()
  reqHeaders.contentType = .json
  reqHeaders.add(name: .contentLength, value: body.readableBytes.description)

  if let headers = headers {
    for (name, value) in headers {
      reqHeaders.add(name: name, value: value)
    }
  }

  switch auth {
  case .bearer(let token):
    reqHeaders.add(name: .authorization, value: "Bearer " + token)
  case nil:
    break
  }

  try! app.testable().test(.POST, path, headers: reqHeaders, body: body) {
    var res = $0
    let rawResponse = res.body.readString(length: res.body.readableBytes)

    switch expectation {

    case .success(let expectedData):
      XCTAssertEqual(res.status, .ok)
      switch expectedData {
      case .exactlyMatches(let exact):
        XCTAssertEqual(rawResponse, exact)
      case .contains(let substring):
        XCTAssertContains(rawResponse, substring)
      case .containsAllUUIDs(let uuids):
        for uuid in uuids {
          XCTAssertContains(rawResponse?.lowercased(), uuid.uuidString.lowercased())
        }
      case .containsAll(let substrings):
        for substring in substrings {
          XCTAssertContains(rawResponse, substring)
        }
      case .containsJson(let json):
        XCTAssertContains(rawResponse, jsonCondense(json))
      case .isExactJson(let json):
        XCTAssertEqual(rawResponse, #"{"data":\#(jsonCondense(json))}"#)
      case .containsKeyValuePairs(let pairs):
        for (key, value) in pairs {
          switch value {
          case let map as GraphQL.Map:
            switch map.typeDescription {
            case "string":
              XCTAssertContains(rawResponse, "\"\(key)\":\"\(try! map.stringValue())\"")
            case "bool":
              XCTAssertContains(rawResponse, "\"\(key)\":\(try! map.boolValue())")
            case "number":
              XCTAssertContains(rawResponse, "\"\(key)\":\(try! map.intValue())")
            default:
              XCTAssertContains(rawResponse, "\"\(key)\":\"\(String(describing: map))\"")
            }
          case let bool as Bool:
            XCTAssertContains(rawResponse, "\"\(key)\":\(bool)")
          case let float as Float:
            XCTAssertContains(rawResponse, "\"\(key)\":\(float)")
          case let int as Int:
            XCTAssertContains(rawResponse, "\"\(key)\":\(int)")
          default:
            XCTAssertContains(rawResponse, "\"\(key)\":\"\(String(describing: value))\"")
          }
        }
      }

    case .error(let expectedError):
      switch expectedError {
      case .withStatus(let status):
        XCTAssertContains(rawResponse, #""errors":[{"#)
        XCTAssertContains(rawResponse, "\(status.code)")
      case .matching(let needle):
        XCTAssertContains(rawResponse, needle)
      }
    }
  }
}

private func jsonCondense(_ json: String) -> String {
  return json.split(separator: "\n")
    .map { $0.trimmingCharacters(in: .whitespaces) }
    .joined()
    .replacingOccurrences(of: "\": ", with: "\":")
}
