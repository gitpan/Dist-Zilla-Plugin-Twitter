#
# This file is part of Dist-Zilla-Plugin-Twitter
#
# This software is Copyright (c) 2011 by David Golden.
#
# This is free software, licensed under:
#
#   The Apache License, Version 2.0, January 2004
#
# mock version
use strict;
use warnings;
package Net::Netrc;

my $fake = {
  login => 'jdoe@example.com',
  account => 'jdoe',
  password => 'example',
};

sub lookup { return bless $fake }

sub login { return $fake->{login} }
sub account { return $fake->{account} }
sub password { return $fake->{password} }
sub lpa { ($fake->login, $fake->password, $fake->account) }

1;
