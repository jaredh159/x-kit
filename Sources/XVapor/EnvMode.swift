import Vapor

public extension Environment {
  enum Mode: Equatable {
    case prod
    case dev
    case staging
    case test

    public init(from env: Environment) {
      switch env.name {
      case "production":
        self = .prod
      case "development":
        self = .dev
      case "staging":
        self = .staging
      case "testing":
        self = .test
      default:
        fatalError("Unexpected environment: \(env.name)")
      }
    }

    public var name: String {
      switch self {
      case .prod:
        return "production"
      case .dev:
        return "development"
      case .staging:
        return "staging"
      case .test:
        return "testing"
      }
    }
  }
}
