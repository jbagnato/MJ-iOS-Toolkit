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

@protocol MJTaskDispatcherObserver;

/**
 * A MJTaskDispatcher is an object that stores multiple task keys and once those are finished, notifies the observers.
 * This class is thread-safe.
 **/
@interface MJTaskDispatcher : NSObject

/** *************************************************** **
 * @name Handling tasks
 ** *************************************************** **/

/**
* The number of pending tasks.
* @return The number of pending tasks.
**/
- (NSUInteger)count;

/**
 * Defines a task start.
 * @param key   The key of the task that is starting. Cannot be nil.
 **/
- (void)startTaskWithKey:(NSString*)key;

/**
 * Mark a task as successfully completed.
 * @param key       The key of the task to complete.
 * @param object    An associated object to the completed task.
 **/
- (void)completedTaskWithKey:(NSString*)key object:(id)object;

/**
 * Mark a task as completed with failure.
 * @param key       The key of the task to complete.
 * @param object    An associated object to the completed task.
 **/
- (void)failedTaskWithKey:(NSString*)key object:(id)object;

/**
 * Mark all pending tasks as completed.
 **/
- (void)completeAllPendingTasks;

/**
 * Mark all pending tasks as completed.
 * @param object The associated object for the completed tasks.
 **/
- (void)completeAllPendingTasksWithObject:(id)object;

/**
 * Mark all pending tasks as failed.
 **/
- (void)failAllPendingTasks;

/**
 * Mark all pending tasks as failed.
 * @param object The associated object for the failed tasks.
 **/
- (void)failAllPendingTasksWithObject:(id)object;

/** *************************************************** **
 * @name Observation
 ** *************************************************** **/

/**
 * Ads an observer.
 * @param observer An observer.
 **/
- (void)addObserver:(id <MJTaskDispatcherObserver>)observer;

/**
 * Removes an observer.
 * @param observer An observer.
 **/
- (void)removeObserver:(id <MJTaskDispatcherObserver>)observer;

@end

/**
 * The observer object protocol.
 **/
@protocol MJTaskDispatcherObserver <NSObject>

@optional
/**
 * Method called when all tasks have completed. 
 * @param dispatcher The dispatcher object.
 * @param tasks A dictionary containing the task keys and the associated objects.
 **/
- (void)dispatcher:(MJTaskDispatcher*)dispatcher didCompleteTasks:(NSSet*)completedTasks failedTasks:(NSSet*)failedTasks objects:(NSDictionary*)objects;

@end