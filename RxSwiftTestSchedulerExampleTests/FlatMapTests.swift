//
//  FlatMapTests.swift
//  RxSwiftTestSchedulerExample
//
//  Created by kumapo on 2015/12/20.
//  Copyright © 2015年 kumapo. All rights reserved.
//

import XCTest
import RxSwift
@testable import RxSwiftTestSchedulerExample

class FlatMapTests: RxTest {
    let disposeBag = DisposeBag()

    func test_flatMap1() {
        let scheduler = TestScheduler(initialClock: 0)
        let xerror = NSError(domain: "x", code: 1, userInfo: nil) as ErrorType
        let xs = scheduler.createColdObservable([
            next(100, 1),
            error(200, xerror)
            ])
        let ys = scheduler.createColdObservable([
            next(99, "a"),
            completed(101)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(1) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.messages, [
            next(200, "a"),
            error(201, xerror)
            ])
    }
    
    func test_flatMap2() {
        let scheduler = TestScheduler(initialClock: 0)
        let xerror = NSError(domain: "x", code: 1, userInfo: nil) as ErrorType
        let xs = scheduler.createColdObservable([
            next(100, 1),
            error(200, xerror)
            ])
        let yerror: ErrorType = NSError(domain: "y", code: 1, userInfo: nil) as ErrorType
        let ys = scheduler.createColdObservable([
            error(1, yerror),
            next(1000, "z")
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(1) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.messages, [
            error(102, yerror)
            ])
    }
    
    func test_flatMap3() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createColdObservable([
            next(100, 1),
            completed(101)
            ])
        let ys = scheduler.createColdObservable([
            next(100, "a"),
            completed(200)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(1) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.messages, [
            next(201, "a"),
            completed(301)
            ])
    }
}