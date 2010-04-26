# 
# This file is part of Dist-Zilla-Plugin-Twitter
# 
# This software is Copyright (c) 2010 by David Golden.
# 
# This is free software, licensed under:
# 
#   The Apache License, Version 2.0, January 2004
# 
# crudly adapted from t/lib/TestUA.pm in Net::Twitter
use strict;
use warnings;
package LWP::TestUA;

use base 'LWP::UserAgent';

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_handler(
    request_send => sub { 
      my $res = HTTP::Response->new(200, 'OK');
      $res->content('{"test":"success"}');
      return $res
    },
  );
  return $self;
}

1;

