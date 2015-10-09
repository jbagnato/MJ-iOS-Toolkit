//
// Copyright 2014 Mobile Jazz SL
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (UIView*)add_nextFirstResponder
{
    UIView *view = self;
    
    UITableViewCell *cell = nil;
    UITableView *tableView = nil;
    while (view != nil)
    {
        if ([view isKindOfClass:UITableViewCell.class])
            cell = (id)view;
        
        if ([view isKindOfClass:UITableView.class])
            tableView = (id)view;
        
        if (tableView && cell)
            break;
        
        view = view.superview;
    }
    
    if (cell && tableView)
    {
        NSIndexPath *indexPath = [tableView indexPathForCell:cell];
        NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        
        while (nextIndexPath.row < [tableView numberOfRowsInSection:indexPath.section])
        {
            UITableViewCell *nextCell = [tableView cellForRowAtIndexPath:nextIndexPath];
            
            NSMutableArray *subviews = [NSMutableArray array];
            [subviews addObject:nextCell];
            
            while (subviews.count > 0)
            {
                UIView *view = [subviews firstObject];
                [subviews removeObjectAtIndex:0];
                [subviews addObjectsFromArray:view.subviews];
                
                if ([view isKindOfClass:UITextField.class] ||
                    [view isKindOfClass:UITextView.class])
                {
                    if (view.userInteractionEnabled &&
                        [view respondsToSelector:@selector(isEnabled)] &&
                        [(id)view isEnabled])
                    {
                        return view;
                    }
                }
            }
            
            nextIndexPath = [NSIndexPath indexPathForRow:nextIndexPath.row+1 inSection:indexPath.section];
        }
    }
    
    return nil;
}

- (id)add_subviewWithAccessibilityIdentifier:(NSString*)identifier
{
    return [self add_subviewPassingTest:^BOOL(UIView *view) {
        return [view.accessibilityIdentifier isEqualToString:identifier];
    }];
}

- (id)add_subviewWithTag:(NSInteger)tag
{
    return [self add_subviewPassingTest:^BOOL(UIView *view) {
        return view.tag == tag;
    }];
}

- (id)add_subviewOfClass:(Class)clazz
{
    return [self add_subviewPassingTest:^BOOL(UIView *view) {
        return [view isKindOfClass:clazz];
    }];
}

- (id)add_subviewPassingTest:(BOOL (^)(UIView *view))testBlock
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:self];
    
    while (array.count > 0)
    {
        UIView *view = [array firstObject];
        [array removeObjectAtIndex:0];
        
        if (view != self && testBlock(view))
            return view;
        
        [array addObjectsFromArray:view.subviews];
    }
    
    return nil;
}

- (NSArray*)add_subviewsPassingTest:(BOOL (^)(UIView *view))testBlock
{
    NSMutableArray *subviews = [NSMutableArray array];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:self];
    
    while (array.count > 0)
    {
        UIView *view = [array firstObject];
        [array removeObjectAtIndex:0];
        
        if (view != self && testBlock(view))
            [subviews addObject:view];
        
        [array addObjectsFromArray:view.subviews];
    }
    
    return [subviews copy];
}

- (nonnull NSArray<__kindof UIView*>*)add_allSubivews
{
    return [self add_subviewsPassingTest:^BOOL(UIView * _Nonnull view) {
        return YES;
    }];
}

@end
