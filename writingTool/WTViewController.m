//
//  WTViewController.m
//  writingTool
//
//  Created by Olivier Delecueillerie on 03/02/2014.
//  Copyright (c) 2014 Olivier Delecueillerie. All rights reserved.
//

#import "WTViewController.h"
#import "WTAudio.h"
#import "WTBool.h"
#import "WTImage.h"
#import "WTString.h"
#import "WTDate.h"
#import "WTSet.h"
#import "WTNumber.h"

@interface WTViewController ()

@property (nonatomic, strong) NSString *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *container;
@property UIViewController  *currentDetailViewController;

@end

@implementation WTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UINavigationItem *navigationItem = [self navigationItem];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];

    UIViewController *detailViewController = [self selectViewControllerForProperty:self.selectedProperty];

    [self presentDetailController: detailViewController];
    [self updateDetailController:detailViewController];
}


- (NSUInteger) propertyTypeToInteger:(NSPropertyDescription *) propertyDescription {

    NSUInteger propertyTypeInInteger = 0;

    if ([propertyDescription isKindOfClass:[NSAttributeDescription class]]) {
        NSAttributeDescription *attributeDescription = (NSAttributeDescription *) propertyDescription;
        NSAttributeType attributeType = [attributeDescription attributeType];

        if (attributeType == NSStringAttributeType ) propertyTypeInInteger = 1;

        else if ((attributeType == NSInteger16AttributeType) ||
                 (attributeType == NSInteger32AttributeType) ||
                 (attributeType == NSInteger64AttributeType) ||
                 (attributeType == NSDecimalAttributeType) ||
                 (attributeType == NSDoubleAttributeType) ||
                 (attributeType == NSFloatAttributeType)
                 ) {
            propertyTypeInInteger = 2;
        }

        else if (attributeType == NSBooleanAttributeType)   propertyTypeInInteger = 3;
        else if (attributeType == NSDateAttributeType)      propertyTypeInInteger = 4;
        else if (attributeType == NSBinaryDataAttributeType) {
            NSString *definedType = [attributeDescription.userInfo valueForKey:@"type"];
            if      ([definedType isEqualToString:@"audio"])     propertyTypeInInteger = 5;
            else if ([definedType isEqualToString:@"image"])     propertyTypeInInteger = 6;
        }
    }

    else if ([propertyDescription isKindOfClass:[NSRelationshipDescription class]]) {
        propertyTypeInInteger = 7;
    }

        return propertyTypeInInteger;
}


- (UIViewController *) selectViewControllerForProperty:(NSPropertyDescription *)propertyDescription {

    NSString *viewControllerIdentifier;

    switch ([self propertyTypeToInteger:self.selectedProperty]) {
        case 1:
            viewControllerIdentifier = @"string";
            break;
        case 2:
            viewControllerIdentifier = @"number";
            break;
        case 3:
            viewControllerIdentifier = @"bool";
            break;
        case 4:
            viewControllerIdentifier = @"date";
            break;
        case 5:
            viewControllerIdentifier = @"audio";
            break;
        case 6:
            viewControllerIdentifier = @"image";
            break;
        case 7:
            viewControllerIdentifier = @"set";
            break;
        default:
            break;
    }
    return [self.storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
}


- (void) updateDetailController :(UIViewController *)viewController {

    if ([viewController isKindOfClass:[WTString class]]) {
        WTString *stringVC = (WTString *) viewController;
        stringVC.editableField.text = [self.editedObject valueForKey:[self.selectedProperty name]];
        stringVC.editableField.placeholder = self.fieldLabel;
        [stringVC.editableField becomeFirstResponder];
    }

    else if ([viewController isKindOfClass:[WTBool class]]) {
        WTBool *boolVC = (WTBool *)viewController;
        boolVC.switchButton.on = (BOOL)[self.editedObject valueForKey:[self.selectedProperty name]];
    }

    else if ([viewController isKindOfClass:[WTDate class]]) {
        WTDate *dateVC = [[WTDate alloc] init];
        NSDate *theDate =  [self.editedObject valueForKey:[self.selectedProperty name]];
        if (theDate) {
            dateVC.datePicker.date = theDate;
        } else {
            dateVC.datePicker.date = [NSDate date];
        }
    }

    else if ([viewController isKindOfClass:[WTNumber class]]) {
        WTNumber *numberVC = (NSNumber *) viewController;
        NSNumber *value = (NSNumber*) [self.editedObject valueForKey:[self.selectedProperty name]];

    }

    else if ([viewController isKindOfClass:[WTAudio class]]) {
        WTAudio *audio = (WTAudio *) viewController;



    }

    else if ([viewController isKindOfClass:[WTImage class]]) {


    }

    else if ([viewController isKindOfClass:[WTSet class]]) {
        WTSet *setVC = (WTSet *)viewController;
        setVC.managedObjectContext = self.managedObjectContext;
        setVC.selectedObjects = [self.editedObject valueForKey:[self.selectedProperty name]];
    }
}




- (void)cancel {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void) save {

    // Set the action name for the undo operation.
    NSUndoManager * undoManager = [[self.editedObject managedObjectContext] undoManager];
    [undoManager setActionName:[NSString stringWithFormat:@"%@", self.selectedProperty.description]];
    NSError *error;
    // Pass current value to the edited object, then pop.


//STRING
    if ([self.currentDetailViewController isKindOfClass:[WTString class]]) {
        WTString *inputVC = [[self childViewControllers] firstObject];
        [self.editedObject setValue:inputVC.editableField.text forKey:[self.selectedProperty name]];
    }

//DATE
    else if ([self.currentDetailViewController isKindOfClass:[WTDate class]]) {
        WTDate *dateVC = [[self childViewControllers] firstObject];
        [self.editedObject setValue:dateVC.datePicker.date forKey:[self.selectedProperty name]];
    }

//INTEGER
    else if ([self.currentDetailViewController isKindOfClass:[WTNumber class]]) {
#warning to complete
    }

//AUDIO
    else if ([self.currentDetailViewController isKindOfClass:[WTAudio class]]) {
        WTAudio *audioVC = [[self childViewControllers] firstObject];
        NSData *audioData= [NSData dataWithContentsOfURL:audioVC.outputFileURL];
        [self.editedObject setValue:audioData forKey:[self.selectedProperty name]];
    }

//IMAGE
    else if ([self.currentDetailViewController isKindOfClass:[WTImage class]]) {
        WTImage *imageVC = [[self childViewControllers] firstObject];
        NSData *imageData= UIImagePNGRepresentation([imageVC.capturedImages firstObject]);
        [self.editedObject setValue:imageData forKey:[self.selectedProperty name]];
    }

//SET
    else if ([self.currentDetailViewController isKindOfClass:[WTSet class]]) {
        WTSet *inputVC = [[self childViewControllers] firstObject];
        NSSet *record = [NSSet setWithSet:inputVC.selectedObjects];
        [self.editedObject setValue:record forKey:self.selectedProperty.name];
    }
    
    [self.managedObjectContext save:&error];
    [[self.managedObjectContext parentContext] save:&error];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)presentDetailController:(UIViewController*)detailVC{

    //0. Remove the current Detail View Controller showed
    if(self.currentDetailViewController){
        [self removeCurrentDetailViewController];
    }

    //1. Add the detail controller as child of the container
    [self addChildViewController:detailVC];

    //2. Define the detail controller's view size
    detailVC.view.frame = [self frameForDetailController];

    //3. Add the Detail controller's view to the Container's detail view and save a reference to the detail View Controller
    [self.container addSubview:detailVC.view];
    self.currentDetailViewController = detailVC;

    //4. Complete the add flow calling the function didMoveToParentViewController
    [detailVC didMoveToParentViewController:self];

}



- (void)removeCurrentDetailViewController{

    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self.currentDetailViewController willMoveToParentViewController:nil];

    //2. Remove the DetailViewController's view from the Container
    [self.currentDetailViewController.view removeFromSuperview];

    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self.currentDetailViewController removeFromParentViewController];
}



- (void)swapCurrentControllerWith:(UIViewController*)viewController{

    //1. The current controller is going to be removed
    [self.currentDetailViewController willMoveToParentViewController:nil];

    //2. The new controller is a new child of the container
    [self addChildViewController:viewController];

    //3. Setup the new controller's frame depending on the animation you want to obtain
    viewController.view.frame = CGRectMake(0, 2000, viewController.view.frame.size.width, viewController.view.frame.size.height);

    //3b. Attach the new view to the views hierarchy
    [self.container addSubview:viewController.view];


    //Save the button position...we'll use it later
    //CGPoint buttonCenter = self.button.center;


/*    [UIView animateWithDuration:1.3

     //4. Animate the views to create a transition effect
                     animations:^{

                         //The new controller's view is going to take the position of the current controller's view
                         viewController.view.frame = self.currentDetailViewController.view.frame;

                         //The current controller's view will be moved outside the window
                         self.currentDetailViewController.view.frame = CGRectMake(0,
                                                                                  -2000,
                                                                                  self.currentDetailViewController.view.frame.size.width,
                                                                                  self.currentDetailViewController.view.frame.size.width);
                         //...and the same is for the button
                         self.button.center = CGPointMake(buttonCenter.x, 1000);

                     }


     //5. At the end of the animations we remove the previous view and update the hierarchy.
                     completion:^(BOOL finished) {
*/
                         //Remove the old Detail Controller view from superview
                         [self.currentDetailViewController.view removeFromSuperview];

                         //Remove the old Detail controller from the hierarchy
                         [self.currentDetailViewController removeFromParentViewController];

                         //Set the new view controller as current
                         self.currentDetailViewController = viewController;
                         [self.currentDetailViewController didMoveToParentViewController:self];
                         
                         //reset the button position
/*                         [UIView animateWithDuration:0.5 animations:^{
                             self.button.center = buttonCenter;
                         }];
                     }];
*/
}

- (CGRect)frameForDetailController{
    CGRect detailFrame = self.container.bounds;

    return detailFrame;
}














@end
