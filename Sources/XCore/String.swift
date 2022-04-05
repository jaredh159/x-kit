import Foundation

public extension String {
  var snakeCased: String {
    return processCamelCaseRegex(pattern: acronymPattern)?
      .processCamelCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
  }

  var shoutyCased: String {
    snakeCased.uppercased()
  }

  func padLeft(toLength: Int, withPad: String) -> String {
    String(
      String(reversed())
        .padding(toLength: toLength, withPad: withPad, startingAt: 0)
        .reversed()
    )
  }

  private func processCamelCaseRegex(pattern: String) -> String? {
    let regex = try? NSRegularExpression(pattern: pattern, options: [])
    let range = NSRange(location: 0, length: count)
    return regex?.stringByReplacingMatches(
      in: self,
      options: [],
      range: range,
      withTemplate: "$1_$2"
    )
  }
}

private let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
private let normalPattern = "([a-z0-9])([A-Z])"
