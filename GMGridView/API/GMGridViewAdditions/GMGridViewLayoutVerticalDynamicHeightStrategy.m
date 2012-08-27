//
//  GMGridViewLayoutVerticalDynamicHeightStrategy.m
//  GMGridView
//
//  Created by Robert Biehl on 10.08.12.
//  Copyright (c) 2012 Fashionfreax GmbH. All rights reserved.
//

#import "GMGridViewLayoutVerticalDynamicHeightStrategy.h"

@implementation GMGridViewLayoutVerticalDynamicHeightStrategy

@synthesize dynamicHeightDataSource = _dataSource, numberOfColumns = _numberOfColumns;

+ (BOOL)requiresEnablingPaging{
    return NO;
}

- (id)init{
    if ((self = [super init]))
    {
        _type = GMGridViewLayoutVerticalDynamicHeight;
        _yOriginCache = (float *)malloc(1 * sizeof(float));
    }
    
    return self;
}

- (void) dealloc{
    free(_yOriginCache);
}

- (void)rebaseWithItemCount:(NSInteger)count insideOfBounds:(CGRect)bounds{
    if (count <= 0) {
        return;
    }
    _itemCount  = count;
    _gridBounds = bounds;
    
    free(_yOriginCache);
    _yOriginCache = (float *)malloc(_itemCount * sizeof(float));
    for (NSUInteger i = 0; i < _itemCount; i++) {
        _yOriginCache[i] = -1.0;
    }

    _maxItemHeight = 0.0;
    _maxContentHeight = 0.0;
    
    CGRect actualBounds = CGRectMake(0,
                                     0,
                                     bounds.size.width  - self.minEdgeInsets.right - self.minEdgeInsets.left,
                                     bounds.size.height - self.minEdgeInsets.top   - self.minEdgeInsets.bottom);
    
    _numberOfColumns = 1;
    while ((self.numberOfColumns + 1) * (self.itemSize.width + self.itemSpacing) - self.itemSpacing < actualBounds.size.width){
        _numberOfColumns++;
    }
    
    CGPoint lastOrigin = [self originForItemAtPosition:count-1];
//    CGSize actualContentSize = CGSizeMake(ceil(MIN(self.itemCount, self.numberOfColumns) * (self.itemSize.width + self.itemSpacing)) - self.itemSpacing, lastOrigin.y+lastSize.height);
    
    CGSize actualContentSize = CGSizeMake(ceil(MIN(self.itemCount, self.numberOfColumns) * (self.itemSize.width + self.itemSpacing)) - self.itemSpacing, _maxContentHeight);
    
    [self setEdgeAndContentSizeFromAbsoluteContentSize:actualContentSize];
}

- (void)setEdgeAndContentSizeFromAbsoluteContentSize:(CGSize)actualContentSize
{
    if (self.centeredGrid)
    {
        NSInteger widthSpace, heightSpace;
        NSInteger top, left, bottom, right;
        
        widthSpace  = floor((self.gridBounds.size.width  - actualContentSize.width)  / 2.0);
        heightSpace = 0.0;
        
        left   = MAX(widthSpace,  self.minEdgeInsets.left);
        right  = MAX(widthSpace,  self.minEdgeInsets.right);
        top    = MAX(heightSpace, self.minEdgeInsets.top);
        bottom = MAX(heightSpace, self.minEdgeInsets.bottom);
        
        _edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);
    }
    else
    {
        _edgeInsets = self.minEdgeInsets;
    }
    
    _contentSize = CGSizeMake(actualContentSize.width  + self.edgeInsets.left + self.edgeInsets.right,
                              actualContentSize.height + self.edgeInsets.top  + self.edgeInsets.bottom);
}

- (CGPoint)originForItemAtPosition:(NSInteger)position{
    NSUInteger index = position;
    CGPoint origin = CGPointZero;
    
    if (self.numberOfColumns > 0 && position >= 0){
        NSInteger numColumns = self.numberOfColumns;
        NSUInteger col = position % numColumns;
        if (_yOriginCache[index]<0) {
            float itemSpacing = self.itemSpacing;
            float topEdgeInsets = self.edgeInsets.top;
            
            float *columns;
            columns = (float *)malloc(numColumns * sizeof(float));

            for (NSInteger c = 0; c < numColumns; c++) {
                columns[c] = 0.0;
            }
            
            //    NSInteger lowestColumn = 0;
            //    float lowestColumnHeight = 0.0;
            
            NSInteger currentColumn = 0;
            CGSize curSize;
            for (NSInteger i = 0; i < index; i++) {
                _yOriginCache[i] = columns[currentColumn] + topEdgeInsets;
                
                curSize = [self.dynamicHeightDataSource GMGridView:nil sizeForItemAtIndex:i];
                if (curSize.height >_maxItemHeight) {
                    _maxItemHeight = curSize.height;
                }
                
                if ((_yOriginCache[i] + curSize.height) > _maxContentHeight) {
                    _maxContentHeight = (_yOriginCache[i] + curSize.height);
                }
                
                columns[currentColumn] = columns[currentColumn]+curSize.height+itemSpacing;
                
                currentColumn = (currentColumn+1)%numColumns;
            }
            free(columns);
            
        }
        origin = CGPointMake(col * (self.itemSize.width + self.itemSpacing) + self.edgeInsets.left, _yOriginCache[index]);
        
//        NSLog(@"cell(%d) col %d => or=%@ sz=%@", index, col, NSStringFromCGPoint(origin), NSStringFromCGSize([self.dynamicHeightDataSource GMGridView:nil sizeForItemAtIndex:index]));
    }

    
    return origin;
    
//    CGPoint origin = CGPointZero;
//    if (self.numberOfColumns > 0 && position >= 0){
//        NSUInteger col = position % self.numberOfColumns;
//        NSUInteger row = position / self.numberOfColumns;
//        
//        origin = CGPointMake(col * (self.itemSize.width + self.itemSpacing) + self.edgeInsets.left,
//                             row * (self.itemSize.height + self.itemSpacing) + self.edgeInsets.top);
//    }
//    return origin;
}

- (NSInteger)itemPositionFromLocation:(CGPoint)location
{
    CGPoint relativeLocation = CGPointMake(location.x - self.edgeInsets.left,
                                           location.y - self.edgeInsets.top);
    
    int col = (int) (relativeLocation.x / (self.itemSize.width + self.itemSpacing));

    NSInteger firstPosition = -1;
    NSInteger lastPosition  = 0;
    
    float start = location.y-_maxItemHeight;
    float end = location.y;
    
    for (NSUInteger i = 0; i < _itemCount; i++) {
        if (_yOriginCache[i]>start && firstPosition<0) {
            firstPosition = i;
        }
        if (_yOriginCache[i]<end) {
            lastPosition = i;
        }
    }
    lastPosition = MIN(lastPosition, _itemCount-1);
    

    
    NSInteger position = -1;
    for (NSInteger i = firstPosition; i <= lastPosition; i++) {
        CGSize itemSize = [self.dynamicHeightDataSource GMGridView:nil sizeForItemAtIndex:i];
        CGPoint itemOrigin = [self originForItemAtPosition:i];
        CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
        if (CGRectContainsPoint(itemFrame, location))
        {
            position = i;
            break;
        }
    }
    
//    NSLog(@"from %d to %d => %d", firstPosition, lastPosition, position);
    
    // Sanity check
    if (position >= [self itemCount] || position < 0)
    {
        position = GMGV_INVALID_POSITION;
    }
    else
    {
        CGSize itemSize = [self.dynamicHeightDataSource GMGridView:nil sizeForItemAtIndex:position];
        CGPoint itemOrigin = [self originForItemAtPosition:position];
        CGRect itemFrame = CGRectMake(itemOrigin.x, itemOrigin.y, itemSize.width, itemSize.height);
        
        if (!CGRectContainsPoint(itemFrame, location))
        {
            position = GMGV_INVALID_POSITION;
        }
    }
    
    return position;
}

- (NSRange)rangeOfPositionsInBoundsFromOffset:(CGPoint)offset{
    [self originForItemAtPosition:_itemCount-1];
    
    CGPoint contentOffset = CGPointMake(MAX(0, offset.x),
                                        MAX(0, offset.y));
    
    NSInteger firstPosition = -1;
    NSInteger lastPosition  = 0;

    float start = contentOffset.y-_maxItemHeight;
    float end = contentOffset.y+self.gridBounds.size.height+_maxItemHeight;
    
    for (NSUInteger i = 0; i < _itemCount; i++) {
        if (_yOriginCache[i]>start && firstPosition<0) {
            firstPosition = i;
        }
        if (_yOriginCache[i]<end) {
            lastPosition = i;
        }
    }
    
    if (firstPosition<0) {
        firstPosition = 0;
    }
    if (lastPosition<firstPosition) {
        lastPosition = firstPosition;
    }
    
//    NSLog(@"within bounds: %@ - first: %d last: %d", NSStringFromCGPoint(offset), firstPosition, lastPosition);
//    
//    CGFloat itemHeight = self.itemSize.height + self.itemSpacing;
//    
//    CGFloat firstRow = MAX(0, (int)(contentOffset.y / itemHeight) - 1);
//    
//    CGFloat lastRow = ceil((contentOffset.y + self.gridBounds.size.height) / itemHeight);
//    
//    NSInteger firstPosition = firstRow * self.numberOfColumns;
//    NSInteger lastPosition  = ((lastRow + 1) * self.numberOfColumns);
    
    return NSMakeRange(firstPosition, (lastPosition - firstPosition));
}


@end
