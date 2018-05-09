//
//  ViewController.m
//  childApp
//
//  Created by swetha on 3/28/18.
//  Copyright © 2018 big nerd ranch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property NSString *latitude;
@property NSString *longitude;
- (IBAction)reportLocation:(id)sender;

@end

@implementation ViewController{
    CLLocationManager *location;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _userTextField.text = @"swe";
    
    location =[[CLLocationManager alloc]init];
    location.delegate = self;
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)reportLocation:(id)sender {
    
    

    location.desiredAccuracy = kCLLocationAccuracyBest;
    if([location respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [location requestWhenInUseAuthorization];
        [location startUpdatingLocation];
        
    }


}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"did fail with error  %@",error);
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"error" message:@"failed to get current location" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *  action) {}];
    
    [errorAlert addAction:defaultAction];
    [self presentViewController:errorAlert animated:YES completion:nil];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)updateLocation
{
    NSLog(@"did update to location %@",updateLocation);
    CLLocation *currentLocation = updateLocation[0];
    if(currentLocation!=nil)
    {
        NSLog(@" current location %@",currentLocation);
        
        _longitude =[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        _latitude = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        
        [self uploadJason];
        
        NSMutableDictionary *Dictionary = [[NSMutableDictionary alloc]init];
        
        [Dictionary setValue:_latitude forKey:@"latitude"];
        [Dictionary setValue:_longitude forKey:@"longitude"];
        [Dictionary setValue:[_userTextField text] forKey:@"userName"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Dictionary options:NSJSONWritingPrettyPrinted error:nil];
        NSError *error;
        NSString *jsonString;
        if (jsonData) {
            jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            //This is your JSON String
            //NSUTF8StringEncoding encodes special characters using an escaping scheme
        } else {
            NSLog(@"Got an error: %@", error);
            jsonString = @"";
        }
        NSLog(@"Your JSON String is %@", jsonString);
        
        
        [location stopUpdatingLocation];
        
        
    }
    
}

-(void)uploadJason{
    
    
    NSString * urlString;
    urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json",_userTextField.text];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"PATCH"; // POST or PUT or PATCH

    // 3
    NSDictionary *dictionary = @{@"child_latitude":_latitude ,@"child_longitude" :_longitude};
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

    
    
    
    
    
    
    
    
    
    
    
















//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Dictionary // Here you can pass array or dictionary
//                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
//                                                         error:&error];






@end
