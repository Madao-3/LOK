//
//  UsageManager.m
//  LOK
//
//  Created by Madao on 12/30/15.
//  Copyright © 2015 Madao. All rights reserved.
//

#import "UsageManager.h"
#import "LOKFrameCounter.h"
#import <mach/mach.h>
#import <UIKit/UIKit.h>

@implementation UsageManager

+ (NSDictionary *)getUsage {
    return @{
             @"memory_usage" : @(memory_usage()),
             @"cpu_usage"    : @(cpu_usage()),
             @"fps"          : @([LOKFrameCounter shareCounter].fps),
             @"thread_count" : @(getThreadsCount()),
//             @"viewcontroller_path" : [self currentViewControllerPath],
             };
}

+ (NSString *)getUsageJSONString {
    NSDictionary *data = @{@"type":@"usage",@"data":[self getUsage]};
    NSData *jsonData   = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

}


+ (NSString *)currentViewControllerPath {
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *list = @[];
    NSMutableArray *stringList = [@[] mutableCopy];
    for (UIWindow *window in application.windows) {
        NSArray *viewControllers = window.rootViewController.navigationController.viewControllers;
        if (!viewControllers&&list.count==0) {
            list = @[window.rootViewController];
        }
        if (viewControllers.count > list.count) {
            list = window.rootViewController.navigationController.viewControllers;
        }
    }
    for (id view in list) {
        [stringList addObject:NSStringFromClass([view class])];
    }
    return [stringList componentsJoinedByString:@" -> "];
}

float memory_usage() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    } else {
        return 0.0f;
    }
}

float cpu_usage() {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

static int getThreadsCount()
{
    thread_array_t threadList;
    mach_msg_type_number_t threadCount;
    task_t task;
    
    kern_return_t kernReturn = task_for_pid(mach_task_self(), getpid(), &task);
    if (kernReturn != KERN_SUCCESS) {
        return -1;
    }
    
    kernReturn = task_threads(task, &threadList, &threadCount);
    if (kernReturn != KERN_SUCCESS) {
        return -1;
    }
    vm_deallocate (mach_task_self(), (vm_address_t)threadList, threadCount * sizeof(thread_act_t));
    
    return threadCount;
}

@end
