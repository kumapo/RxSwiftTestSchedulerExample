//
//  Created by kumapo on 2015/10/23.
//  Copyright © 2015年 kumapo. All rights reserved.
//

import RxSwift

enum State: Int {
    case Empty = 0
    case InProgress
    case Success
    case Error
}

class ViewModel: NSObject {

    
    var state: Variable<State> = Variable(.Empty)
    var disposeBag = DisposeBag()
    var client: Fetchable {
        return RestfulClient.sharedInstance
    }
    
    func load() -> Observable<Int> {
        self.state.value = .InProgress
        return client
            .fetch()
            .doOn(
                onNext: { [unowned self] (_) in
                    self.state.value = .Success
                },
                onError: { [unowned self] (_) in
                    self.state.value = .Error
                })
    }
}