package URI::oracle;
use base 'URI::_db';
our $VERSION = '0.23';

sub default_port { 1521 }
sub dbi_driver   { 'Oracle' }

sub _dsn_params {
    my $self = shift;
    my $name = $self->dbname || '';
    my $dsn = $self->host;

    if (my $p = $self->_port) {
        $dsn .= ":$p";
    }

    return $name unless $dsn;
    $dsn .= "/$name";


    if (my @p = $self->query_params) {
        my @kvpairs;
        while (@p) {
            push @kvpairs => join '=', shift @p, shift @p;
        }
        $dsn .= '?' . join '&' => @kvpairs;
    }

    return "//$dsn";
}

1;
