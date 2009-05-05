#!/usr/bin/perl

use Test::More tests => 24;
use RT::Test;

use strict;
use warnings;

use RT::Model::TicketCollection;
use RT::Model::Queue;
use RT::Model::CustomField;

# Test Sorting by custom fields.

diag "Create a queue to test with." if $ENV{TEST_VERBOSE};
my $queue_name = "CFSortQueue-$$";
my $queue;
{
    $queue = RT::Model::Queue->new(current_user => RT->system_user );
    my ($ret, $msg) = $queue->create(
        name =>  $queue_name,
        description =>  'queue for custom field sort testing'
    );
    ok($ret, "$queue_name - test queue creation. $msg");
}

diag "create a CF\n" if $ENV{TEST_VERBOSE};
my $cf_name = "Order$$";
my $cf;
{
    $cf = RT::Model::CustomField->new( current_user => RT->system_user );
    my ($ret, $msg) = $cf->create(
        name  => $cf_name,
        queue => $queue->id,
        type  => 'FreeformMultiple',
    );
    ok($ret, "Custom Field Order created");
}

my ($total, @data, @tickets, @test) = (0, ());

sub add_tix_from_data {
    my @res = ();
    @data = sort { rand(100) <=> rand(100) } @data;
    while (@data) {
        my $t = RT::Model::Ticket->new(current_user => RT->system_user);
        my %args = %{ shift(@data) };
        my @values = ();
        if ( exists $args{'CF'} && ref $args{'CF'} ) {
            @values = @{ delete $args{'CF'} };
        } elsif ( exists $args{'CF'} ) {
            @values = (delete $args{'CF'});
        }
        $args{ 'CustomField-'. $cf->id } = \@values
            if @values;
        my $subject = join(",", sort @values) || '-';
        my ( $id, undef $msg ) = $t->create(
            %args,
            queue => $queue->id,
            subject => $subject,
        );
        ok( $id, "ticket created" ) or diag("error: $msg");
        push @res, $t;
        $total++;
    }
    return @res;
}

sub run_tests {
    my $query_prefix = join ' OR ', map 'id = '. $_->id, @tickets;
    foreach my $test ( @test ) {
        my $query = join " AND ", map "( $_ )", grep defined && length,
            $query_prefix, $test->{'Query'};

        foreach my $order (qw(ASC DESC)) {
            my $error = 0;
            my $tix = RT::Model::TicketCollection->new(current_user => RT->system_user );
            $tix->from_sql( $query );
            $tix->order_by( column => $test->{'column'}, order => $order );

            ok($tix->count, "found ticket(s)")
                or $error = 1;

            my ($order_ok, $last) = (1, $order eq 'ASC'? '-': 'zzzzzz');
            my $last_id = $tix->last->id;
            while ( my $t = $tix->next ) {
                my $tmp;
                next if $t->id == $last_id and $t->subject eq "-"; # Nulls are allowed to come last, in Pg

                if ( $order eq 'ASC' ) {
                    $tmp = ((split( /,/, $last))[0] cmp (split( /,/, $t->subject))[0]);
                } else {
                    $tmp = -((split( /,/, $last))[-1] cmp (split( /,/, $t->subject))[-1]);
                }
                if ( $tmp > 0 ) {
                    $order_ok = 0; last;
                }
                $last = $t->subject;
            }

            ok( $order_ok, "$order order of tickets is good" )
                or $error = 1;

            if ( $error ) {
                diag "Wrong SQL query:". $tix->build_select_query;
                $tix->goto_first_item;
                while ( my $t = $tix->next ) {
                    diag sprintf "%02d - %s", $t->id, $t->subject;
                }
            }
        }
    }
}

@data = (
    { },
    { cf => ['b', 'd'] },
    { cf => ['a', 'c'] },
);
@tickets = add_tix_from_data();
@test = (
    { column => "CF.{$cf_name}" },
    { column => "CF.$queue_name.{$cf_name}" },
);
run_tests();

@data = (
    { cf => ['m', 'a'] },
    { cf => ['m'] },
    { cf => ['m', 'o'] },
);
@tickets = add_tix_from_data();
@test = (
    { column => "CF.{$cf_name}", query => "CF.{$cf_name} = 'm'" },
    { column => "CF.$queue_name.{$cf_name}", query => "CF.{$cf_name} = 'm'" },
);
run_tests();

