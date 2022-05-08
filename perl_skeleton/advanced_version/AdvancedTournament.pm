use strict;
use warnings;

package AdvancedTournament;
use base_version::Team;
use advanced_version::AdvancedFighter;
use base_version::Tournament;
use List::Util qw(sum);

our @ISA = qw(Tournament); 

sub new{
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{_defeat_record} = [];
    return bless $self, $class;
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

        $team1_fighter->buy_prop_upgrade;
        $team2_fighter->buy_prop_upgrade;

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
            $fighter_first->record_fight(1);
            $fighter_second->record_fight(-1);
            push(@{$self->{_defeated_record}}, $fighter_second->{_NO});
        } else {
            if ($damage_first > $damage_second) {
                $winner_info = "Fighter $fighter_first->{_NO} wins";
                $fighter_first->record_fight(1);
                $fighter_second->record_fight(-1);
            } elsif ($damage_second > $damage_first) {
                $winner_info = "Fighter $fighter_second->{_NO} wins";
                $fighter_first->record_fight(-1);
                $fighter_second->record_fight(1);
            } else {
                $fighter_first->record_fight(0);
                $fighter_second->record_fight(0);
            }
        }

        print "Duel $fight_cnt: Fighter $team1_fighter->{_NO} VS Fighter $team2_fighter->{_NO}, $winner_info\n";
        $team1_fighter->print_info;
        $team2_fighter->print_info;
        $fight_cnt = $fight_cnt + 1;

        $self->update_fighter_properties_and_award_coins($team1_fighter, $team2_fighter->check_defeated, 0);
        $self->update_fighter_properties_and_award_coins($team2_fighter, $team1_fighter->check_defeated, 0);
    }

    print "Fighters at rest:\n";
    while (defined($team1_fighter)) {
        $team1_fighter->print_info();
        $self->update_fighter_properties_and_award_coins($team1_fighter, 0, 1);
        $team1_fighter = $self->{_team1}->get_next_fighter();
    }
    while (defined($team2_fighter)) {
        $team2_fighter->print_info();
        $self->update_fighter_properties_and_award_coins($team2_fighter, 0, 1);
        $team2_fighter = $self->{_team2}->get_next_fighter();
    }
    $self->{_round_cnt} = $self->{_round_cnt} + 1;
}

sub update_fighter_properties_and_award_coins{
    my ( $self, $fighter, $flag_defeat, $flag_rest ) = @_;

    local $AdvancedFighter::coins_to_obtain = $AdvancedFighter::coins_to_obtain;

    my $combo = 0;
    for my $win_score (@{$fighter->{_history_record}}) {
        $combo = $combo + $win_score;
    }

    if ($flag_defeat != 1 and $flag_rest != -1) {
        if ($combo != 3 and $combo !=-3) {
            $fighter->obtain_coins;
            $fighter->update_properties;
            return;
        }
    }

    local $AdvancedFighter::delta_attack = 0;
    local $AdvancedFighter::delta_defense = 0;
    local $AdvancedFighter::delta_speed = 0;

    if ($flag_rest == 1) {
        $AdvancedFighter::coins_to_obtain = int($AdvancedFighter::coins_to_obtain / 2);
        $AdvancedFighter::delta_attack += 1;
        $AdvancedFighter::delta_defense += 1;
        $AdvancedFighter::delta_speed += 1;
    }

    if ($flag_rest != 1 and $combo == 3) {
        $AdvancedFighter::coins_to_obtain = int($AdvancedFighter::coins_to_obtain * 1.1);
        $AdvancedFighter::delta_attack += 1;
        $AdvancedFighter::delta_defense += -2;
        $AdvancedFighter::delta_speed += 1;
        $fighter->{_history_record} = [];
    }

    if ($flag_rest != 1 and $combo == -3) {
        $AdvancedFighter::coins_to_obtain = int($AdvancedFighter::coins_to_obtain * 1.1);
        $AdvancedFighter::delta_attack += -2;
        $AdvancedFighter::delta_defense += 2;
        $AdvancedFighter::delta_speed += 2;
        $fighter->{_history_record} = [];
    }

    if ($flag_defeat == 1) {
        $AdvancedFighter::delta_attack += 1;
        $AdvancedFighter::coins_to_obtain = int($AdvancedFighter::coins_to_obtain * 2);
    }

    $fighter->obtain_coins;
    $fighter->update_properties;
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
                my $fighter = new AdvancedFighter($fighter_idx, $HP, $attack, $defence, $speed);
                push(@fighter_list_team, $fighter);
                last;
            }
            print "Properties violate the constraint\n";
        }
    }
    return \@fighter_list_team;
}


1;