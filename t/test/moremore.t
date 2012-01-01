package test::Test::MoreMore;
use strict;
use warnings;
use Path::Class;
use lib file(__FILE__)->dir->parent->parent->subdir('lib')->stringify;
use base qw(Test::Class);
use Test::MoreMore;
use Test::Test::More;
use List::Rubyish;
use DateTime;
use Encode;
use Carp qw(croak);

{
    package test::Test::MoreMore::MyClass;
    use Test::MoreMore;
}

{
    package My::List;
    sub new { bless $_[1] || [], $_[0] }
    sub length { scalar @{$_[0]} }
}

{
    package DBIx::MoCo::List;
    sub new { bless $_[1] || [], $_[0] }
    sub length { scalar @{$_[0]} }
}

{
  package My::DBIx::MoCo::List;
  push our @ISA, 'DBIx::MoCo::List';
}

sub _test_more_functions : Test(6) {
    my $class = 'test::Test::MoreMore::MyClass';
    ok $class->can('ok');
    ok $class->can('ng');
    ok $class->can('isa_ok');
    ok $class->can('note');
    ok $class->can('diag');
    ok $class->can('explain');
}

sub _isa_list_ok_custom_empty : Test(5) {
    my $l1 = My::List->new;
    test_ng_ok {
        isa_list_ok $l1;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 0;
    };
    local $Test::MoreMore::ListClass{'My::List'} = 1;
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 0;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_custom_empty

sub _isa_list_ok_custom_not_empty : Test(5) {
    my $l1 = My::List->new([1, 2, 4]);
    test_ng_ok {
        isa_list_ok $l1;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 3;
    };
    local $Test::MoreMore::ListClass{'My::List'} = 1;
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 3;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_custom_not_empty

sub _isa_list_ok_rubyish_empty : Test(3) {
    my $l1 = List::Rubyish->new;
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 0;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_rubyish_empty

sub _isa_list_ok_rubyish_not_empty : Test(3) {
    my $l1 = List::Rubyish->new([1, 2, 4]);
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 3;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_rubyish_not_empty

sub _isa_list_ok_moco_list_empty : Test(3) {
    my $l1 = DBIx::MoCo::List->new;
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 0;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_moco_list_empty

sub _isa_list_ok_moco_list_not_empty : Test(3) {
    my $l1 = DBIx::MoCo::List->new([1, 2, 4]);
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 3;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_moco_list_not_empty

sub _isa_list_ok_moco_list_child_empty : Test(3) {
    my $l1 = My::DBIx::MoCo::List->new;
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 0;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_moco_list_child_empty

sub _isa_list_ok_moco_list_child_not_empty : Test(3) {
    my $l1 = My::DBIx::MoCo::List->new([1, 2, 4]);
    test_ok_ok {
        isa_list_ok $l1;
    };
    test_ok_ok {
        isa_list_n_ok $l1, 3;
    };
    test_ng_ok {
        isa_list_n_ok $l1, 1;
    };
} # _isa_list_ok_moco_list_child_not_empty

sub _is_datetime : Test(12) {
    my $dt1 = DateTime->now;
    my $dt2 = $dt1->clone;
    $dt1->set_time_zone('Asia/Tokyo');
    $dt2->set_time_zone('UTC');
    is_datetime $dt1, $dt2;
    test_ng_ok {
        is_datetime $dt1, $dt2->clone->add(seconds => 1);
    };
    test_ng_ok {
        is_datetime $dt1, undef;
    };
    test_ng_ok {
        is_datetime undef, $dt2;
    };
    test_ng_ok {
        is_datetime $dt1, "abc";
    };
    test_ng_ok {
        is_datetime $dt1->epoch, $dt2;
    };
    test_ok_ok {
        is_datetime $dt1, DateTime->now(time_zone => 'UTC') . '';
    };
    test_ok_ok {
        is_datetime $dt2, DateTime->now(time_zone => 'UTC') . '';
    };
    test_ng_ok {
        is_datetime $dt1, $dt1 . '';
    };
    test_ok_ok {
        is_datetime $dt1, $dt2 . '';
    };
    test_ng_ok {
        is_datetime $dt1, '2010-01-01T01:01:02';
    };
    test_ng_ok {
        is_datetime $dt1, '2010-01-01 01:01:02';
    };
}

sub _now_ok : Test(1) {
    now_ok +DateTime->now;
}

sub _sort_ok_sorted : Test(1) {
    sort_ok { $_[0] cmp $_[1] }
        List::Rubyish->new([qw(a b c)]),
        List::Rubyish->new([qw(a b c)]);
}

sub _sort_ok_not_sorted : Test(1) {
    sort_ok { $_[0] cmp $_[1] }
        List::Rubyish->new([qw(a b c)]),
        List::Rubyish->new([qw(b a c)]);
}

sub _eq_or_diff : Test(9) {
    eq_or_diff [1, ['0']], ['1', [0]]; # Test::Differences::eq_or_diff returns not ok
    eq_or_diff 0, '0';
    eq_or_diff bless({a => '200'}, 'test::abc'),
        bless({(encode 'utf8', 'a') => '200'}, 'test::abc');
    eq_or_diff "\x00\x0D\x0Aab\xA0", "\x00\x0d\x0Aab\xA0";
    eq_or_diff "\xA4\xFE\xCD", substr "\x{A4}\x{FE}\x{CD}\x{4e00}", 0, 3;
    test_ng_ok {
        eq_or_diff 1.0, '1.0';
    };
    failure_output_like {
        eq_or_diff 1, 2;
    } qr<\Q
# +---+-----+----------+
# | Ln|Got  |Expected  |
# +---+-----+----------+
# *  1|1    |2         *
# +---+-----+----------+
\E>;
    failure_output_like {
        eq_or_diff {a => 1, b => 2}, {c => 1, b => [2]};
    } qr{\Q
# +----+---------------+----+--------------+
# | Elt|Got            | Elt|Expected      |
# +----+---------------+----+--------------+
# |   0|{              |   0|{             |
# *   1|  qq'a' => 1,  *   1|  qq'b' => [  *
# *   2|  qq'b' => 2   *   2|    2         *
# |    |               *   3|  ],          *
# |    |               *   4|  qq'c' => 1  *
# |   3|}              |   5|}             |
# +----+---------------+----+--------------+
\E};
    test_ng_ok {
        eq_or_diff {a => 1, b => 2}, {c => 1, b => 2};
    };
}

sub _dies_ok : Test(2) {
    test_ok_ok {
        dies_ok { die 1 };
    };
    test_ng_ok {
        dies_ok { };
    };
}

sub _dies_ok_croak : Test(2) {
    test_ok_ok {
        dies_ok { croak 1 };
    };
    test_ok_ok {
        dies_ok { croak 1 };
    };
}

sub _dies_ok_method : Test(1) {
    test_ok_ok {
        dies_ok { my $x = {}; $x->hoge; };
    };
}

sub _lives_ok : Test(2) {
    test_ok_ok {
        lives_ok {  };
    };
    test_ng_ok {
        lives_ok { die 1 };
    };
}

__PACKAGE__->runtests;

1;


