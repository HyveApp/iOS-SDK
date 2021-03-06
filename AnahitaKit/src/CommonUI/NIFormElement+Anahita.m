//
//  NIFormElement+Anahita.m
//  Pods
//
//  Created by Arash  Sanieyan on 2013-01-21.
//
//

#import "NIFormElement+Anahita.h"
#import "JRSwizzle.h"
#import <objc/runtime.h>

@interface NITableViewModelSection : NSObject
@property(nonatomic,readonly) NSArray *rows;
@end

@interface NITableViewModel()

@property(nonatomic,readonly) NSArray *sections;

@end

@implementation NITableViewModel(ExtraMethods)

- (NSIndexPath*)indexPathOfObject:(id)object
{
    __block NSIndexPath *indexPath = nil;
    [self.sections enumerateObjectsUsingBlock:^(NITableViewModelSection *section, NSUInteger sectionIndex, BOOL *stop) {
        stop = indexPath != nil;
        [section.rows enumerateObjectsUsingBlock:^(id<NICellObject> obj, NSUInteger rowIndex, BOOL *stop) {
                if ( [obj isEqual:object] ) {
                    indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
                }
                stop = indexPath != nil;
        }];
    }];
    return indexPath; 
}

@end

@implementation NIMutableTableViewModel(ExtraMethods)

- (NSArray*)replaceObjectAtIndexPath:(NSIndexPath *)indexPath withObject:(id)object
{
    [self removeObjectAtIndexPath:indexPath];
    [self insertObject:object atRow:indexPath.row inSection:indexPath.section];
    return [NSArray arrayWithObject:indexPath];
}

@end

@interface NICellFactory(SwizzleCellFactoryMethod)
@end

@implementation NICellFactory(SwizzleCellFactoryMethod)

+ (UITableViewCell *)SwizzleCellFactoryMethod_cellWithClass:(Class)cellClass
                         tableView:(UITableView *)tableView
                            object:(id)object
{

  UITableViewCell* cell = nil;

  NSString* identifier = NSStringFromClass(cellClass);

  cell = [tableView dequeueReusableCellWithIdentifier:identifier];

  if (nil == cell) {
    UITableViewCellStyle style = UITableViewCellStyleDefault;
    if ([object respondsToSelector:@selector(cellStyle)]) {
      style = [object cellStyle];
    }
    cell = [[cellClass alloc] initWithStyle:style reuseIdentifier:identifier];
    if ( [object respondsToSelector:@selector(styleTags)]) {
            [[object styleTags] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
               [cell addStyleTag:obj];
            }];
    }
  }

  // Allow the cell to configure itself with the object's information.
  if ([cell respondsToSelector:@selector(shouldUpdateCellWithObject:)]) {
    [(id<NICell>)cell shouldUpdateCellWithObject:object];
  }

  return cell;
}

@end

__attribute__((constructor))
void NIFormElement_Anahita_Initialize()
{
    [NICellFactory jr_swizzleClassMethod:@selector(cellWithClass:tableView:object:)
        withClassMethod:@selector(SwizzleCellFactoryMethod_cellWithClass:tableView:object:) error:nil];
}

@implementation NICellObject(StylerTag)

SYNTHESIZE_PROPERTY(NSMutableArray*, setStyleTags, styleTags, OBJC_ASSOCIATION_RETAIN_NONATOMIC,[NSMutableArray array]);

- (void)addStyleTags:(NSString *)tag1, ...
{
    va_list args;
    va_start(args, tag1);
    for(NSString* arg = tag1; arg != nil; arg=va_arg(args, NSString*)) {
        [self addStyleTag:arg];
    }
    va_end(args);
}

- (void)addStyleTag:(NSString *)tag
{
    [(NSMutableArray*)[self styleTags] addObject:tag];
}

@end

@implementation NISwitchFormElement(Anahita)

- (id)elementValue
{
    return [NSNumber numberWithBool:self.value];
}

@end

@implementation NITextInputFormElement(Anahita)

- (id)elementValue
{
    return self.value;
}

@end

@implementation NISliderFormElement(Anahita)

- (id)elementValue
{
    return [NSNumber numberWithFloat:self.value];
}

@end

@implementation NISegmentedControlFormElement(Anahita)

- (id)elementValue
{
    return nil;
}

@end

@implementation NIDatePickerFormElement(Anahita)

- (id)elementValue
{
    return self.date;
}

@end
