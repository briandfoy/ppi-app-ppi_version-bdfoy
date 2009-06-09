package PPI::App::ppi_version::BDFOY;
use base qw(PPI::App::ppi_version);

use PPI::App::ppi_version;


use 5.005;
use strict;
use version;
use File::Spec             ();
use PPI::Document          ();
use File::Find::Rule       ();
use File::Find::Rule::Perl ();
use Term::ANSIColor;

use vars qw{$VERSION};
BEGIN {
        $VERSION = '0.12';
}

#####################################################################
# Main Methods

sub print_my_version {
	print "brian's ppi_version $VERSION - Copright 2006 - 2007 Adam Kennedy\n";
	}

sub print_file_report
	{
	my $class = shift;
	my( $file, $version, $message, $error ) = @_;
	
	if( defined $version )
		{
		$class->print_info( 
			colored( ['green'], $version ),
			  " $file" );
		}
	elsif( $error )
		{
		$class->print_info( "$file... ", colored ['red'], $message );
		}
	else
		{
		$class->print_info( "$file... ", $message );
		}
	}
	
sub print_info
	{
	my $class = shift;
	
	print @_, "\n";
	}
	
sub get_file_list
	{
	my( $class, $dir ) = @_;
	
	my @files = grep { ! /\bblib\b/ } File::Find::Rule->perl_file
	               ->in( $dir || File::Spec->curdir );
	
	print  "Found " . scalar(@files) . " file(s)\n";

	return \@files;	
	}

sub show {
	my $class = shift;
	
	my @args = @_;
	
	my $files = $class->get_file_list( $args[0] );
	
	my $count = 0;
	foreach my $file ( @$files ) {
		my( $version, $message, $error_flag ) = $class->get_version( $file );
		$class->print_file_report( $file, $version, $message, $error_flag );
		$count++ if defined $version;
		}
		
	$class->print_info( "Found $count versions" );
	}

sub get_version {
	my( $class, $file ) = @_;
	
	my $Document = PPI::Document->new( $file );

	return ( undef, " failed to parse file", 1 ) unless $Document;
	
	# Does the document contain a simple version number
	my $elements = $Document->find( sub {
		# Find a $VERSION symbol
		$_[1]->isa('PPI::Token::Symbol')           or return '';
		$_[1]->content =~ m/^\$(?:\w+::)*VERSION$/ or return '';

		# It is the first thing in the statement
		$_[1]->sprevious_sibling                  and return '';

		# Followed by an "equals"
		my $equals = $_[1]->snext_sibling          or return '';
		$equals->isa('PPI::Token::Operator')       or return '';
		$equals->content eq '='                    or return '';

		# Followed by a quote
		my $quote = $equals->snext_sibling         or return '';
		$quote->isa('PPI::Token::Quote')           or return '';

		# ... which is EITHER the end of the statement
		my $next = $quote->snext_sibling           or return 1;

		# ... or is a statement terminator
		$next->isa('PPI::Token::Structure')        or return '';
		$next->content eq ';'                      or return '';

		return 1;
		} );

	return ( undef, "no version", 0 ) unless $elements;

	if ( @$elements > 1 ) {
		$class->error("$file contains more than one \$VERSION = 'something';");
		}

	my $element = $elements->[0];
	my $version = $element->snext_sibling->snext_sibling;
	my $version_string = $version->string;

	$class->error("Failed to get version string") 
		unless defined $version_string;
	
	return ( $version_string, undef, undef );
	}

sub change {
	my $class = shift;
	
	my $from = shift @_;
	
	unless ( $from and $from =~ /^[\d\._]+$/ ) {
		$class->error("From version is not a number [$from]");
	}
	my $to = shift @_;
	unless ( $to and $to =~ /^[\d\._]+$/ ) {
		$class->error("Target to version is not a number [$to]");
	}

	$from = "'$from'";
	$to   = "'$to'";

	# Find all modules and scripts below the current directory
	my $files = $class->get_file_list;

	my $count = 0;
	foreach my $file ( @$files ) {
		if ( ! -w $file ) {
			$class->print_info( colored ['bold red'], " no write permission" );
			next;
		}
		my $rv = $class->changefile( $file, $from, $to );
		if ( $rv ) {
			$class->print_info( 
				colored( ['cyan'], $from ), 
				" -> ",
				colored( ['bold green'], $to ), 
				" $file"
				);
			$count++;
		} elsif ( defined $rv ) {
			$class->print_info( colored( ['red'], " skipped" ), " $file" );
		} else {
			$class->print_info( colored( ['red'], " failed to parse" ), " $file" );
		}
	}

	$class->print_info( "Updated " . scalar($count) . " file(s)" );
	$class->print_info( "Done." );
	return 0;
}

sub error 
	{
	print "\n", colored ['red'], "  $_[1]\n\n";
	return 255;
	}

1;
