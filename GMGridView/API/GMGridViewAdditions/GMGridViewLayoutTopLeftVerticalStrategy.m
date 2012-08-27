//
//  GMGridViewLayoutTopLeftVerticalStrategy.m
//  Fashionfreax
//
//  Created by Robert Biehl on 23.08.12.
//  Copyright (c) 2012 Fashionfreax GmbH. All rights reserved.
//

#import "GMGridViewLayoutTopLeftVerticalStrategy.h"

@implementation GMGridViewLayoutTopLeftVerticalStrategy

- (void)setEdgeAndContentSizeFromAbsoluteContentSize:(CGSize)actualContentSize
{
    if (self.centeredGrid)
    {
        NSInteger widthSpace, heightSpace;
        NSInteger top, left, bottom, right;
        
        widthSpace  = 0.0;//floor((self.gridBounds.size.width  - actualContentSize.width)  / 2.0);
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


@end
