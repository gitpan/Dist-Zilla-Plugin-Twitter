# 
# This file is part of Dist-Zilla-Plugin-Twitter
# 
# This software is Copyright (c) 2010 by David Golden.
# 
# This is free software, licensed under:
# 
#   The Apache License, Version 2.0, January 2004
# 
package Dist::Zilla::Plugin::FakeUploader;
# ABSTRACT: fake plugin to test release

use Moose;
with 'Dist::Zilla::Role::Releaser';

has user => (
  is   => 'ro',
  isa  => 'Str',
  required => 1,
  default  => 'AUTHORID',
);

sub release {
  my $self = shift;

  $self->log('Fake release happening (nothing was really done)');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

__END__

=head1 DESCRIPTION

This plugin is a C<Releaser> that does nothing. It is directed to plugin
authors, who may need a dumb release plugin to test their shiny plugin
implementing C<BeforeRelease> and C<AfterRelease>.

When this plugin does the release, it will just log a message and finish.

If you set the environment variable C<DZIL_FAKERELEASE_FAIL> to a true value,
the plugin will die instead of doing nothing. This can be usefulfor
authors wanting to test reliably that release failed.
