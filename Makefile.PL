
use strict;
use warnings;

use 5.008;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Twitter when you release with Dist::Zilla",
  "AUTHOR" => "David Golden <dagolden\@cpan.org>, Mike Doherty <doherty\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Module::Build" => "0.3601"
  },
  "CONFIGURE_REQUIRES" => {
    "Module::Build" => "0.3601"
  },
  "DISTNAME" => "Dist-Zilla-Plugin-Twitter",
  "EXE_FILES" => [],
  "LICENSE" => "apache",
  "NAME" => "Dist::Zilla::Plugin::Twitter",
  "PREREQ_PM" => {
    "Config::INI::Reader" => 0,
    "Config::INI::Writer" => 0,
    "Dist::Zilla" => 4,
    "Dist::Zilla::Role::AfterRelease" => 0,
    "Dist::Zilla::Role::TextTemplate" => 0,
    "Dist::Zilla::Util" => 0,
    "File::Path" => 0,
    "File::Spec" => 0,
    "Moose" => "0.99",
    "Net::Twitter" => "4.00001",
    "Try::Tiny" => 0,
    "WWW::Shorten" => "3.02",
    "WWW::Shorten::Simple" => 0,
    "WWW::Shorten::TinyURL" => 0,
    "namespace::autoclean" => "0.09",
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "TEST_REQUIRES" => {
    "Dist::Zilla::App::Tester" => 0,
    "Dist::Zilla::Role::Releaser" => 0,
    "Dist::Zilla::Tester" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Response" => 0,
    "LWP::UserAgent" => 0,
    "Params::Util" => 0,
    "Sub::Exporter" => 0,
    "Test::More" => "0.88",
    "base" => 0
  },
  "VERSION" => "0.021",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

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



