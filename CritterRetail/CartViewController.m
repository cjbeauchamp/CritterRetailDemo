//
//  CartViewController.m
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/1/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//

#import "CartViewController.h"

#import "AppDelegate.h"
#import "CartCell.h"
#import <Crittercism/Crittercism.h>

@interface CartViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation CartViewController

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [Crittercism leaveBreadcrumb:@"CartViewDisplayed"];
}

- (void) updateTotal
{
    // update our total
    NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
    for(CartItem *item in self.fetchedResultsController.fetchedObjects) {
        total = [total decimalNumberByAdding:item.productPrice];
    }
    
    self.totalLabel.text = [NSString stringWithFormat:@"$%@", total.stringValue];
    
    NSUInteger ct = self.fetchedResultsController.fetchedObjects.count;
    NSString *ctString = [NSString stringWithFormat:@"%ld", ct];
    
    [[self navigationController] tabBarItem].badgeValue = ct == 0 ? nil : ctString;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Initialize Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"CartItem"];
    
    // Add Sort Descriptors
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"productID" ascending:YES]]];
    
    // Initialize Fetched Results Controller
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[AppDelegate sharedDelegate].managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    // Configure Fetched Results Controller
    [self.fetchedResultsController setDelegate:self];
    
    // Perform Fetch
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
    
    if (error) {
        NSLog(@"Unable to perform fetch.");
        NSLog(@"%@, %@", error, error.localizedDescription);
    }
    
    [self updateTotal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    
    [self updateTotal];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        }
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
    }

}

- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:section];
    
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    CartCell *cell = (CartCell*)[tableView dequeueReusableCellWithIdentifier:@"CartCell"];
    
    // Configure Table View Cell
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void) configureCell:(CartCell*)cell atIndexPath:(NSIndexPath*)indexPath {

    cell.tag = indexPath.row;

    CartItem *record = (CartItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.productName.text = record.productName;
    cell.productPrice.text = [NSString stringWithFormat:@"$%@", record.productPrice.stringValue];
    cell.productDescription.text = record.productDescription;

    cell.productImageView.image = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^(void) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:record.imageURL]];
                             
        UIImage* image = [[UIImage alloc] initWithData:imageData];
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (cell.tag == indexPath.row) {
                    cell.productImageView.image = image;
                    [cell setNeedsLayout];
                }
            });
        }
    });
    
}

- (IBAction)toggleEdit:(id)sender {
    
    [(UIBarButtonItem*)sender setTitle:self.tableView.editing?@"Edit":@"Done"];
    
    [self.tableView setEditing:!self.tableView.editing animated:TRUE];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // remove the record from the core data
        CartItem *record = (CartItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        [[AppDelegate sharedDelegate].managedObjectContext deleteObject:record];
        [[AppDelegate sharedDelegate] saveContext];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if([identifier isEqualToString:@"payment"]) {
        
        if(self.fetchedResultsController.fetchedObjects.count == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                       message:@"There are no items in your cart!"
                                      delegate:nil
                             cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil] show];
            return FALSE;
        } else {
            
            // start the crittercism transaction
            [Crittercism beginTransaction:@"checkout"];
            
            // update our total
            NSDecimalNumber *total = [NSDecimalNumber decimalNumberWithString:@"0.0"];
            for(CartItem *item in self.fetchedResultsController.fetchedObjects) {
                total = [total decimalNumberByAdding:item.productPrice];
            }
            
            int totalInt = [total decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]].intValue;
            [Crittercism setValue:totalInt forTransaction:@"checkout"];
        }
    }
    
    return TRUE;
}

@end
