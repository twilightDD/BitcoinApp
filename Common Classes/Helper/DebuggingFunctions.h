//
//  DebuggingFunctions.h
//
//  Created by Kasprzak Ingo on 15.03.12.
//  Copyright (c) 2012 Silutions. All rights reserved.
//

#import <mach/mach_time.h>  // for mach_absolute_time() and friends

CGFloat timeBlock (void (^block)(void));

/*
 Example:
 
 CGFloat time = timeBlock(^{
	for (int i = 0; i < 1000000; i++) {
		[thing1 isEqualToString: thing2];
	}
 });
 printf ("isEqualToString: time: %f\n", time);
 
*/
