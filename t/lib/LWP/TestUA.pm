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
use HTTP::Response;
package LWP::TestUA;

use base 'LWP::UserAgent';

# from http://apiwiki.twitter.com/ xAuth example
my $token_reply =
  "oauth_token=819797-torCkTs0XK7H2A2i1ee5iofqkMC4p7aayeEXRTmlw&" .
  "oauth_token_secret=SpuaLXRxZ0gOZHNQKPooBiWC2RY81klw13kLZGa2wc&" .
  "user_id=819797&screen_name=episod";

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->add_handler(
    request_send => sub {
      my $req = shift;
      my $res = HTTP::Response->new(200, 'OK');
      if ( $req->uri =~ qr{\Ahttps://api.twitter.com/oauth/access_token} ) {
        $res->content($token_reply);
      }
      else {
        $res->content('{"test":"success"}');
      }
      return $res
    },
  );
  return $self;
}

1;

