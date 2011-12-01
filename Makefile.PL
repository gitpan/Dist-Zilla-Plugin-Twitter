
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Twitter when you release with Dist::Zilla",
  "AUTHOR" => "David Golden <dagolden\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Dist::Zilla::App::Tester" => 0,
    "Dist::Zilla::Role::Releaser" => 0,
    "Dist::Zilla::Tester" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Response" => 0,
    "LWP::UserAgent" => 0,
    "Params::Util" => 0,
    "Path::Class" => 0,
    "Sub::Exporter" => 0,
    "Test::More" => "0.88",
    "base" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Dist-Zilla-Plugin-Twitter",
  "EXE_FILES" => [],
  "LICENSE" => "apache",
  "NAME" => "Dist::Zilla::Plugin::Twitter",
  "PREREQ_PM" => {
    "Carp" => 0,
    "Dist::Zilla" => 4,
    "Dist::Zilla::Role::AfterRelease" => 0,
    "Dist::Zilla::Role::TextTemplate" => 0,
    "Math::BigFloat" => 0,
    "Moose" => "0.99",
    "Net::Netrc" => 0,
    "Net::Twitter" => 3,
    "WWW::Shorten" => "3.02",
    "WWW::Shorten::Simple" => 0,
    "WWW::Shorten::TinyURL" => 0,
    "namespace::autoclean" => "0.09",
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.013",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



