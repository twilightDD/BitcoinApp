//
//  ViewController.m
//  BitcoinApp
//
//  Created by Peter Hauke on 12.03.17.
//  Copyright © 2017 2sox / Peter Hauke. All rights reserved.
//

#import "MacViewController.h"

#import "SOXMarket_BitcoinDE_Core.h"
@interface MacViewController ()

@property (strong, nonatomic) NSDictionary *serverAnswerDictionary;

@end



@implementation MacViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear {
    [super viewWillAppear];
    
    [self askServerForServerCommand:BitcoinDE_ShowAccountInfoCommandType];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (void)askServerForServerCommand:(BitcoinDE_ServerCommandType)serverCommandType {
    NSURLRequest *request = [SOXMarket_BitcoinDE_Core urlRequestForServerCommandType:serverCommandType];
    
    
    NSURLSessionTask *getTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    NSError *jsonError;
                                                                    self.serverAnswerDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                  options:0
                                                                                                                                    error:&jsonError ];
                                                                    NSLog(@"completionHandler");
                                                                    NSLog(@"Data: %@", [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]);
                                                                    NSLog(@"JSON: %@", self.serverAnswerDictionary);
                                                                    NSLog(@"response: %@", response);
                                                                    NSLog(@"error: %@", error);
                                                                    NSLog(@"jsonError: %@", jsonError);
                                                                    
                                                                    
                                                                    [self performSelectorOnMainThread:@selector(report:)
                                                                                           withObject:self.serverAnswerDictionary
                                                                                        waitUntilDone:YES];
                                                                    
                                                                }];
    
    [getTask resume];
}

- (void)report:(NSDictionary *)serverAnswerDictionary {
//    _serverAnswerDictionary = serverAnswerDictionary;
    

        __block NSString *outputString = @"";
        
        [serverAnswerDictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *_Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]] &&
                [(NSDictionary *)obj allValues].count > 0) {
                outputString = [outputString stringByAppendingString:key];
                outputString = [outputString stringByAppendingString:@"\n"];
                
                outputString = [outputString stringByAppendingString:[self outputOfDictionary:obj intendLevel:0]];
            }
            else {
                outputString = [outputString stringByAppendingString:key];
                outputString = [outputString stringByAppendingString:[NSString stringWithFormat:@"  %@", obj]];
                outputString = [outputString stringByAppendingString:@"\n"];
            }
            
            outputString = [outputString stringByAppendingString:@"\n-----------------------------------\n"];
        }];
        
        //        self.outputTextView.string = outputString;
        //        [self.outputTextView displayIfNeeded];
    
}

- (NSString *)outputOfDictionary:(NSDictionary *)dict intendLevel:(int)intendLevel {
    __block NSString *outputString = @"";
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString  *_Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *intendString = @"";
        for (int a = 0; a < intendLevel*5; a ++) {
            intendString = [intendString stringByAppendingString:@" "];
        }
        outputString = [outputString stringByAppendingString:intendString];
        outputString = [outputString stringByAppendingString:key];
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            outputString = [outputString stringByAppendingString:@"\n"];
            outputString = [outputString stringByAppendingString:[self outputOfDictionary:obj intendLevel:0]];
        }
        else {
            outputString = [outputString stringByAppendingString:[NSString stringWithFormat:@"  %@", obj]];
        }
        outputString = [outputString stringByAppendingString:@"\n"];
    }];
    
    return [outputString copy];
}

@end
