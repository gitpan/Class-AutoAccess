#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Class::AutoAccess' );
}

package Foo ;
use base qw/Class::AutoAccess/ ;

sub new{
	my ($class) = @_ ;
	my $self = {
		'bar' => undef ,
		'baz' => undef 
	};
	return bless $self, $class ;
}

1;

package main ;

my $o = Foo->new();

$o->bar();
$o->bar("new value");
$o->baz() ;

