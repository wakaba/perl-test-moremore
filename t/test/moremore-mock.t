package test::Test::MoreMore;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::MoreMore::Mock;

sub _param : Test(7) {
    my $obj = Test::MoreMore::Mock->new;
    is $obj->param('a'), undef;
    $obj->param(a => 1);
    is $obj->param('a'), 1;
    $obj->param(xyz => 'abc');
    is $obj->param('xyz'), 'abc';
    $obj->param('abc' => undef);
    is $obj->param('abc'), undef;
    $obj->param(axy => 0);
    is $obj->param('axy'), 0;
    $obj->param('' => '');
    is $obj->param(''), '';
    eq_or_diff {map { $_ => 1 } $obj->param}, {a => 1, xyz => 1, abc => 1, axy => 1, '' => 1};
}

sub _param_default : Test(2) {
    my $obj = Test::MoreMore::Mock->new(param => {a => 1, b => 2});
    is $obj->param('a'), 1;
    is $obj->param('b'), 2;
}

__PACKAGE__->runtests;

1;
