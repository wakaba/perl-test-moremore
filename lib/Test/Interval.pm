package Test::Interval;
use strict;
use warnings;
our $VERSION = '1.0';
use Time::HiRes qw(gettimeofday tv_interval nanosleep);
use Test::More;
use Exporter::Lite;

our @EXPORT = qw(ms_ok);

our $VERBOSE ||= $ENV{TEST_INTERVAL_VERBOSE};

sub ms_ok (&$;$) {
    my ($code, $expected_ms, $name) = @_;
    
    my $t1 = [gettimeofday];
    $code->();
    my $actual_s = tv_interval ($t1);
    my $actual_ms = $actual_s * 1000;
    
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    if ($actual_ms <= $expected_ms) {
        if ($VERBOSE) {
            my $expected_s = $expected_ms / 1000;
            diag sprintf '%d s %d ms (Expected: %d s %d ms)',
                $actual_s, $actual_ms % 1000,
                $expected_s, $expected_ms % 1000;
        }
        ok 1, $name;
    } else {
        my $expected_s = $expected_ms / 1000;
        diag sprintf '%d s %d ms (Expected: %d s %d ms)',
            $actual_s, $actual_ms % 1000,
            $expected_s, $expected_ms % 1000;
        is $actual_ms, $expected_ms, $name;
    }
}

1;
