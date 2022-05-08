use strict;
use warnings;


package Team;

sub new {
    my $class = shift;
    my $self = {
        _NO => shift,
        _fighter_list => undef,
        _order => undef,
        _fight_cnt => 0
    };
    return bless $self, $class;
};

sub set_fighter_list{
    my ( $self, $fighter_list ) = @_;
    $self->{_fighter_list} = $fighter_list;
}

sub get_fighter_list{
    my ( $self ) = @_;
    return $self->{_fighter_list};
}

sub set_order{
    my ( $self, $order ) = @_;
    $self->{_order} = ();
    for my $a_order (@{$order}) {
        push(@{$self->{_order}}, $a_order);
    }
    $self->{_fight_cnt} = 0;
}

sub get_next_fighter{
    my ( $self ) = @_;
    my $order_length = @{$self->{_order}};
    if ($self->{_fight_cnt}>=$order_length) {
        return undef;
    }
    my $prev_fighter_idx = @{$self->{_order}}[$self->{_fight_cnt}];
    my $fighter = undef;
    for my $a_fighter (@{$self->{_fighter_list}}) {
        if ($a_fighter->{_NO}==$prev_fighter_idx) {
            $fighter = $a_fighter;
            last;
        }
    }
    $self->{_fight_cnt} = $self->{_fight_cnt} + 1;
    return $fighter;
}

1;