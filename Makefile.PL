
use strict;
use warnings;

 BEGIN { require 5.008; } 

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
                       'test' => {
                                   'TESTS' => 't/*.t'
                                 },
                       'NAME' => 'Dist::Zilla::Plugin::Twitter',
                       'DISTNAME' => 'Dist-Zilla-Plugin-Twitter',
                       'CONFIGURE_REQUIRES' => {
                                                 'ExtUtils::MakeMaker' => '6.31'
                                               },
                       'AUTHOR' => 'David Golden <dagolden@cpan.org>',
                       'BUILD_REQUIRES' => {
                                             'Sub::Exporter' => '0',
                                             'Dist::Zilla::Tester' => '0',
                                             'Dist::Zilla::Role::Releaser' => '0',
                                             'Dist::Zilla::App::Tester' => '0',
                                             'Test::More' => '0.88',
                                             'LWP::UserAgent' => '0',
                                             'Params::Util' => '0',
                                             'HTTP::Response' => '0',
                                             'File::Find' => '0',
                                             'File::Temp' => '0',
                                             'Path::Class' => '0'
                                           },
                       'ABSTRACT' => 'Twitter when you release with Dist::Zilla',
                       'EXE_FILES' => [],
                       'VERSION' => '0.006',
                       'PREREQ_PM' => {
                                        'Dist::Zilla::Role::TextTemplate' => '0',
                                        'namespace::autoclean' => '0.09',
                                        'Dist::Zilla::Role::AfterRelease' => '0',
                                        'Net::Netrc' => '0',
                                        'WWW::Shorten::TinyURL' => '1',
                                        'Carp' => '0',
                                        'utf8' => '0',
                                        'Dist::Zilla' => '2.101170',
                                        'Math::BigFloat' => '0',
                                        'Net::Twitter' => '3',
                                        'Moose' => '0.99'
                                      },
                       'LICENSE' => 'apache'
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



