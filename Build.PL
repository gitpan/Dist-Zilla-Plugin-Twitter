
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Dist::Zilla::App::Tester" => 0,
    "Dist::Zilla::Role::Releaser" => 0,
    "Dist::Zilla::Tester" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Response" => 0,
    "LWP::UserAgent" => 0,
    "Module::Build" => "0.3601",
    "Params::Util" => 0,
    "Sub::Exporter" => 0,
    "Test::More" => "0.88",
    "base" => 0
  },
  "configure_requires" => {
    "ExtUtils::MakeMaker" => "6.30",
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Twitter when you release with Dist::Zilla",
  "dist_author" => [
    "David Golden <dagolden\@cpan.org>",
    "Mike Doherty <doherty\@cpan.org>"
  ],
  "dist_name" => "Dist-Zilla-Plugin-Twitter",
  "dist_version" => "0.016",
  "license" => "apache",
  "module_name" => "Dist::Zilla::Plugin::Twitter",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Config::INI::Reader" => 0,
    "Config::INI::Writer" => 0,
    "Dist::Zilla" => 4,
    "Dist::Zilla::Role::AfterRelease" => 0,
    "Dist::Zilla::Role::TextTemplate" => 0,
    "Dist::Zilla::Util" => 0,
    "File::Spec" => 0,
    "Moose" => "0.99",
    "Net::Twitter" => 3,
    "Try::Tiny" => 0,
    "WWW::Shorten" => "3.02",
    "WWW::Shorten::Simple" => 0,
    "WWW::Shorten::TinyURL" => 0,
    "namespace::autoclean" => "0.09",
    "perl" => "5.008",
    "strict" => 0,
    "utf8" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
