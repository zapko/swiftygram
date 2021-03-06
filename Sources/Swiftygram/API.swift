//
// Created by Zap on 07.08.2018.
//

import Foundation


protocol API {
    func send<T: Decodable>(request: URLRequest, onComplete: @escaping (Result<T>) -> Void)
}

private struct Response<T: Decodable>: Decodable {
    let ok:          Bool
    let result:      T?
    let description: String?
    let errorCode:   Int?
}


final internal class APIClient: API {


    // MARK: - Private properties

    private let session: URLSession

    private let decoder: JSONDecoder = {

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return decoder
    }()


    // MARK: - Initialization / Deinitialization

    init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }


    // MARK: - API

    func send<T: Decodable>(request: URLRequest, onComplete: @escaping (Result<T>) -> Void) {

        let task = session.dataTask(with: request) {
            [decoder]
            (possibleData, possibleResponse, possibleError) in

            Result.action(handler: onComplete) {

                if let error = possibleError { throw error }

                guard let data = possibleData else { throw APIError("Missing data") }

                let response = try decoder.decode(Response<T>.self, from: data)

                guard let result = response.result else {
                    throw APIError(text: response.description, code: response.errorCode)
                }

                return result
            }
        }

        task.resume()
    }
}