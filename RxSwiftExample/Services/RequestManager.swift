//
//  RequestManager.swift
//  RxSwiftExample
//
//  Created by Johnny Yen on 2020/6/26.
//  Copyright © 2020 Test. All rights reserved.
//

import Foundation
import RxSwift

enum HttpMethod: String {
    case get
    case put
    case post
    case patch
    case delete
}

class RequestManager {

    struct Entity {
        private var values = [String: String]()

        mutating func add(key: String, value: String) {
            values[key] = value
        }

        func value(for key: String) -> String? {
            return values[key]
        }

        func allValues() -> [String: String] {
            return values
        }

        func count() -> Int {
            return values.count
        }
    }

    struct Response {
        var response: HTTPURLResponse?
        var httpStatusCode = 0
        var headers = Entity()

        init(_ response: URLResponse?) {
            guard let response = response as? HTTPURLResponse else { return }
            self.response = response
            httpStatusCode = response.statusCode

            for (key, value) in response.allHeaderFields {
                headers.add(key: "\(key)", value: "\(value)")
            }
        }
    }

    struct Results {
        var data: Data?
        var response: Response?
        var error: Error?

        init(data: Data?, response: Response?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }

        init(error: Error?) {
            self.error = error
        }
    }

    enum Errors {
        case createRequest
    }

    var requestHttpHeaders = Entity()
    var queryParam = Entity()
    var httpBodyParam = Entity()

    private func addQueryParam(to url: URL) -> URL {
        var resultUrl = url
        if queryParam.count() > 0,
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            var queryItems = [URLQueryItem]()

            for (key, value) in queryParam.allValues() {
                let item = URLQueryItem(name: key, value: value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
                queryItems.append(item)
            }

            urlComponents.queryItems = queryItems
            if let queryUrl = urlComponents.url {
                resultUrl = queryUrl
            }
        }
        return resultUrl
    }

    func request(urlString: String, completion: @escaping (_ result: Results) -> Void) {
        if let url = URL(string: urlString) {
            let targetURL = self.addQueryParam(to: url)
            let task = URLSession.shared.dataTask(with: targetURL) {(data, response, error) in

                let resp = Response(response)
                let results = Results(data: data, response: resp, error: error)
                DispatchQueue.main.async {
                    completion(results)
                }
            }

            task.resume()
        } else {
            completion(Results(error: Errors.createRequest))
        }
    }
}

extension RequestManager.Errors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .createRequest: return "Create request failed"
        }
    }
}
