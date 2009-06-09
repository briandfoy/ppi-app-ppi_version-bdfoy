use ExtUtils::MakeMaker;

require 5.008;

eval "use Test::Manifest 1.21";

WriteMakefile(
	'NAME'	       => 'PPI::App::ppi_version::BDFOY',
	'ABSTRACT'     => "brian d foy's version of ppi_version",
	'VERSION_FROM' => 'lib/BDFOY.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	'PM'           => {
		'lib/BDFOY.pm' => '$(INST_LIBDIR)/BDFOY.pm',
		},

	'EXE_FILES'     => [ qw(script/ppi_version) ],
	
	'MAN3PODS'     => {
		'lib/BDFOY.pm' => '$(INST_MAN3DIR)/PPI::App::ppi_version::BDFOY.${MAN3EXT}',
		},

	'MAN1PODS'     => {
		'script/ppi_version' => '$(INST_MAN1DIR)/ppi_version.${MAN3EXT}',
		},

	clean  => { FILES    => q|PPI-App-ppi_version-BDFOY-*| },
	);
