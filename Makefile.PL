use ExtUtils::MakeMaker;

WriteMakefile(
    	NAME			=> 'XML::RSS::JavaScript',
    	VERSION_FROM		=> 'lib/XML/RSS/JavaScript.pm',
	PREREQ_PM		=> { 'XML::RSS' => .9 },
);
