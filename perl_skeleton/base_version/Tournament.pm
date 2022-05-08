use strict;
use warnings;

package Tournament;
use base_version::Team;
use base_version::Fighter;

sub new{
    my $class = shift;
    my $self = {
        _team1 => undef,
        _team2 => undef,
        _round_cnt => 1
    };
    return bless $self, $class;
}

sub set_teams{
    my ( $self, $team1, $team2 ) = @_;
    $self->{_team1} = $team1;
    $self->{_team2} = $team2;
}

sub play_one_round{
    my ( $self ) = @_;
    my $fight_cnt = 1;
    my $team1_fighter;
    my $team2_fighter;
    print "Round $self->{_round_cnt}:\n";

    while (1 == 1) {
        $team1_fighter = $self->{_team1}->get_next_fighter();
        $team2_fighter = $self->{_team2}->get_next_fighter();

        if (not defined($team1_fighter) or not defined ($team2_fighter)) {
            last;
        }

        my $fighter_first = $team1_fighter;
        my $fighter_second = $team2_fighter;
        if ($team1_fighter->{_speed} < $team2_fighter->{_speed}) {
            $fighter_first = $team2_fighter;
            $fighter_second = $team1_fighter;
        }

        my $damage_first = 1;
        my $damage_second = 0;

        if ($fighter_first->{_attack} - $fighter_second->{_defense} > 1) {
            $damage_first = $fighter_first->{_attack} - $fighter_second->{_defense};
        }
        $fighter_second->reduce_HP($damage_first);

        if ($fighter_second->check_defeated!=1) {
            if ($fighter_second->{_attack} - $fighter_first->{_defense} > 1) {
                $damage_second = $fighter_second->{_attack} - $fighter_first->{_defense};
            } else {
                $damage_second = 1;
            }
            $fighter_first->reduce_HP($damage_second);
        }

        my $winner_info = "tie";
        if (not defined($damage_second)) {
            $winner_info = "Fighter $fighter_first->{_NO} wins";
        } else {
            if ($damage_first > $damage_second) {
                $winner_info = "Fighter $fighter_first->{_NO} wins";
            } elsif ($damage_second > $damage_first) {
                $winner_info = "Fighter $fighter_second->{_NO} wins";
            }
        }
        
        print "Duel $fight_cnt: Fighter $team1_fighter->{_NO} VS Fighter $team2_fighter->{_NO}, $winner_info\n";
        $team1_fighter->print_info;
        $team2_fighter->print_info;
        $fight_cnt = $fight_cnt + 1;
    }

    print "Fighters at rest:\n";
    while (defined($team1_fighter)) {
        $team1_fighter->print_info();
        $team1_fighter = $self->{_team1}->get_next_fighter();
    }
    while (defined($team2_fighter)) {
        $team2_fighter->print_info();
        $team2_fighter = $self->{_team2}->get_next_fighter();
    }
    $self->{_round_cnt} = $self->{_round_cnt} + 1;
    
}

sub check_winner(){
    my ( $self ) = @_;

    my $team1_defeated = 1;
    my $team2_defeated = 1;

    my $fighter_list1 = $self->{_team1}->{_fighter_list};
    my $fighter_list2 = $self->{_team2}->{_fighter_list};

    for my $i (@{$fighter_list1}) {
        if ($i->check_defeated != 1) {
            $team1_defeated = 0;
            last;
        }
    }

    for my $i (@{$fighter_list2}) {
        if ($i->check_defeated != 1) {
            $team2_defeated = 0;
            last;
        }
    }

    my $stop = 0;
    my $winner = 0;
    if ($team1_defeated == 1) {
        $winner = 2;
        $stop = 1;
    } elsif ($team2_defeated == 1) {
        $winner = 1;
        $stop = 1;
    }

    return ($stop, $winner);
}

sub input_fighters{
    my ( $self, $team_NO ) = @_;
    my @fighter_list_team = ();
    print "Please input properties for fighters in Team $team_NO\n";
    foreach my $fighter_idx ((4 * ($team_NO - 1) + 1) .. (4 * ($team_NO - 1) + 4)) {
        while (1 == 1) {
            my $properties_input = <STDIN>;
            chomp($properties_input);
            my @properties = split(' ', $properties_input);
            my ( $HP, $attack, $defence, $speed ) = @properties;
            if ($HP + 10 * ($attack + $defence + $speed) <= 500) {
                my $fighter = new Fighter($fighter_idx, $HP, $attack, $defence, $speed);
                push(@fighter_list_team, $fighter);
                last;
            }
            print "Properties violate the constraint\n";
        }
    }
    return \@fighter_list_team;
}

sub play_game{
    my ( $self ) = @_;

    my $fighter_list_team1 = $self->input_fighters(1);
    my $fighter_list_team2 = $self->input_fighters(2);

    my $team1 = new Team(1);
    my $team2 = new Team(2);

    $team1->{_fighter_list} = $fighter_list_team1;
    $team2->{_fighter_list} = $fighter_list_team2;
    $self->set_teams($team1, $team2);

    my $flag_valid;
    my $undefeated_number;
    my ($stop, $winner);
    my @order1 = undef;
    my @order2 = undef;

    print "===========\n";
    print "Game Begins\n";
    print "===========\n";
    print "\n";

    while (1) {
        print "Team 1: please input order\n";
        while (1) {
            my $order1_input = undef;
            $order1_input = <STDIN>;
            @order1 = split(" ", $order1_input);
            $flag_valid = 1;
            $undefeated_number = 0;

            for my $i (@order1) {
                if ($i < 1 or $i > 4) {
                    $flag_valid = 0;
                } elsif (@{$self->{_team1}->{_fighter_list}}[$i-1]->check_defeated) {
                    $flag_valid = 0;
                }
            }
            my $order1_len = @order1;
            for my $i (0 .. ($order1_len - 1)) {
                for my $j (($i + 1) .. ($order1_len - 1)) {
                    if ($i != $j and $order1[$i] == $order1[$j]) {
                        $flag_valid = 0;
                        last;
                    }
                }
            }
            for my $i (0 .. 3) {
                if (@{$self->{_team1}->{_fighter_list}}[$i]->check_defeated != 1) {
                    $undefeated_number += 1;
                }
            }
            if ($undefeated_number != $order1_len) {
                $flag_valid = 0;
            }
            if ($flag_valid) {
                last;
            } else {
                print "Invalid input order\n";
            }
        }

        print "Team 2: please input order\n";
        while (1) {
            my $order2_input = undef;
            $order2_input = <STDIN>;
            @order2 = split(" ", $order2_input);
            $flag_valid = 1;
            $undefeated_number = 0;
            for my $i (@order2) {
                if ($i < 5 or $i > 8) {
                    $flag_valid = 0;
                } elsif (@{$self->{_team2}->{_fighter_list}}[$i-1-4]->check_defeated) {
                    $flag_valid = 0;
                }
            }
            my $order2_len = @order2;
            for my $i (0 .. ($order2_len - 1)) {
                for my $j (($i + 1) .. ($order2_len - 1)) {
                    if ($i != $j and $order2[$i] == $order2[$j]) {
                        $flag_valid = 0;
                        last;
                    }
                }
            }
            for my $i (0 .. 3) {
                if (@{$self->{_team2}->{_fighter_list}}[$i]->check_defeated != 1) {
                    $undefeated_number += 1;
                }
            }
            if ($undefeated_number != $order2_len) {
                $flag_valid = 0;
            }
            if ($flag_valid) {
                last;
            } else {
                print "Invalid input order\n";
            }
        }

        $self->{_team1}->set_order(\@order1);
        $self->{_team2}->set_order(\@order2);
        $self->play_one_round;

        ($stop, $winner) = $self->check_winner;
        if ($stop == 1) {
            last;
        }
    }

    print "Team $winner wins.\n";
}
1;