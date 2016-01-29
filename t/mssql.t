use strict;
use Test::More;

use URI;
my $u = URI->new("db:mssql:");

is( ref( $u->[1] ), 'URI::mssql', "Initial internal object is URI::mssql" );
like( $u->dbi_dsn, qr/^dbi:ODBC:/, "Initial internal object returns ODBC DSN" );

my %int_map = (
    ADO    => '_ado',
    Sybase => 'sybase',
    ODBC   => '_odbc',
);

my @permutations = (
    [ "ADO",    "ODBC",   "Sybase" ],
    [ "ADO",    "Sybase", "ODBC" ],
    [ "ODBC",   "ADO",    "Sybase" ],
    [ "ODBC",   "Sybase", "ADO" ],
    [ "Sybase", "ADO",    "ODBC" ],
    [ "Sybase", "ODBC",   "ADO" ],
);

for my $permutation (@permutations) {
    my $title = "Permutation: @{$permutation}";
    note $title;
    my $u = URI->new("db:mssql:");
    for my $driver ( @{$permutation} ) {
        _main_test( $u, $driver, $title );
    }

    # now that we have an object that has run the current permutation, ensure that we can continue in any combination
    note "Starting Followup Permutations";
    for my $permutation (@permutations) {
        my $new_title = $title . " += @{$permutation}";
        for my $driver ( @{$permutation} ) {
            _main_test( $u, $driver, $new_title );
        }
    }
}

done_testing;

#########################
#### utility functions ##
#########################

sub _main_test {
    my ( $u, $driver, $title ) = @_;

    note "Driver $driver ($title)";

    like( $u->dbi_dsn($driver), qr/^dbi:$driver:/, "dbi_dsn($driver) returns $driver DSO" ) or diag "in $title";
    is( ref( $u->[1] ), "URI::$int_map{$driver}", "post dbi_dsn($driver): internal object is URI::$int_map{$driver}" ) or diag "in $title";
    like( $u->dbi_dsn, qr/^dbi:$driver:/, "post dbi_dsn($driver): subsequent dbi_dsn() returns $driver DSN" ) or diag "in $title";
}
