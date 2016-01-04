//
//  RxSwiftTestSchedulerExampleTests.swift
//  RxSwiftTestSchedulerExampleTests
//
//  Created by kumapo on 2015/12/17.
//  Copyright © 2015年 kumapo. All rights reserved.
//

import XCTest
import RxSwift
import RxTests
@testable import RxSwiftTestSchedulerExample

class RxSwiftTestSchedulerExampleTests {
    
    func test_BehaviorSubject() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            next(940, 11),
            next(1020, 12)
            ])
        
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int)
        var subscription1: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        
        scheduler.scheduleAt(500) { subject.onCompleted() }
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            next(300, 4),
            next(340, 5),
            next(410, 6),
            completed(500)
            ])
    }
    
    func test_BehaviorSubject_ColdObservable() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createColdObservable([
            next(70, 1),
            next(110, 2),
            next(220, 3),
            next(270, 4),
            next(340, 5),
            next(410, 6),
            next(520, 7),
            next(630, 8),
            next(710, 9),
            next(870, 10),
            next(940, 11),
            next(1020, 12)
            ])
        
        var subject: BehaviorSubject<Int>! = nil
        var subscription: Disposable! = nil
        
        let results1 = scheduler.createObserver(Int)
        var subscription1: Disposable! = nil
        
        scheduler.scheduleAt(100) { subject = BehaviorSubject<Int>(value: 100) }
        scheduler.scheduleAt(200) { subscription = xs.subscribe(subject) }
        scheduler.scheduleAt(300) { subscription1 = subject.subscribe(results1) }
        
        scheduler.scheduleAt(500) { subject.onCompleted() }
        scheduler.scheduleAt(600) { subscription1.dispose() }
        scheduler.scheduleAt(1000) { subscription.dispose() }
        
        scheduler.start()
        
        XCTAssertEqual(results1.events, [
            next(300, 1),
            next(310, 2),
            next(420, 3),
            next(470, 4),
            completed(500)
            ])
    }
    
    
    func test_ViewModel() {
        class MockClient: Fetchable {
            let xs: TestableObservable<Int>
            init(scheduler: TestScheduler) {
                xs = scheduler.createColdObservable([
                    next(100, 200)  //200 as OK
                    ])
            }
            func fetch() -> Observable<Int> { return xs.asObservable() }
        }
        class MockViewModel: ViewModel {
            var scheduler: TestScheduler
            init(scheduler: TestScheduler) {
                self.scheduler = scheduler
                super.init()
            }
            override var client: Fetchable { return MockClient(scheduler: scheduler) }
        }
        
        let scheduler = TestScheduler(initialClock: 0)
        let viewModel = MockViewModel(scheduler: scheduler)
        let results     = scheduler.createObserver(State)
        let disposeBag  = DisposeBag()
        
        scheduler.scheduleAt(100) {
            viewModel.state.asObservable().subscribe(results).addDisposableTo(disposeBag) }
        scheduler.scheduleAt(200) {
            _ = viewModel.load().subscribe() }
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            next(100, .Empty),
            next(200, .InProgress),
            next(300, .Success)
            ])
    }
}
