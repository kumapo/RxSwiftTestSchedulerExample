//
//  TakeUntilTests.swift
//  RxSwiftTestSchedulerExample
//
//  Created by kumapo on 2016/02/17.
//  Copyright © 2016年 kumapo. All rights reserved.
//

import XCTest
import RxSwift
import RxTests
@testable import RxSwiftTestSchedulerExample

class TakeUntilTests : XCTestCase {
    let disposeBag = DisposeBag()
    
    func test_takeUntil1() {
        let scheduler = TestScheduler(initialClock: 0)
        let empty = scheduler.createColdObservable([
            completed(100),  // empty
            next(101, "(never emits)")
            ])
        let first = Observable<String>
            .never()
            .takeUntil(empty)
        
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            first.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [])
    }
    func test_takeUntil2() {
        let scheduler = TestScheduler(initialClock: 0)
        let just = scheduler.createColdObservable([
            next(100, "just"),
            completed(101)
            ])
        let first = Observable<String>
            .never()
            .takeUntil(just)
        
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            first.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            completed(100)
            ])
    }
}
