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

#import <Foundation/Foundation.h>

#import "MJTaskDispatcher.h"

@class MJInteractor;

typedef NS_ENUM(NSUInteger, MJInteractorType)
{
    MJInteractorTypeSharedQueue,
    MJInteractorTypeClassQueue,
    MJInteractorTypeInstanceQueue,
};

/**
 * Convenience method to execute a background block in an interactor.
 **/
extern void MJInteractorBackground(MJInteractor *interactor, void (^block)());

/**
 * Convenience method to execute a foreground block in an interactor.
 **/
extern void MJInteractorForeground(MJInteractor *interactor, void (^block)());

/**
 * Interactor superclass
 **/
@interface MJInteractor : NSObject <MJTaskDispatcherObserver>

/** ************************************************************ **
 * @name Initializers
 ** ************************************************************ **/

/**
 * Default initializer.
 * @param type The interactor type.
 * @return The initialized instance.
 **/
- (id)initWithType:(MJInteractorType)type;

/** ************************************************************ **
 * @name Properties
 ** ************************************************************ **/

/**
 * The interactor type.
 **/
@property (nonatomic, assign, readonly) MJInteractorType type;

/**
 * The interactor's task dispatcher.
 **/
@property (nonatomic, strong, readonly) MJTaskDispatcher *taskDispatcher;

/** ************************************************************ **
 * @name Methods
 ** ************************************************************ **/

/**
 * Executes a block in a background thread.
 * @discussion A `background` call must be in corresponded to a `foreground` call.
 **/
- (void)background:(void (^)())block;

/**
 * Executes a block in a foreground thread.
 * @discussion A `background` call must be in corresponded to a `foreground` call.
 **/
- (void)foreground:(void (^)())block;

@end
