#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

eval "use Test::Exception; use Test::Warn; use Test::NoWarnings; 1;";
plan skip_all => 'Requires Test::Exception, Test::Warn and Test::NoWarnings' if $@;
plan tests => 11;

use Net::SSLeay;
Net::SSLeay::load_error_strings();

{
    throws_ok(sub {
            Net::SSLeay::die_now('test')
    }, qr/^$$: test\n$/, 'die_now dies without errors');

    lives_ok(sub {
            Net::SSLeay::die_if_ssl_error('test');
    }, 'die_if_ssl_error lives without errors');

    put_err();
    throws_ok(sub {
            Net::SSLeay::die_now('test');
    }, qr/^$$: test\n$/, 'die_now dies with errors');

    put_err();
    throws_ok(sub {
            Net::SSLeay::die_if_ssl_error('test');
    }, qr/^$$: test\n$/, 'die_if_ssl_error dies with errors');
}

{
    local $Net::SSLeay::trace = 1;

    throws_ok(sub {
            Net::SSLeay::die_now('foo');
    }, qr/^$$: foo\n$/, 'die_now dies without arrors and with trace');

    lives_ok(sub {
            Net::SSLeay::die_if_ssl_error('foo');
    }, 'die_if_ssl_error lives without errors and with trace');

    put_err();
    warning_like(sub {
            throws_ok(sub {
                    Net::SSLeay::die_now('foo');
            }, qr/^$$: foo\n$/, 'die_now dies with errors and trace');
    }, qr/^foo $$: 1 - error:2006d080/i, 'die_now raises warnings about the occured error when tracing');

    put_err();
    warning_like(sub {
            throws_ok(sub {
                Net::SSLeay::die_if_ssl_error('foo');
            }, qr/^$$: foo\n$/, 'die_if_ssl_error dies with errors and trace');
    }, qr/^foo $$: 1 - error:2006d080/i, 'die_if_ssl_error raises warnings about the occured error when tracing');
}

sub put_err {
    Net::SSLeay::ERR_put_error(
        32, #lib
       109, #func
       128, #reason
         1, #file
         1, #line
    );
}
