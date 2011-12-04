package Test::MoreMore;
use strict;
use warnings;
our $VERSION = '1.1';
use Test::More;
require Test::Differences;
use Exporter::Lite;

our @EXPORT = (
    @Test::More::EXPORT,
    qw(
        ng
        is_bool
        is_datetime
        isa_list_ok
        isa_list_n_ok
        sort_ok
        now_ok
        eq_or_diff
        lives_ok
        dies_ok
    ),
);

for my $function (qw(note diag explain)) {
    unless (Test::More->can($function)) {
        no strict 'refs';
        *{'Test::MoreMore::' . $function} = sub (@) {
            #
        };
        push @EXPORT, $function;
    }
}

sub eq_or_diff;

sub ng ($;$) {
    my ($test, $name) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    ok(!$test, $name);
}

sub is_bool ($$;$) {
    my ($v1, $v2, $name) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    is !!$v1, !!$v2, $name;
}

sub is_datetime ($$;$) {
    my ($dt1, $dt2, $name) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    unless (UNIVERSAL::isa($dt1, 'DateTime')) {
        isa_ok $dt1, 'DateTime', $name;
        return;
    }
    unless (UNIVERSAL::isa($dt2, 'DateTime')) {
        is $dt1 . '', $dt2, $name;
        return;
    }
    if ($dt1->epoch == $dt2->epoch) {
        is $dt1->epoch, $dt2->epoch, $name;
    } else {
        is $dt1 . '', $dt2 . '', $name;
    }
}

sub isa_list_ok ($;$) {
    my ($obj, $name) = @_;

    if (UNIVERSAL::isa($obj, 'DBIx::MoCo::List')) {
        ok 1, $name;
        return 1;
    }

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    isa_ok $obj, 'List::Rubyish', $name;
}

sub isa_list_n_ok ($$;$) {
    my ($obj, $n, $name) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    if (UNIVERSAL::isa($obj, 'DBIx::MoCo::List')) {
        is $obj->length, $n, $name;
        return 1;
    } elsif (UNIVERSAL::isa($obj, 'List::Rubyish')) {
        is $obj->length, $n, $name;
        return 1;
    }

    isa_ok $obj, 'List::Rubyish', $name;
}

sub sort_ok (&$$;$) {
    my ($code, $actual_list, $expected_list, $name) = @_;
    eq_or_diff
        $actual_list->sort($code)->to_a,
        $expected_list->sort($code)->to_a,
        $name;
}

sub now_ok ($;$) {
    my ($obj, $name) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unless (UNIVERSAL::isa($obj, 'DateTime')) {
        isa_ok $obj, 'DateTime', $name;
        return;
    }

    my $now = time;
    my $diff = abs $obj->epoch - $now;
    if ($diff < 60) {
        ok 1, $name;
    } else {
        is $obj . '', $now . '';
    }
}

sub eq_or_diff {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    no warnings 'redefine';
    local $Data::Dumper::Useqq = 1;
    local *Data::Dumper::qquote = sub {
        my $s = shift;
        
        local $@;
        eval {
            # Perl 5.8.8 in some environment does not handle utf8
            # string with surrogate code points well (it breaks the
            # string when it is passed to another subroutine even when
            # it can be accessible only via traversing reference
            # chain, very strange...), so |eval| this statement.

            $s =~ s/([\x00-\x1F\x27\x5C\x7F-\xA0])/sprintf '\x{%02X}', ord $1/ge;
            1;
        } or warn $@;

        # We does not want to distinguish |0| and |'0'|.
        return q<qq'> . $s . q<'>;
    };

    return Test::Differences::eq_or_diff(@_);
}

sub lives_ok (&;$) {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    local $Carp::CarpLevel = $Carp::CarpLevel + 2;
    my ($code, $name) = @_;
    local $@ = undef;
    eval {
        $code->();
        ok 1, $name;
        1;
    } or do {
        if (defined $@) {
            is $@, undef, $name;
        } else {
            ng 1, $name;
        }
    };
}

sub dies_ok (&;$) {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    local $Carp::CarpLevel = $Carp::CarpLevel + 2;
    my ($code, $name) = @_;
    local $@ = undef;
    eval {
        $code->();
        ng 1, $name;
        1;
    } or do {
        ok 1, $name || do { my $v = $@; $v =~ s/\n$//; $v };
    };
}

1;
