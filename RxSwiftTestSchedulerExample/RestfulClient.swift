//
//  Created by kumapo on 2015/09/23.
//  Copyright © 2015年 kumapo. All rights reserved.
//

import RxSwift

protocol Fetchable {
    func fetch() -> Observable<Int>
}

public class RestfulClient: Fetchable {
    struct RestfulError: ErrorType { }

    public static let sharedInstance = RestfulClient.init()
    private static let endpoint = "http://www.google.com/search?q=RxSwift"
    
    var session: NSURLSession

    private init() {
        let sessionConfiguration: NSURLSessionConfiguration =
        NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 30.0
        sessionConfiguration.timeoutIntervalForResource = 30.0
        sessionConfiguration.HTTPAdditionalHeaders = [
            "Accept": "application/json",
            "Content-type": "application/json" //"CONTENT_TYPE" results in 422
        ]
        session = NSURLSession.init(configuration: sessionConfiguration)        
    }
    
    public func fetch() -> Observable<Int> {
        let subject: Observable<Int> = Observable.create { [unowned self] observer in
            let url     = NSURL.init(string: RestfulClient.endpoint)
            let request = NSURLRequest.init(URL: url!)
            let task = self.session.dataTaskWithRequest(request) { (_, response, err) in
                if let response = response as? NSHTTPURLResponse {
                    dispatch_async(dispatch_get_main_queue(), {
                        observer.on(.Next(response.statusCode))
                        observer.on(.Completed)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        observer.on(.Error(RestfulError()))
                    })
                }
            }
            task.resume()
            return AnonymousDisposable {
                task.cancel()
            }
        }
        return subject
    }
 }
