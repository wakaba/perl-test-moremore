package Test::MoreMore::Mock;
use strict;
use warnings;
our $VERSION = '1.0';
use base qw(
    Class::Accessor::Fast
    Class::Data::Inheritable
);

# --- Class methods ---

sub add_to_inc {
    my $class = shift;
    $class =~ s/^Test:://; # XXX
    $class =~ s{::}{/}g;
    $class .= '.pm';
    $INC{$class} = 1;
}

sub become_parent_of_real_class {
    my $class = shift;
    my $real = $class;
    $real =~ s/^Test:://; # XXX

    no strict 'refs';
    push @{$real . '::ISA'}, $class;
}

sub copy_methods_to_real_class {
    my $class = shift;
    my @method = @_;

    my $real = $class;
    $real =~ s/^Test:://; # XXX

    no strict 'refs';
    *{$real . '::' . $_} = $class->can($_) for @method;
}

# --- Instantiation ---

sub new {
    my $class = shift;

    my $self;
    if (ref $_[0] eq 'HASH') {
        $self = $class->SUPER::new(@_);
    } else {
        $self = $class->SUPER::new({@_});
    }

    $self->_new_props;
    return $self;
}

sub _new_props { }

sub param {
    my $self = shift;
    unless (@_) {
        return (keys %{$self->{param} or {}});
    }

    my $name = shift;

    if (@_) {
        $self->{param}->{$name} = +shift;
    }

    return $self->{param}->{$name};
}

sub debug_info {
    my $self = shift;
    return $self->{debug_info};
}

sub AUTOLOAD {
    if (our $AUTOLOAD =~ /([^:]+)$/) {
        no strict 'refs';
        my $name = $1;
        *$AUTOLOAD = sub {
            my $self = shift;
            if (@_) {
                $self->{$name} = shift;
            }
            return $self->{$name};
        };
        goto &$AUTOLOAD;
    } else {
        die "AUTOLOAD: no $AUTOLOAD";
    }
}

1;
