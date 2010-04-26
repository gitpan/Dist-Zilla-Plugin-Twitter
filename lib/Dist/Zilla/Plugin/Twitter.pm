# 
# This file is part of Dist-Zilla-Plugin-Twitter
# 
# This software is Copyright (c) 2010 by David Golden.
# 
# This is free software, licensed under:
# 
#   The Apache License, Version 2.0, January 2004
# 
use 5.008;
use strict;
use warnings;
package Dist::Zilla::Plugin::Twitter;
BEGIN {
  $Dist::Zilla::Plugin::Twitter::VERSION = '0.001';
}
# ABSTRACT: Twitter when you release with Dist::Zilla

use Carp qw/confess/;
use Moose 0.99;
use WWW::Shorten::TinyURL 1 ();
use Net::Twitter 3 ();
use namespace::autoclean 0.09;

# extends, roles, attributes, etc.
with 'Dist::Zilla::Role::AfterRelease';
with 'Dist::Zilla::Role::TextTemplate';

has 'tweet' => (
  is  => 'ro',
  isa => 'Str',
  default => 'Released {{$DIST}}-{{$VERSION}} {{$URL}}'
);

has 'tweet_url' => (
  is  => 'ro',
  isa => 'Str',
  default => 'http://frepan.64p.org/~{{$AUTHOR}}/{{$TARBALL}}'
);


# methods

sub after_release {
    my $self = shift;
    my $tgz = shift || 'unknowntarball';
    my $zilla = $self->zilla;

    my $cpan_id = '';
    for my $plugin ( @{ $zilla->plugins_with( -Releaser ) } ) {
      if ( my $user = eval { $plugin->user } ) {
        $cpan_id = $user;
        last;
      }
    }
    confess "Can't determine your CPAN user id from a release plugin"
      unless length $cpan_id;

    my $stash = {
      DIST => $zilla->name,
      VERSION => $zilla->version,
      TARBALL => "$tgz",
      AUTHOR => lc $cpan_id,
    };

    my $longurl = $self->fill_in_string($self->tweet_url, $stash);
    $stash->{URL} = WWW::Shorten::TinyURL::makeashorterlink($longurl);

    my $msg = $self->fill_in_string( $self->tweet, $stash);

    my $nt = Net::Twitter->new(
      useragent_class => $ENV{DZ_TWITTER_USERAGENT} || 'LWP::UserAgent',
      traits => ['API::REST'],
      netrc => 1,
    );
    $nt->update($msg);

    $self->log($msg);
    return 1;
}


__PACKAGE__->meta->make_immutable;

1;



=pod

=head1 NAME

Dist::Zilla::Plugin::Twitter - Twitter when you release with Dist::Zilla

=head1 VERSION

version 0.001

=head1 SYNOPSIS

In your C<<< dist.ini >>>:

   [Twitter]

In your C<<< .netrc >>>:

    machine api.twitter.com
      login YOUR_TWITTER_USER_NAME
      password YOUR_TWITTER_PASSWORD

=head1 DESCRIPTION

This plugin will use L<Net::Twitter> with the login and password in
your C<<< .netrc >>> file to send a release notice to Twitter.

The default configuration is as follows:

   [Twitter]
   tweet_url = http://frepan.64p.org/~{{$AUTHOR}}/{{$TARBALL}}
   tweet = Released {{$DIST}}-{{$VERSION}} {{$URL}}

The C<<< tweet_url >>> is shortened with L<WWW::Shorten::TinyURL> and
appended to the C<<< tweet >>> messsage.  The following variables are
available for substitution in the URL and message templates:

       DIST        # Foo-Bar
       VERSION     # 1.23
       TARBALL     # Foo-Bar-1.23.tar.gz
       AUTHOR      # CPAN author ID (in lower case)
       URL         # TinyURL

You must be using the C<<< UploadToCPAN >>> plugin for this plugin to
determine your CPAN author ID.

=for Pod::Coverage after_release

=head1 AUTHOR

  David Golden <dagolden@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by David Golden.

This is free software, licensed under:

  The Apache License, Version 2.0, January 2004

=cut


__END__


