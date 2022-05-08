use strict;
use warnings;

package AdvancedFighter;

use base_version::Fighter;
use List::Util qw(sum);

our @ISA = qw(Fighter); 

our $coins_to_obtain = 20;
our $delta_attack = -1;
our $delta_defense = -1;
our $delta_speed = -1;


sub new{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{_coins} = 0;
    $self->{_history_record} = [];
    return bless $self, $class;
}

sub obtain_coins{
    my ( $self ) = @_;
    $self->{_coins} = $self->{_coins} + $coins_to_obtain;
}

sub buy_prop_upgrade{
    my ( $self ) = @_;
    while ($self->{_coins}>=50) {
        print "Do you want to upgrade properties for Fighter $self->{_NO}? A for attack. D for defense. S for speed. N for no.\n";
        my $action = <STDIN>;
        chomp($action);
        if ($action eq "A") {
            $self->{_attack} = $self->{_attack} + 1;
        }
        if ($action eq "D") {
            $self->{_defense} = $self->{_defense} + 1;
        }
        if ($action eq "S") {
            $self->{_speed} = $self->{_speed} + 1;
        }
        if ($action eq "N") {
            last;
        }
        $self->{_coins} = $self->{_coins} - 50;
    }
}

sub record_fight{
    my ( $self, $fight_result ) = @_;
    push(@{$self->{_history_record}}, $fight_result);
    my $history_record_len = @{$self->{_history_record}};
    if ($history_record_len > 3) {
        shift(@{$self->{_history_record}});
    }
}


sub update_properties{
    my ( $self ) = @_;
    $self->{_attack} = $self->{_attack} + $delta_attack;
    if ($self->{_attack} < 1) {
        $self->{_attack} = 1;
    }
    $self->{_defense} = $self->{_defense} + $delta_defense;
    if ($self->{_defense} < 1) {
        $self->{_defense} = 1;
    }
    $self->{_speed} = $self->{_speed} + $delta_speed;
    if ($self->{_speed} < 1) {
        $self->{_speed} = 1;
    }
}
