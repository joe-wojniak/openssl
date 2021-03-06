#! /usr/bin/env perl
# Copyright 2007-2020 The OpenSSL Project Authors. All Rights Reserved.
# Copyright Nokia 2007-2019
# Copyright Siemens AG 2015-2019
#
# Licensed under the Apache License 2.0 (the "License").  You may not use
# this file except in compliance with the License.  You can obtain a copy
# in the file LICENSE in the source distribution or at
# https://www.openssl.org/source/license.html

use strict;
use OpenSSL::Test qw/:DEFAULT data_file srctop_file srctop_dir bldtop_file bldtop_dir/;
use OpenSSL::Test::Utils;

BEGIN {
    setup("test_cmp_client");
}

use lib srctop_dir('Configurations');
use lib bldtop_dir('.');
use platform;

my $no_fips = disabled('fips') || ($ENV{NO_FIPS} // 0);

plan skip_all => "This test is not supported in a no-cmp or no-ec build"
    if disabled("cmp") || disabled("ec");

plan tests => 2 + ($no_fips ? 0 : 2); #fips install + fips test

my @basic_cmd = ("cmp_client_test",
                 data_file("server.key"),
                 data_file("server.crt"),
                 data_file("client.key"),
                 data_file("client.crt"),
                 data_file("client.csr"));

ok(run(test([@basic_cmd, "none"])));

ok(run(test([@basic_cmd, "default", srctop_file("test", "default.cnf")])));

unless ($no_fips) {
    ok(run(app(['openssl', 'fipsinstall',
                '-out', bldtop_file('providers', 'fipsmodule.cnf'),
                '-module', bldtop_file('providers', platform->dso('fips'))])),
       "fipsinstall");

    ok(run(test([@basic_cmd, "fips", srctop_file("test", "fips-and-base.cnf")])));
}
