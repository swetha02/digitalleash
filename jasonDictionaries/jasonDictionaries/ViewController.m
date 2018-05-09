//
//  ViewController.m
//  jasonDictionaries
//
//  Created by swetha on 3/27/18.
//  Copyright © 2018 big nerd ranch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSString *jsonString1 = @"{\"ID\":{\"Content\":268,\"type\":\"text\"},\"ContractTemplateID\":{\"Content\":65,\"type\":\"text\"}}";
    NSData *data1 = [jsonString1 dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:nil];

    
    NSMutableDictionary *contentDictionary = [[NSMutableDictionary alloc]init];
    [contentDictionary setValue:@"abc" forKey:@"user_name"];
    [contentDictionary setValue:@"12.1223" forKey:@"latitude"];
    [contentDictionary setValue:@"145.40404" forKey:@"longitude"];
    NSData * data = [NSJSONSerialization dataWithJSONObject:contentDictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString ;
    
    
    
    
    NSError *error;
    if(data)
    {
        jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    else {
        NSLog(@"Got an error: %@", error);
        jsonString = @"";
    }
    NSLog(@"Your JSON String is %@", jsonString);
    
    
//https://turntotech.firebaseio.com/digitalleash/5555.json
   

    
   // [self downloadJson];
    [self uploadJson];
    

    /*
     
     // step by step
     data = download(url)
     // we have the data
     print data
     
     download(url)
     // next line - we don't have the data
     // we data in completion handler block
     
    */
    
    
}


-(void) downloadJson {
    
    NSURL *jasonUrl = [NSURL URLWithString:@"https://turntotech.firebaseio.com/digitalleash/5555.json"];
    
    
    NSURLSessionDataTask *downloadData = [[NSURLSession sharedSession] dataTaskWithURL:jasonUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            
            NSData *data1 = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data1 options:0 error:nil];
            
            
            NSLog(@" data %@", [json objectForKey:@"user_name"]);
            NSLog(@" response %@", response);
        } else {
            NSLog(@" Error %@", [error localizedDescription]);
        }
    }];
    
    [downloadData resume];
}



-(void) uploadJson {
    
    // 1
    NSURL *url = [NSURL URLWithString:@"https://turntotech.firebaseio.com/digitalleash/swetha.json"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"PUT"; // POST or PUT or PATCH
    
    // 3
    NSDictionary *dictionary = @{@"latitude": @10.34,@"longitude": @11.34,@"radius": @12.34};
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:kNilOptions error:&error];
    
    if (!error) {
        // 4
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                                   fromData:data completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                                                       // Handle response here
                                                                   }];
        
        // 5
        [uploadTask resume];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
