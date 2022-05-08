use strict;
use warnings;

package Fighter;


sub new{
  my $class = shift;
  my $self = {
    _NO => shift,
    _HP => shift,
    _attack => shift,
    _defense => shift,
    _speed => shift,
    _defeated => 0
  };
  return bless $self, $class;
}

sub get_properties{
  my ( $self ) = @_;
  return %{$self};
}

sub reduce_HP{
  my ( $self, $damage ) = @_;
  $self->{_HP} = $self->{_HP} - $damage;
  if ($self->{_HP}<=0) {
    $self->{_HP} = 0;
    $self->{_defeated} = 1;
  }
}

sub check_defeated{
  my ( $self ) = @_;
  return $self->{_defeated};
}

sub print_info{
  my ( $self ) = @_;
  
  my $defeated_info;
  if ($self -> check_defeated() == 1){
    $defeated_info = "defeated";
  }else{
    $defeated_info = "undefeated";
  }
  print "Fighter $self->{_NO}: HP: $self->{_HP} attack: $self->{_attack} defense: $self->{_defense} speed: $self->{_speed} $defeated_info\n";
}


1;
