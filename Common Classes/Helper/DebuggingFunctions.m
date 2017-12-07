//
//  DebuggingFunctions.m
//
//  Created by Kasprzak Ingo on 15.03.12.
//  Copyright (c) 2012 Silutions. All rights reserved.
//

#import "DebuggingFunctions.h"

CGFloat timeBlock (void (^block)(void)) {
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) return -1;
	
    uint64_t start = mach_absolute_time ();
    block ();
    uint64_t end = mach_absolute_time ();
    uint64_t elapsed = end - start;
	
    uint64_t nanos = elapsed * info.numer / info.denom;
    return (CGFloat)nanos / NSEC_PER_SEC;
	
}
