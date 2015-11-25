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


#import "MJInteractor.h"

static dispatch_queue_t _sharedQueue;
static NSMutableDictionary *_interactorDispatchQueues;

void MJInteractorBackground(MJInteractor *interactor, void (^block)())
{
    [interactor background:^{
        block();
    }];
}

void MJInteractorForeground(MJInteractor *interactor, void (^block)())
{
    [interactor foreground:^{
        block();
    }];
}

@implementation MJInteractor
{
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
}

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _interactorDispatchQueues = [[NSMutableDictionary alloc] init];
        _sharedQueue = dispatch_queue_create("com.mobilejazz.interactor.shared", DISPATCH_QUEUE_SERIAL);
    });
}

- (id)init
{
    return [self initWithType:MJInteractorTypeInstanceQueue];
}

- (id)initWithType:(MJInteractorType)type
{
    self = [super init];
    if (self)
    {
        // Setting type
        _type = type;
        
        // Setting task dispatcher
        _taskDispatcher = [[MJTaskDispatcher alloc] init];
        [_taskDispatcher addObserver:self];
        
        // Setting queue
        
        if (_type == MJInteractorTypeClassQueue)
        {
            NSString * const className = NSStringFromClass(self.class);
            
            @synchronized(_interactorDispatchQueues)
            {
                dispatch_queue_t queue = _interactorDispatchQueues[className];
                if (!queue)
                {
                    NSString * name = [NSString stringWithFormat:@"com.mobilejazz.interactor.class.%@", className];
                    queue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
                    _interactorDispatchQueues[className] = queue;
                }
                
                _queue = queue;
            }
        }
        else if (_type == MJInteractorTypeSharedQueue)
        {
            _queue = _sharedQueue;
        }
        else //if (_type == MJInteractorTypeInstanceQueue)
        {
            NSString *name = [NSString stringWithFormat:@"com.mobilejazz.interactor.instance.%x", (int)self];
            _queue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        }
    }
    return self;
}

- (void)background:(void (^)())block
{
    dispatch_async(_queue, ^{
        _semaphore = dispatch_semaphore_create(0);
        block();
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)foreground:(void (^)())block
{
    if ([NSThread isMainThread])
    {
        block();
        if (self.taskDispatcher.count == 0 && _semaphore != NULL)
            dispatch_semaphore_signal(_semaphore);
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
            if (self.taskDispatcher.count == 0 && _semaphore != NULL)
                dispatch_semaphore_signal(_semaphore);
        });
    }
}

@end
