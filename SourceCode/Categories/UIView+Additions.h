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
#import <UIKit/UIKit.h>

/**
 * Find subviews inside a view.
 **/
@interface UIView (Additions)

/** ************************************************************ **
 * @name UIResponder support
 ** ************************************************************ **/

/**
 * Returns the next UITextField or UITextView located in the next UITableViewCells on a same UITableView section.
 * @return A candidate to next first responder.
 * @discussion The receiver view must be located inside a table view cell, and the cell must be located inside a table view.
 **/
- (nullable __kindof UIView*)add_nextFirstResponder;

/** ************************************************************ **
 * @name Finding Subviews
 ** ************************************************************ **/

/**
 * Return a subview with the given accessibility identifier.
 * @param identifier The accessibility identifier.
 * @return The subview that matches the passed arguments.
 **/
- (nullable __kindof UIView*)add_subviewWithAccessibilityIdentifier:(nonnull NSString*)identifier;

/**
 * Return a subview with the given tag.
 * @param tag The tag.
 * @return The subview that matches the passed arguments.
 **/
- (nullable __kindof UIView*)add_subviewWithTag:(NSInteger)tag;

/**
 * Return a subview with the given a class.
 * @param clazz The class.
 * @return The subview that matches the passed arguments.
 **/
- (nullable __kindof UIView*)add_subviewOfClass:(nonnull Class)clazz;


/**
 * Return a subview with that passes the given test.
 * @param testBlock The test block
 * @return The subview that matches the passed arguments.
 **/
- (nullable __kindof UIView*)add_subviewPassingTest:(BOOL (^_Nonnull)(UIView * _Nonnull view))testBlock;

/**
 * Return all subviews that passes the given test.
 * @param testBlock The test block
 * @return An array with the subview that matches the passed arguments.
 **/
- (nonnull NSArray<__kindof UIView*>*)add_subviewsPassingTest:(BOOL (^_Nonnull)(UIView * _Nonnull view))testBlock;

/**
 * Return all subviews of all subviews of all subviews...
 * @return An array with all views in the subtree of views form the receiver.
 **/
- (nonnull NSArray<__kindof UIView*>*)add_allSubivews;

@end
