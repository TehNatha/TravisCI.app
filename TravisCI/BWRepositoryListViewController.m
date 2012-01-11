//
//  BWMasterViewController.m
//  TravisCI
//
//  Created by Bradley Grzesiak on 12/19/11.
//  Copyright (c) 2011 Bendyworks. All rights reserved.
//

#import "BWRepositoryListViewController.h"
#import "BWRepositoryTableCell.h"
#import "BWBuildListViewController.h"
#import "BWColor.h"
#import "BWAwesome.h"

#import "BWRepository.h"

@interface BWRepositoryListViewController ()
- (void)configureCell:(BWRepositoryTableCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)refreshRepositoryList;
@end

@implementation BWRepositoryListViewController
@synthesize repositoryCellNib;

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize buildListController = _buildListController;

- (void)awakeFromNib
{
    if (IS_IPAD) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    self.detailViewController = (BWRepositoryViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)viewWillAppear:(BOOL)animated { 

    [super viewWillAppear:animated];

    [self refreshRepositoryList];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { return YES; }


#pragma mark - Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return [[self.fetchedResultsController sections] count]; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWRepositoryTableCell *cell = [BWRepositoryTableCell cellForTableView:tableView fromNib:self.repositoryCellNib];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BWRepository *repository = [BWRepository presenterWithObject:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
    [repository fetchBuilds];
//    [self.detailViewController configureViewAndSetRepository:repository];

    self.buildListController.repository = repository;
    [self.navigationController pushViewController:self.buildListController animated:YES];
}

- (UINib *)repositoryCellNib
{
    if (repositoryCellNib == nil) {
        self.repositoryCellNib = [BWRepositoryTableCell nib];
    }
    return repositoryCellNib;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BWCDRepository" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"last_build_started_at" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"RepositoryList"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}

    return __fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller { [self.tableView beginUpdates]; }
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller  { [self.tableView endUpdates];   }

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(BWRepositoryTableCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)configureCell:(BWRepositoryTableCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    BWRepository *repository = [BWRepository presenterWithObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    cell.slug.text = repository.slug;
    cell.buildNumber.text = [NSString stringWithFormat:@"#%@", repository.last_build_number];


    cell.duration.text = [repository durationText];
    cell.finished.text = [repository finishedText];

    [cell.slug setTextColor:repository.statusTextColor];
    [cell.buildNumber setTextColor:repository.statusTextColor];
    [cell.statusImage setImage:repository.statusImage];
}

- (void)refreshRepositoryList
{
    RKObjectManager *manager = [RKObjectManager sharedManager];

    [manager loadObjectsAtResourcePath:@"/repositories.json"
                         objectMapping:[manager.mappingProvider objectMappingForKeyPath:@"BWCDRepository"]
                              delegate:self];
}

#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects { }

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Getters and Setters

- (BWBuildListViewController *)buildListController
{
    if (_buildListController != nil) {
        return _buildListController;
    }
    
    _buildListController = [[BWBuildListViewController alloc] initWithStyle:UITableViewStylePlain];
    
    return _buildListController;
}

@end
