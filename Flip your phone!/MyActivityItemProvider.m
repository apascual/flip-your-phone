//
//  MyActivityItemProvider.m
//  ComunioManager
//
//  Created by Abel Pascual on 27/02/13.
//
//

#import "MyActivityItemProvider.h"

@implementation MyActivityItemProvider
@synthesize inicioMensaje = _inicioMensaje;

- (id) activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    if([activityType isEqualToString:UIActivityTypePostToTwitter])
    {
        return [NSString stringWithFormat:@"%@ Try @FlipYourPhone", self.inicioMensaje];
    }
    else if([activityType isEqualToString:UIActivityTypePostToFacebook])
    {
        return [NSString stringWithFormat:@"%@ Try Flip Your Phone!", self.inicioMensaje];
    }
    else if([activityType isEqualToString:UIActivityTypeMail])
    {
        return [NSString stringWithFormat:@"%@ Try Flip Your Phone!", self.inicioMensaje];
    }
    else
    {
         return [NSString stringWithFormat:@"%@ Try Flip Your Phone!", self.inicioMensaje];
    }
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }

@end
