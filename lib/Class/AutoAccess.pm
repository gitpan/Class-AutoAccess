package Class::AutoAccess;

use warnings;


=head1 NAME

Class::AutoAccess - Zero code dynamic accessors implementation.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 DESCRIPTION

This class provides an autoload method that is used as an automated accessor for
object internal attributes.

Class that inherits from this have to be implement as blessed hashmaps (almost all objects).

As from now, this AUTOLOAD method produces the actual accessor method the first time
it's called. This speeds up your programm since a real accessor exists after.

=head1 SYNOPSIS

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
...

=head1 AUTHOR

Jerome Eteve, C<< <jerome@eteve.net> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-class-autoaccess@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Class-AutoAccess>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2005 Jerome Eteve, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

use Carp ;

no strict ;

sub AUTOLOAD{
	my ($self,$value)= @_ ;
	
	# $AUTOLOAD contains the name of the missing method.

	# Avoid implicit ovverriding of destroy method.
	return if $AUTOLOAD =~ /::DESTROY$/ ;

	my $attname = $AUTOLOAD;
	# Removing packagename from the attname.
	$attname =~ s/.*::// ;

	if(! exists $self->{$attname}){
		confess("Attribute $attname does not exists in $self");
	}

	# If attribute exists, got to set up the method
	# in order to avoid calling this everytime !!

	my $pkg = ref($self ) ;
	my $code = qq{
		package $pkg ;
		sub $attname {
			my \$self = shift ;
			\@_ ? \$self->{$attname} = shift :
			\$self->{$attname} ;
		}
	
	};

	eval $code ;
	if( $@ ){
		confess("Failed to create method $AUTOLOAD : $@");
	}
	
	# Let's use out brand new method !
	goto &$AUTOLOAD ;
		
}

use strict ;

1; # End of Class::AutoAccess
