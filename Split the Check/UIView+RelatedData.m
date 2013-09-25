//
//  UIView+RelatedData.m
//  Split the Check
//
//  Created by Gautham Badhrinathan on 9/10/13.
//  Copyright (c) 2013 Gautham Badhrinathan. All rights reserved.
//

#import "UIView+RelatedData.h"
#import <objc/runtime.h>

static char const * const relatedDataKey = "relatedData";

@implementation UIView (RelatedData)

- (id)relatedData
{
    return objc_getAssociatedObject(self, relatedDataKey);
}

- (void)setRelatedData:(id)relatedData
{
    objc_setAssociatedObject(self, relatedDataKey, relatedData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
