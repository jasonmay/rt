# BEGIN BPS TAGGED BLOCK {{{
# 
# COPYRIGHT:
# 
# This software is Copyright (c) 1996-2009 Best Practical Solutions, LLC
#                                          <jesse@bestpractical.com>
# 
# (Except where explicitly superseded by other copyright notices)
# 
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
# 
# END BPS TAGGED BLOCK }}}

package RT::Condition::BeforeDue;
use base 'RT::Condition';

use RT::Date;

use strict;

sub IsApplicable {
    my $self = shift;

    # Parse date string.  Format is "1d2h3m4s" for 1 day and 2 hours
    # and 3 minutes and 4 seconds.
    my %e;
    foreach (qw(d h m s)) {
	my @vals = $self->Argument =~ m/(\d+)$_/;
	$e{$_} = pop @vals || 0;
    }
    my $elapse = $e{'d'} * 24*60*60 + $e{'h'} * 60*60 + $e{'m'} * 60 + $e{'s'};

    my $cur = new RT::Date( $RT::SystemUser );
    $cur->SetToNow();
    my $due = $self->TicketObj->DueObj;
    return (undef) if $due->Unix <= 0;

    my $diff = $due->Diff($cur);
    if ( $diff >= 0 and $diff <= $elapse ) {
        return(1);
    } else {
        return(undef);
    }
}

eval "require RT::Condition::BeforeDue_Vendor";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/Condition/BeforeDue_Vendor.pm});
eval "require RT::Condition::BeforeDue_Local";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/Condition/BeforeDue_Local.pm});

1;