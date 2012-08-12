//
//  GMDynamicGridViewDataSource.h
//  Fashionfreax
//
//  Created by Robert Biehl on 10.08.12.
//  Copyright (c) 2012 Fashionfreax GmbH. All rights reserved.
//

#import "GMGridView.h"

@protocol GMDynamicGridViewDataSource <GMGridViewDataSource>

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemAtIndex:(NSInteger)index;

@end
