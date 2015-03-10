//
//  RJUserDetailInfoController.m
//  Lesson46-47Ex
//
//  Created by Hopreeeeenjust on 10.03.15.
//  Copyright (c) 2015 Hopreeeeenjust. All rights reserved.
//

#import "RJUserDetailInfoController.h"
#import "RJUser.h"
#import "RJFollowersViewController.h"
#import "RJGroupsViewController.h"

@interface RJUserDetailInfoController ()
@end

@implementation RJUserDetailInfoController

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.photoImageView.image = self.image;
    self.photoImageView.layer.cornerRadius = CGRectGetHeight(self.photoImageView.bounds) / 2;
    self.photoImageView.clipsToBounds = YES;
    
    self.statusLabel.text = self.onlineSstatus;
    self.nameLabel.text = self.name;
    self.cityLabel.text = self.city;
    self.ageLabel.text = self.age;
    
    if ([self.user.status isEqualToString:@""]) {
        self.user.status = nil;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.user.status) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView numberOfSections] == 2 && section == 0) {
        return 1;
    } else if ([tableView numberOfSections] == 2 && section == 1) {
        return 2;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (self.user.status && indexPath.section == 0) {
        cell.textLabel.text = self.user.status;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        [self setAttributedTextForCell:cell atIndexPath:indexPath];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!([tableView numberOfSections] == 2 && [indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:0]])) {
        if (indexPath.row == 0) {
            [self actionShowUserGroups];
        } else if (indexPath.row == 1) {
            [self actionShowUserFollowers];
        }
    }
}

#pragma mark - Actions

- (void)actionShowUserFollowers {
    RJFollowersViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFollowersViewController"];
    vc.userID = self.user.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionShowUserGroups {
    RJGroupsViewController *vc = [[RJGroupsViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.userID = self.user.userID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Methods

- (void)setAttributedTextForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self cell:cell withAttributedText:@"Группы" andCount:self.user.groupsCount];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        [self cell:cell withAttributedText:@"Подписчики" andCount:self.user.followersCount];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)cell:(UITableViewCell *)cell withAttributedText:(NSString *)text andCount:(NSInteger)count {
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %ld", text, count];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSRange range = NSMakeRange(text.length + 1, [[NSString stringWithFormat:@"%ld", count] length]); //+1 is for space symbol
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %ld", text, count]];
    [string addAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.f],
       NSForegroundColorAttributeName:[UIColor lightGrayColor]}
                    range:range];
    cell.textLabel.attributedText = string;
}

@end
