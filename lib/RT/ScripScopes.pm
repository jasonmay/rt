# Copyright 1999-2000 Jesse Vincent <jesse@fsck.com>
# Released under the terms of the GNU Public License
# $Header$

package RT::ScripScopes;
use RT::EasySearch;
@ISA= qw(RT::EasySearch);

# Removed the new() method.  It's redundant, we'll use
# RT::EasySearch::new instead.

# {{{ sub _Init
sub _Init { 
  my $self = shift;
  $self->{'table'} = "ScripScope";
  $self->{'primary_key'} = "id";
  return ( $self->SUPER::_Init(@_));
}
# }}}

# {{{ sub Limit 

# In this case, we want the default aggregator to be AND rather than OR

sub Limit  {
  my $self = shift;
  my %args = ( ENTRYAGGREGATOR => 'AND',
	       @_);
 
  $self->SUPER::Limit(%args);
}
# }}}

# {{{ sub LimitToQueue 

=head2 LimitToQueue

Takes a queue id (numerical) as its only argument. Makes sure that 
Scopes it pulls out apply to this queue (or another that you've selected with
another call to this method

=cut

sub LimitToQueue  {
   my $self = shift;
  my $queue = shift;
 
  $self->Limit (ENTRYAGGREGATOR => 'OR',
		FIELD => 'Queue',
		VALUE => "$queue")
      if defined $queue;
  
}
# }}}

# {{{ sub LimitToGlobal

=head2 LimitToGlobal

Makes sure that 
Scopes it pulls out apply to all queues (or another that you've selected with
another call to this method or LimitToQueue

=cut

sub LimitToGlobal  {
   my $self = shift;
 
  $self->Limit (ENTRYAGGREGATOR => 'OR',
		FIELD => 'Queue',
		VALUE => 0);
  
}
# }}}

# {{{ sub NewItem 
sub NewItem  {
  my $self = shift;
  my $item;

  use RT::ScripScope;
  $item = new RT::ScripScope($self->CurrentUser);
  return($item);
}
# }}}


1;

