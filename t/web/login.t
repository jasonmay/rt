use strict;
use warnings;

use RT::Test tests => 21;

my ( $baseurl, $m ) = RT::Test->started_ok;

my $ticket = RT::Test->create_ticket(
    Subject => 'ticket_foo',
    Queue   => 'General',
);

my ( $user, $pass ) = ( 'root', 'password' );

diag "normal login";
{
    $m->get($baseurl);
    $m->title_is('Login');
    is( $m->uri, $baseurl, "right url" );
    $m->submit_form(
        form_id => 'login',
        fields  => {
            user => $user,
            pass => $pass,
        }
    );

    $m->title_is( 'RT at a glance', 'logged in' );

    $m->follow_link_ok( { text => 'Logout' }, 'follow logout' );
    $m->title_is( 'Logout', 'logout' );
}

diag "tangent login";

{
    $m->get( $baseurl . '/Ticket/Display.html?id=1' );
    $m->title_is('Login');
    $m->submit_form(
        form_id => 'login',
        fields  => {
            user => $user,
            pass => $pass,
        }
    );
    like( $m->uri, qr{/Ticket/Display\.html}, 'normal ticket page' );
    $m->follow_link_ok( { text => 'Logout' }, 'follow logout' );
}

diag "mobile normal login";
{

    # default browser in android 2.3.6
    $m->agent(
"Mozilla/5.0 (Linux; U; Android 2.3.6; en-us; Nexus One Build/GRK39F) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
    );

    $m->get($baseurl);
    is( $m->uri, $baseurl, "right url" );
    $m->content_contains( "/m/index.html?NotMobile=1", 'mobile login' );
    $m->submit_form(
        form_id => 'login',
        fields  => {
            user => $user,
            pass => $pass,
        }
    );
    is( $m->uri, $baseurl . '/m/', "mobile url" );
    $m->follow_link_ok( { text => 'Logout' }, 'follow logout' );
    like( $m->uri, qr{/NoAuth/Login\.html}, 'back to login page' );
}

diag "mobile tangent login";
{
    $m->get( $baseurl . '/Ticket/Display.html?id=1' );
    $m->content_contains( "/m/index.html?NotMobile=1", 'mobile login' );
    $m->submit_form(
        form_id => 'login',
        fields  => {
            user => $user,
            pass => $pass,
        }
    );
    like( $m->uri, qr{/m/ticket/show}, 'mobile ticket page' );
}

