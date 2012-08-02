package test::Test::Interval;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::Test::More;
use Test::Interval;
use Time::HiRes qw(usleep);

sub _ok : Test(3) {
    test_ok_ok {
        ms_ok {
            
        } 1_000;
    };
    
    test_ok_ok {
        ms_ok {
            usleep 1500;
        } 10;
    };
    
    test_ok_ok {
        ms_ok {
            usleep 100_000;
        } 200;
    };
}

sub _ng : Test(1) {
    test_ng_ok {
        ms_ok {
            usleep 1500;
        } 1;
    };
}

__PACKAGE__->runtests;

1;
