import Foundation

enum BundleJSONLoaderError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Missing bundled JSON file: \(filename)"
        }
    }
}

struct BundleJSONLoader {
    func load<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
        guard let url = Bundle.main.url(
            forResource: filename,
            withExtension: "json",
            subdirectory: "MockJSON"
        ) else {
            throw BundleJSONLoaderError.fileNotFound(filename)
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }
}

