use 5.008;
use strict;
use warnings;
use utf8;
package Dist::Zilla::Plugin::Twitter;
# ABSTRACT: Twitter when you release with Dist::Zilla
our $VERSION = '0.015'; # VERSION

use Dist::Zilla 4 ();
use Moose 0.99;
use Net::Twitter 3 ();
use WWW::Shorten::Simple ();  # A useful interface to WWW::Shorten
use WWW::Shorten 3.02 ();     # For latest updates to dead services
use WWW::Shorten::TinyURL (); # Our fallback
use namespace::autoclean 0.09;
use Try::Tiny;

# extends, roles, attributes, etc.
with 'Dist::Zilla::Role::AfterRelease';
with 'Dist::Zilla::Role::TextTemplate';

has 'tweet' => (
  is  => 'ro',
  isa => 'Str',
  default => 'Released {{$DIST}}-{{$VERSION}}{{$TRIAL}} {{$URL}}'
);

has 'tweet_url' => (
  is  => 'ro',
  isa => 'Str',
  default => 'https://metacpan.org/release/{{$AUTHOR_UC}}/{{$DIST}}-{{$VERSION}}/',
);

has 'url_shortener' => (
  is    => 'ro',
  isa   => 'Str',
  default => 'TinyURL',
);

has 'hash_tags' => (
  is  => 'ro',
  isa => 'Str',
);

has 'config_file' => (
    is => 'ro',
    isa => 'Str',
    default => sub {
        require File::Spec;
        require Dist::Zilla::Util;

        return File::Spec->catfile(
            Dist::Zilla::Util->_global_config_root(),
            'twitter.ini'
        );
    }
);

has 'consumer_tokens' => (
  is => 'ro',
  isa => 'HashRef',
  lazy => 1,
  default => sub {
    return { grep tr/a-zA-Z/n-za-mN-ZA-M/, map $_, # rot13
        pbafhzre_xrl      => 'fdAdffgTXj6OiyoH0anN',
        pbafhzre_frperg   => '3J25ATbGmgVf1vO0miwz3o7VjRoXC7Y9y5EfLGaUfTL',
    };
  },
);

has 'twitter' => (
    is => 'ro',
    isa => 'Net::Twitter',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $nt = Net::Twitter->new(
            useragent_class => $ENV{DZ_TWITTER_USERAGENT} || 'LWP::UserAgent',
            traits => [qw/ API::REST OAuth /],
            %{ $self->consumer_tokens },
        );

        try {
            require Config::INI::Reader;
            my $access = Config::INI::Reader->read_file( $self->config_file );

            $nt->access_token( $access->{'api.twitter.com'}->{access_token} );
            $nt->access_token_secret( $access->{'api.twitter.com'}->{access_secret} );
        }
        catch {
            $self->log("Error: $_");

            my $auth_url = $nt->get_authorization_url;
            $self->log(__PACKAGE__ . " isn't authorized to tweet on your behalf yet");
            $self->log("Go to $auth_url to authorize this application");
            my $pin = $self->zilla->chrome->prompt_str('Enter the PIN: ', { noecho => 1 });
            chomp $pin;
            # Fetches tokens and sets them in the Net::Twitter object
            my @access_tokens = $nt->request_access_token(verifier => $pin);

            require Config::INI::Writer;
            Config::INI::Writer->write_file( {
                'api.twitter.com' => {
                    access_token => $access_tokens[0],
                    access_secret => $access_tokens[1],
                }
            }, $self->config_file );

            try {
                chmod 0600, $self-> config_file;
            }
            catch {
                print "Couldn't make @{[ $self->config_file ]} private: $_";
            };
        };

        return $nt;
    },
);


# methods

sub after_release {
    my $self = shift;
    my $tgz = shift || 'unknowntarball';
    my $zilla = $self->zilla;

    my $cpan_id = '';
    for my $plugin ( @{ $zilla->plugins_with( -Releaser ) } ) {
      if ( my $user = eval { $plugin->user } || eval { $plugin->username } ) {
        $cpan_id = uc $user;
        last;
      }
    }
    confess "Can't determine your CPAN user id from a release plugin"
      unless length $cpan_id;

    my $path = substr($cpan_id,0,1)."/".substr($cpan_id,0,2)."/$cpan_id";

    my $stash = {
      DIST => $zilla->name,
      ABSTRACT => $zilla->abstract,
      VERSION => $zilla->version,
      TRIAL   => ( $zilla->is_trial ? '-TRIAL' : '' ),
      TARBALL => "$tgz",
      AUTHOR_UC => $cpan_id,
      AUTHOR_LC => lc $cpan_id,
      AUTHOR_PATH => $path,
    };
    my $module = $zilla->name;
    $module =~ s/-/::/g;
    $stash->{MODULE} = $module;

    my $longurl = $self->fill_in_string($self->tweet_url, $stash);
    foreach my $service (($self->url_shortener, 'TinyURL')) { # Fallback to TinyURL on errors
      my $shortener = WWW::Shorten::Simple->new($service);
      $self->log("Trying $service");
      $stash->{URL} = eval { $shortener->shorten($longurl) } and last;
    }

    my $msg = $self->fill_in_string( $self->tweet, $stash);
    if (defined $self->hash_tags) {
        $msg .= " " . $self->hash_tags;
    }


    try {
        $self->twitter->update($msg);
        $self->log($msg);
    }
    catch {
        $self->log("Couldn't tweet: $_");
        $self->log("Tweet would have been: $msg");
    };

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::Twitter - Twitter when you release with Dist::Zilla

=head1 VERSION

version 0.015

=head1 SYNOPSIS

In your C<<< dist.ini >>>:

   [Twitter]
   hash_tags = #foo
   url_shortener = TinyURL

=head1 DESCRIPTION

This plugin will use L<Net::Twitter> to send a release notice to Twitter.
By default, it will include a link to release on L<http://metacpan.org>.

The default configuration is as follows:

   [Twitter]
   tweet_url = https://metacpan.org/release/{{$AUTHOR_UC}}/{{$DIST}}-{{$VERSION}}/
   tweet = Released {{$DIST}}-{{$VERSION}}{{$TRIAL}} {{$URL}}
   url_shortener = TinyURL

The C<<< tweet_url >>> is shortened with L<WWW::Shorten::TinyURL> or
whichever other service you choose and
appended to the C<<< tweet >>> message.  The following variables are
available for substitution in the URL and message templates:

       DIST        # Foo-Bar
       MODULE      # Foo::Bar
       ABSTRACT    # Foo-Bar is a module that FooBars
       VERSION     # 1.23
       TRIAL       # -TRIAL if is_trial, empty string otherwise.
       TARBALL     # Foo-Bar-1.23.tar.gz
       AUTHOR_UC   # JOHNDOE
       AUTHOR_LC   # johndoe
       AUTHOR_PATH # J/JO/JOHNDOE
       URL         # http://tinyurl.com/...

You must be using the C<<< UploadToCPAN >>> or C<<< FakeRelease >>> plugin for this plugin to
determine your CPAN author ID.

You can use the C<<< hash_tags >>> option to append hash tags (or anything,
really) to the end of the message generated from C<<< tweet >>>.

   [Twitter]
   hash_tags = #perl #cpan #foo

=for Pod::Coverage after_release

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-Twitter>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/doherty/Dist-Zilla-Plugin-Twitter>

  git clone https://github.com/doherty/Dist-Zilla-Plugin-Twitter.git

=head1 AUTHORS

=over 4

=item *

David Golden <dagolden@cpan.org>

=item *

Mike Doherty <doherty@cpan.org>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2012 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut


__END__

