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
		'File::Find::Rule::Perl' => '0',
		'File::Find::Rule'       => '0',
		'PPI::App::ppi_version'  => '0',
		'PPI::Document'          => '0',
		'PPI'                    => '0',
		'Term::ANSIColor'        => '0',		
		'Test::More'             => '0',
		'version'                => '0',
		},

	'PM'           => {
		'lib/BDFOY.pm' => '$(INST_LIBDIR)/BDFOY.pm',
		},

	(
	$ExtUtils::MakeMaker::VERSION ge '6.48' ? 
		(
		MIN_PERL_VERSION => 5.008,

		META_MERGE       => {
			resources => {
				repository => 'git@github.com:briandfoy/PPI-App-ppi_version-BDFOY.git',
				},
			keywords => ['ppi','version'],
			},
		) 
		: 
		()
	 ),

	'EXE_FILES'     => [ qw(script/ppi_version) ],

	'MAN3PODS'     => {
		'lib/BDFOY.pm' => '$(INST_MAN3DIR)/PPI::App::ppi_version::BDFOY.$(MAN3EXT)',
		},

	'MAN1PODS'     => {
		'script/ppi_version' => '$(INST_MAN1DIR)/ppi_version.$(MAN3EXT)',
		},

	clean  => { FILES    => q|PPI-App-ppi_version-BDFOY-*| },
	);
