//
//  FlatMapTests.swift
//  RxSwiftTestSchedulerExample
//
//  Created by kumapo on 2015/12/20.
//  Copyright © 2015年 kumapo. All rights reserved.
//

import XCTest
import RxSwift
import RxTests
@testable import RxSwiftTestSchedulerExample

class FlatMapTests : XCTestCase {
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
        
        scheduler.scheduleAt(0) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(199, "a"),
            error(200, xerror)
            ])  // never emits y completed
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
            next(10, "z"),
            completed(1000)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            error(101, yerror)
            ])  // never emits x error
    }
    
    func test_flatMap3() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createColdObservable([
            next(100, 1),
            completed(101)
            ])
        let ys = scheduler.createColdObservable([
            next(100, "a"),
            completed(230)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            xs.flatMap { (x) -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(200, "a"),
            completed(330)  // emit y completed
            ])
    }
    
    func test_flatMap4() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(200, 1),
            next(300, 1),
            completed(1000)
            ])
        let ys = scheduler.createColdObservable([
            next(100, "a"),
            next(300, "b"),
            completed(400)
            ])
        let results = scheduler.createObserver(String)
        
        scheduler.scheduleAt(0) {
            xs.flatMap { _ -> Observable<String> in
                return ys.asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(200, "a"),
            next(300, "a"),
            next(400, "b"),
            next(400, "a"),
            next(500, "b"),
            next(600, "b"),
            completed(1000)  // emit y completed
            ])
    }
    
    func test_flatMap5() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(200, 1),
            completed(1000)
            ])
        let results = scheduler.createObserver(String)
        
        var value = ["b", "a"]
        scheduler.scheduleAt(0) {
            xs.flatMap { _ -> Observable<String> in
                return scheduler
                    .createColdObservable(
                        [ next(100, value.popLast()!),
                          completed(101) ])
                    .asObservable()
                }.subscribe(results)
                .addDisposableTo(self.disposeBag)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(200, "a"),
            next(300, "b"),
            completed(1000)  // emit y completed
            ])
    }
    
    func test_flatMap6() {
        let scheduler = TestScheduler(initialClock: 0)
        let xs = scheduler.createColdObservable([
            next(100, 1),
            next(200, 1),
            completed(1000)
            ])
        let ys = scheduler.createColdObservable([
            next(101, 1),
            next(201, 1),
            completed(1000)
            ])
        let results = scheduler.createObserver(String)
        
        var xval = ["b", "a"]
        var yval = ["y", "x"]
        scheduler.scheduleAt(0) {
            let x = xs.flatMap { _ -> Observable<String> in
                return scheduler
                    .createColdObservable(
                        [ next(100, xval.popLast()!),
                          completed(101) ])
                    .asObservable()
                }
            let y = ys.flatMap { _ -> Observable<String> in
                return scheduler
                    .createColdObservable(
                        [ next(100, yval.popLast()!),
                          completed(101) ])
                    .asObservable()
                }
            [x, y]
                .toObservable()
                .merge()
                .subscribe(results)
        }
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(200, "a"),
            next(201, "x"),
            next(300, "b"),
            next(301, "y"),
            completed(1000)  // emit y completed
            ])
    }
}