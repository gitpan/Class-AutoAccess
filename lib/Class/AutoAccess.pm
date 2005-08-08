package Class::AutoAccess;

use warnings;


=head1 NAME

Class::AutoAccess - Zero code dynamic accessors implementation.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

=head1 DESCRIPTION

Base class for automated accessors implementation.

If you implement a class as a blessed hash reference, this class can greatly helps you not
to write the fields accessors yourself. It uses the AUTOLOAD method to implement accessors
on demand. Since the accessor is *REALLY* implemented the first time it is attempted to be use,
using this class does NOT affect performance of your program.

Inheriting from this class does not impose accessors. If you want to implement your own accessors for any reason
(checking, implementation change ... ), just write them and they will be used in place of automated ones.


Since it use the AUTOLOAD method, be carefull when you 
implement your own AUTOLOAD method in subclasses. If you wanna keep this functionnal in this particular case,
evaluate SUPER::AUTOLOAD in your own AUTOLOAD method before doing anything else.


=head1 SYNOPSIS

    package Foo ;

    # This class Foo will benefit from the AutoAccessors features of the base class Class::AutoAccess 

    use base qw/Class::AutoAccess/ ;  # Just write that and that's all !

    sub new{
        my ($class) = @_ ;
        my $self = {
                'bar' => undef ,
                'baz' => undef ,
                'toCheck' => undef
        };
     return bless $self, $class ;
    }

    sub toCheck{
        my ($self , $value ) = @_ ;
        # Behave the way you want. This accessor will be used in place of automated ones.
    }

    1;

    package main ;

    my $o = Foo->new();
    
    # Since there is a bar attribute, the accessor will be implemented at the first use:
    $o->bar();
    # This time, the bar accessor is really implemented so there is no performance lost.
    $o->bar("new value");

    # Idem.
    $o->baz() ;
    
    # If you wrote your own accessor, that one will be used.
    $o->toCheck("value");

=head1 AUTHOR

Jerome Eteve, C<< <jerome@eteve.net> >>

=head1 BUGS

None known.

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
