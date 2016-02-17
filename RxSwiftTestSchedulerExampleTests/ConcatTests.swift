//
//  ConcatTests.swift
//  RxSwiftTestSchedulerExample
//
//  Created by kumapo on 2016/02/12.
//  Copyright © 2016年 kumapo. All rights reserved.
//

import XCTest
import RxSwift
import RxTests
@testable import RxSwiftTestSchedulerExample

class ConcatTests : XCTestCase {
    let disposeBag = DisposeBag()
    
    func test_concat1() {
        let scheduler = TestScheduler(initialClock: 0)
        //isNearTheBottomEdge
        let trigger = scheduler.createColdObservable([
            next(100, "just"),
            completed(101)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            [ Observable.just("appendedRepositories"),
              Observable.never().takeUntil(trigger)]
                .concat()
                .subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(0, "appendedRepositories"),    //isEdge
            completed(100) ])
    }
    func test_concat2() {
        let scheduler = TestScheduler(initialClock: 0)
        //notNearTheBottomEdge
        let trigger = scheduler.createColdObservable([
            completed(100),  // empty
            next(101, "(never emits)")
            ])
        
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            [ Observable.just("appendedRepositories"),
              Observable.never().takeUntil(trigger)]
                .concat()
                .subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(0, "appendedRepositories")] )  //notEdge
    }
    
    func test_concat3() {
        let scheduler = TestScheduler(initialClock: 0)
        let first = scheduler.createColdObservable([
            next(100, "one"),
            next(200, "two"),
            completed(300)
            ])
        let second = scheduler.createColdObservable([
            next(50, "ichi"),
            completed(250)
            ])
        let third = scheduler.createColdObservable([
            next(110, "eins"),
            completed(210)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            [ first, second, third ]
                .concat()
                .subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(100, "one"),
            next(200, "two"),
            next(350, "ichi"),
            next(660, "eins"),
            completed(760)
            ])
    }
}
