package XML::RSS::JavaScript;

use strict;
use Carp;
use base 'XML::RSS';

our $VERSION = 0.2;

=head1 NAME

XML::RSS::JavaScript - serialize your RSS as JavaScript

=head1 SYNOPSIS

    use XML::RSS::JavaScript;
    my $rss = XML::RSS::JavaScript->new();
    $rss->channel(
	title	    => 'My Channel',
	link	    => 'http://my.url.com',
	description => 'My RSS Feed.'
    );

    $rss->add_item(
	title	    => 'My item #1',
	link	    => 'http://my.item.com#1',
	description => 'My first news item.'
    );

    $rss->add_item( 
	title	    => 'My item #2',
	link	    => 'http://my.item.com#2',
	description => 'My second news item.'
    );

    # save rss 
    $rss->save( '/usr/local/apache/htdocs/myfeed.xml' );

    # save identical content as javascript
    $rss->save_javascript( '/usr/local/apache/htdocs/myfeed.js');

=head1 DESCRIPTION

Perhaps you use XML::RSS to generate RSS for consumption by RSS parsers. 
Perhaps you also get requests for how to use the RSS feed by people who 
have no idea how to parse XML, or write Perl programs for that matter.

Enter XML::RSS::JavaScript, a simple subclass of XML::RSS which writes your
RSS feed as a sequence of JavaScript print statements. This means you 
can then write the JavaScript to disk, and a users HTML can simply
I<include> it like so:

    <script language="JavaScript" src="/myfeed.js"></script>

What's more the javascript emits HTML that can be fully styled with 
CSS. See the CSS examples included with the distribution in the css directory.

=head1 METHODS

=head2 save_javascript()

Pass in the path to a file you wish to write your javascript in. Optionally
you can pass in the maximum amount of items to include from the feed and a
boolean value to switch descriptions on or off (default: on). 

    save_javascript( '/usr/local/apache/htdocs/rss/myfeed.js' );

    or no more than 10 items:

    save_javascript( '/usr/local/apache/htdocs/rss/myfeed.js', 10 );

    or no descriptions:

    save_javascript( '/usr/local/apache/htdocs/rss/myfeed.js', undef, 0 );

=cut

sub save_javascript {
	my ( $self, $file, @options ) = @_;
	if ( !$file ) { 
	    croak "You must pass in a filename to save_javascript";
	}
	open( OUT, ">$file" ) || croak "Cannot open file $file for write: $!";
	print OUT $self->as_javascript( @options );
	close OUT;	
}

=head2 as_javascript()

as_javascript will return a string containing javascript suitable for 
generating text for your RSS object. You can pass in the maximum amount of
items to include by passing in an integer as an argument and a boolean value
to switch descriptions on or off (default: on). If you pass in no argument
you will get the contents of the entire object.

    $js = $rss->as_javascript();

=cut

sub as_javascript {
	my ( $self, $max, $descriptions ) = @_;
	my $items = scalar @{ $self->{ items } };
	if ( not $max or $max > $items ) { $max = $items; }

	## open javascript section
	my $output = _js_print( '<div class="rss_feed">' );
	$output   .= _js_print( '<div class="rss_feed_title">' . $self->channel( 'title' ) . '</div>' );
	
	## open our list
	$output .= _js_print( '<ul class="rss_item_list">' );

	## generate content for each item
	foreach my $item ( ( @{ $self->{ items } } )[ 0..$max - 1 ] ) {
		my $link  = $item->{ link };
		my $title = $item->{ title };
		my $desc  = $item->{ description };
		my $data  = <<"JAVASCRIPT_TEXT";
<li class="rss_item">
<span class="rss_item_title"><a class="rss_item_link" href="$link">$title</a></span>
JAVASCRIPT_TEXT
		$data    .= " <span class=\"rss_item_desc\">$desc</span>" if $descriptions or not defined ( $descriptions );
		$data    .= '</li>';
		$output  .= _js_print( $data );
	}
	
	## close our item list, and return 
	$output .= _js_print( '</ul>' );
	$output .= _js_print( '</div>' );
	return $output;

}

=head1 SEE ALSO

=over 4 

=item * XML::RSS

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>brian@alternation.netE<gt>

=item * Ed Summers E<lt>ehs@pobox.comE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Brian Cassidy and Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

sub _js_print { 
    my $string = shift;
    $string =~ s/"/\\"/g;
    $string =~ s/'/\\'/g;
    $string =~ s/\n//g;	
    return( "document.write('$string');\n" );
}

1;
