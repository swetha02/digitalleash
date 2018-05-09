//
//  ViewController.m
//  DigitalLeash
//
//  Created by swetha on 3/19/18.
//  Copyright © 2018 big nerd ranch. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameText;
@property (weak, nonatomic) IBOutlet UITextField *radiusText;
@property (weak, nonatomic) IBOutlet UITextField *longitudeText;
@property (weak, nonatomic) IBOutlet UITextField *latitudeText;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation ViewController
{
    CLLocationManager *location;
}

- (void)viewDidLoad

{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //_btnCreate.backgroundColor = [UIColor greenColor];
    location = [[CLLocationManager alloc]init];
    
//    _userNameText.text = @"swetha";
    _userNameText.textColor = [UIColor redColor];
    
    location.delegate = self;
    
    [_errorLabel setHidden:YES];
}


- (BOOL)isTextFieldCorrect:(UITextField *)textField

{
    if([textField hasText])
    {
        //-180 .. 180  -12.45645
        NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"-.0123456789"];
        NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString: textField.text];
        
        BOOL stringIsValid = [numbersOnly isSupersetOfSet: characterSetFromTextField];
        if (stringIsValid){
            NSLog(@"YI lat and lon is correct");
            [_errorLabel setHidden:YES];
        } else {
            NSLog(@"YI lat and lon is wrong");
            [_errorLabel setHidden:NO];
            [_errorLabel setText:@" error :zone must be numeric value"];
        }
        return stringIsValid;
    }
    NSLog(@"YI text field is empty");
    [_errorLabel setHidden:NO];
    [_errorLabel setText:@" error :empty"];
    return NO;
    
    
    
}

- (IBAction)createTouched:(UIButton *)sender {
    
    NSLog(@"createTouched clicked");
//    [self performSegueWithIdentifier:@"SegueGood" sender:nil];
    
    if([_userNameText hasText]) {
        location.desiredAccuracy = kCLLocationAccuracyBest;
        if([location respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [location requestWhenInUseAuthorization];
            [location startUpdatingLocation];
            
        }
        [location stopUpdatingLocation];

        NSLog(@"YI YES");
        [_errorLabel setHidden:YES];
    } else {
        
            NSLog(@"YI error:enter text");
            [_errorLabel setHidden:NO];
            [_errorLabel setText:@"error: enter text"];
        
    }
    
    
}

- (IBAction)updateButtonClick:(id)sender {
    
    [self isTextFieldCorrect:_longitudeText];
    
    [self isTextFieldCorrect:_latitudeText];
    [self uploadJson];
    
//    UIButton *button = sender;
//
//    button.backgroundColor = [UIColor greenColor];
 //   [self performSegueWithIdentifier:@"segueNotInZone" sender:nil];
    
    
    
}
- (IBAction)statusButton:(id)sender {
    [self checkingIsKidsInZone];
    
    
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
        
        _longitudeText.text =[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
        _latitudeText.text = [NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
        [self uploadJson];
        
    }

}
-(void)checkingIsKidsInZone{
    
    NSError *error;
    //should accept all names
    NSString *url_string = [NSString stringWithFormat: @"https://turntotech.firebaseio.com/digitalleash/%@.json",_userNameText.text];
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    double latDouble = [_latitudeText.text doubleValue];
    double longDouble = [_longitudeText.text doubleValue];
    double childLat = [json[@"child_latitude"] doubleValue];
    double childLong= [json[@"child_longitude"] doubleValue];

    if (childLong == 0 || childLat == 0)
        {
        [_errorLabel setHidden:NO];
        [_errorLabel setText:@"Children don't make report"];
            return;
        }else{
            [_errorLabel setHidden:YES];
        }

    


    CLLocation *parentLocation = [[CLLocation alloc]initWithLatitude: latDouble longitude: longDouble];
    CLLocation *childLocation = [[CLLocation alloc]initWithLatitude:childLat     longitude:childLong];
    
    CLLocationDistance distance = [parentLocation distanceFromLocation: childLocation];
    
    int radius = [_radiusText.text intValue];
    NSLog(@"radius is %d and distance is %f", radius, distance);
    if (distance <= radius) {
        [self performSegueWithIdentifier:@"SegueGood" sender:nil];
        NSLog(@"YI All good kids in the zone, keep drinking!");
        
        
    } else {
        [self performSegueWithIdentifier:@"segueNotInZone" sender:nil];
        NSLog(@"YI PANICK children outw of zone call the police. You are the worst parents!");
        
    }
    
}




-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


-(void) uploadJson {
    
    // validate


    // dynamic url based on username @"https://turntotech.firebaseio.com/digitalleash/<username>.json"
//[by using stringwithFormat]
    NSString * urlString = [NSString stringWithFormat:@"https://turntotech.firebaseio.com/digitalleash/%@.json",_userNameText.text];
    
    
    // 1
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    // 2
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"PUT"; // POST or PUT or PATCH

    // 3
    NSDictionary *dictionary = @{@"latitude":_latitudeText.text ,@"longitude" :_longitudeText.text ,@"radius": _radiusText.text};
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
//-(void)getDataFromUrl{
//
//    NSError *error;
//    NSString *url_string = [NSString stringWithFormat: @""];
//    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url_string]];
//    NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//    NSLog(@"json: %@", json);
//
//}







@end
