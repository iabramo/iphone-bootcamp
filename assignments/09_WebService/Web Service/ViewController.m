//
//  ViewController.m
//  Web Service
//
//  Created by Matt Tardiff on 4/21/13.
//  Copyright (c) 2013 Matthew Tardiff. All rights reserved.
//

#import "ViewController.h"
#import "RestaurantCell.h"
#import "ReserveViewController.h"

@interface ViewController ()
{
    NSArray *searchResults;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSInteger row = [self.tableView indexPathForSelectedRow].row;
    NSString *url = [[searchResults objectAtIndex:row] objectForKey:@"mobile_reserve_url"];
    ((ReserveViewController *)segue.destinationViewController).url = url;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // search url
    NSString *searchURL = @"http://opentable.heroku.com/api/restaurants?zip=%@";
    
    // create NSURL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:searchURL, searchBar.text]];
    
    // create NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // start async connection
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (! error)
        {
            NSError *err = nil;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
            
            searchResults = [[json objectForKey:@"restaurants"] copy];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }
    }];
    
    // hide keyboard
    [searchBar resignFirstResponder];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // could optionally delete this method and it would default to returning 1
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    RestaurantCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.nameLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    cell.addressLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"address"];
    
    cell.phoneNumberLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"phone"];
    
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
