//
//  GMGridViewLayoutVerticalDynamicHeightStrategy.h
//  GMGridView
//
//  Created by Robert Biehl on 10.08.12.
//  Copyright (c) 2012 Fashionfreax GmbH. All rights reserved.
//

#import "GMGridViewLayoutStrategies.h"

#import "GMDynamicGridViewDataSource.h"

@interface GMGridViewLayoutVerticalDynamicHeightStrategy : GMGridViewLayoutStrategyBase<GMGridViewLayoutStrategy>{
    __unsafe_unretained NSObject<GMDynamicGridViewDataSource>* _dataSource;
    
    NSInteger _numberOfColumns;
    
    float _maxContentHeight;
    float* _yOriginCache;
    float _maxItemHeight;
}

@property (unsafe_unretained, nonatomic, readwrite) NSObject<GMDynamicGridViewDataSource>* dynamicHeightDataSource;
@property (assign, nonatomic, readwrite) NSInteger numberOfColumns;

@end