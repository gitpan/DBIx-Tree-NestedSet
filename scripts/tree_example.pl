#!/usr/bin/perl
#This is in "scripts/tree_example.pl" of DBIx::Tree::NestedSet distribution
use strict;
use warnings;
use DBIx::Tree::NestedSet;
use DBI;

#Create the connection. We'll use SQLite for now.
#my $dbh=DBI->connect('DBI:mysql:test','user','pass') or die ($DBI::errstr);
my $dbh=DBI->connect('DBI:SQLite:test') or die ($DBI::errstr);

my $db_type='SQLite';
#my $db_type='MySQL';
my $tree=DBIx::Tree::NestedSet->new(
				    dbh=>$dbh,
				    db_type=>$db_type
				   );

#Let's see how the table will be created for this driver
print "Default Create Table Statement for $db_type:\n";
print $tree->get_default_create_table_statement()."\n";

#Let's create it.
$tree->create_default_table();

#Create the root node.
my $root_id=$tree->add_child_to_right(name=>'Food');

#Second level
my $vegetable_id=$tree->add_child_to_right(id=>$root_id,name=>'Vegetable');
my $animal_id=$tree->add_child_to_right(id=>$root_id,name=>'Animal');
my $mineral_id=$tree->add_child_to_right(id=>$root_id,name=>'Mineral');

#Third Level, under "Vegetable"
foreach ('Froot','Beans','Legumes','Tubers') {
    $tree->add_child_to_right(id=>$vegetable_id,name=>$_);
}

#Third Level, under "Animal"
foreach ('Beef','Chicken','Seafood') {
    $tree->add_child_to_right(id=>$animal_id,name=>$_);
}

#Hey! We forgot pork! Since it's the other white meat,
#it should be first among the "Animal" crowd.
$tree->add_child_to_left(id=>$animal_id,name=>'Pork');

#Oops. Misspelling.
$tree->edit_node(
		 id=>$tree->get_id_by_key(key_name=>'name',key_value=>'Froot'),
		 name=>'Fruit'
		);

#Get the child nodes of the 2nd level "Animal" node
my $children=$tree->get_self_and_children_flat(id=>$animal_id);

#Grab the first node, which is "Animal" and the
#parent of this subtree.
my $parent=shift @$children;

print 'Parent Node: '.$parent->{name}."\n";

#Loop through the children and do something.
foreach my $child (@$children) {
    print ' Child ID: '.$child->{id}.' '.$child->{name}."\n";
}

#Mineral? Get rid of it.
$tree->delete_self_and_children(id=>$mineral_id);

#Print the rudimentary report built into the module.
print "\nThe Complete Tree:\n";
print $tree->create_report();
