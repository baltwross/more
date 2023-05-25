//
//  MulticastDelegate.swift
//  More
//
//  Created by Igor Ostriz on 14/10/2018.
//  Based on
//  Copyright © 2018 More Technologies. All rights reserved.
//

import Foundation


fileprivate final class Weak<Value: AnyObject> {
    weak var value: Value?
    init(_ value: Value) {
        self.value = value
    }
}

// Subclass NSObject so that obj-c protocols can conform to this on Apple platforms.
class MulticastDelegate<T: AnyObject>: NSObject {
    fileprivate var delegates: [Weak<T>] = []
//    fileprivate var delegates: Set<Weak<T>> = []    // how to conform to 'Hashable'?

    
    public override init() {
        super.init()
    }
    
    // should prevent duplicates: maybe with sets?
    //     fileprivate var delegates: Set<Weak<T>> = []
    func addDelegate(_ delegate: T) {
        self.delegates.append(Weak(delegate))
    }
    
    func removeDelegate(_ delegate: T) {
        guard let index = delegates.index(where: { $0.value === delegate }) else {
            return
        }
        self.delegates.remove(at: index)
    }
    
    fileprivate func clearNilDelegates() {
        for (index, element) in delegates.enumerated().reversed() {
            if element.value == nil {
                delegates.remove(at: index)
            }
        }
    }
}

extension MulticastDelegate: Sequence {
    func makeIterator() -> AnyIterator<T> {
        clearNilDelegates()
        
        var iterator = delegates.makeIterator()
        
        return AnyIterator {
            // loop over the generator's items until we find one that isn't nilled out
            //  and return that as the next item in this generator.
            // Even though we preemptively remove nil delegates before starting,
            //  it's possible something else could cause a delegate to become nil during iteration.
            while let next = iterator.next() {
                if let delegate = next.value {
                    return delegate
                }
            }
            return nil
        }
    }
}


