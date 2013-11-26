package URI::db;

# db:engine:dbname
# db:engine:/path/to/some.db
# db:engine://dbname
# db:engine:///path/to/some.db
# db:engine:../relative.db
# db:engine://../relative.db
# db:engine://[netloc][:port][/dbname][?param1=value1&...]
# db:engine://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]

use strict;
use 5.8.1;
use base 'URI::_login';
our $VERSION = '0.10';
use overload '""' => 'as_string', fallback => 1;

my %implementor;

sub _init {
    my ($class, $str, $scheme) = @_;

    $str =~ s/^db://;

    my ($engine, $impclass);
    if ($str =~ /^($URI::scheme_re):/so) {
        $engine = $1;
    } else {
        # No engine detected.
        return $class->_db_init($str);
    }

    $impclass = $implementor{$engine} ||= do {
        # make it a legal perl identifier
        (my $pkg = $engine) =~ s/-/_/g;
        $engine = "_$engine" if $engine =~ /^\d/;

        $pkg = "URI::db::$pkg";

        no strict 'refs';
        unless (@{"${pkg}::ISA"}) {
            # Try to load it
            eval "require $pkg";
            die $@ if $@ && $@ !~ /Can\'t locate.*in \@INC/;
            $pkg = "URI::db" unless @{"${pkg}::ISA"};
        }
        $pkg;
    };

    return $impclass->_db_init($str, $engine);
}

sub _db_init {
    my ($class, $self, $engine) = @_;
    bless \$self => $class;
}

sub scheme { 'db' }

sub engine {
    shift->SUPER::scheme(@_);
}

sub has_recognized_engine {
    ref $_[0] ne 'URI::db';
}

sub as_string {
    my $self = shift;
    return $self->scheme . ':' . $self->SUPER::as_string(@_);
}

sub dbname {
    my $self = shift;
    my @segs = $self->path_segments or return;
    shift @segs if $self->opaque =~ m{^//(?!/)};
    join '/' => @segs;
}

sub query_params {
    my $self = shift;
    require URI::QueryParam;
    return map {
        my $f = $_;
        map { $f => $_ } grep { defined } $self->query_param($f)
    } $self->query_param;
}

sub _dbi_param_map {
    my $self = shift;
    return (
        [ host   => scalar $self->host    ],
        [ port   => scalar $self->_port   ],
        [ dbname => scalar $self->dbname ],
    );
}

sub dbi_params {
    my $self = shift;
    return (
        (
            map { @{ $_ } }
            grep { defined $_->[1] && length $_->[1] } $self->_dbi_param_map
        ),
        $self->query_params,
    );
}

sub dbi_driver { return undef }

sub _dsn_params {
    my $self = shift;
    my @params = $self->dbi_params;
    my @kvpairs;
    while (@params) {
        push @kvpairs => join '=', shift @params, shift @params;
    }
    return join ';' => @kvpairs;
}

sub dbi_dsn {
    my $self = shift;
    my $driver = $self->dbi_driver or return $self->_dsn_params;
    return join ':' => 'dbi', $driver, $self->_dsn_params;
}

1;
__END__

=head1 Name

URI::db - Database URIs

=head1 Synopsis

  use URI;
  my $uri = URI->new('db:pg://user@localhost');

=head1 Description

This class provides support for database URIs. They're inspired by
L<JDBC URIs|http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB> and
L<PostgreSQL URIs|http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING>,
though they're a bit more formal.

=head3 Format

A database URI is made up of these parts:

  db:engine:[//[user[:password]@][netloc][:port]/][dbname][?params]

=over

=item C<db>

The literal string C<db> is the scheme that defines a database URI.

=item C<engine>

A string identifying the database engine.

=item C<user>

The user name to use when connecting to the database.

=item C<password>

The password to use when connecting to the database.

=item C<netloc>

The network location to connect to, such as a host name or IP address.

=item C<port>

The network port to connect to.

=item C<dbname>

The name of the database. For some engines, this will be a file name, in which
case it may be a complete or local path, as appropriate.

=item C<params>

A URI-standard GET query string representing additional parameters to be
passed to the engine.

=back

=head3 Examples

Some examples:

=over

=item C<db:sqlite>

=item C<db:sqlite:dbname>

=item C<db:sqlite:/path/to/some.db>

=item C<db:sqlite://dbname>

=item C<db:sqlite:../relative.db>

=item C<db::sqlite//../relative.db>

=item C<db:firebird:///path/to/some.db>

=item C<db:pg://>

=item C<db:pg://localhost>

=item C<db:pg://localhost:5433>

=item C<db:pg://localhost/mydb>

=item C<db:pg://user@localhost>

=item C<db:pg://user:secret@localhost>

=item C<db:pg://other@localhost/otherdb?connect_timeout=10&application_name=myapp>

=back

=head2 Interface

The following differences exist compared to the C<URI> class interface:

=head3 C<engine>

  my $engine = $uri->engine;

The name of the database engine. This is the "subprotocol", part of the
URI, in the JDBC parlance.

=head3 C<dbname>

  my $dbname = $uri->dbname;

Returns the name of the database.

=head3 C<host>

  my $host = $uri->host;

Returns the host to connect to.

=head3 C<port>

  my $port = $uri->port;

Returns the port to connect to.

=head3 C<user>

  my $user = $uri->user;

Returns the user name.

=head3 C<password>

  my $password = $uri->password;

Returns the password.

=head3 C<has_recognized_engine>

  my $has_recognized_engine = $uri->has_recognized_engine;

Returns true if the engine is recognized by URI::db, and false if it is not. A
recognized engine is simply one that has an implementation in the C<URI::db>
namespace.

=head3 C<query_params>

  my @params = $uri->query_params;

Returns a list of key/value pairs representing all query parameters.
Parameters specified more than once will be returned more than once, so avoid
assigning to a hash. If you want a hash, use L<URI::QueryParam>'s
C<query_from_hash()>, where duplicate keys lead to an array of values for that
key:

  use URI::QueryParam;
  my $params = $uri->query_form_hash;

=head3 C<dbi_driver>

  if ( my $driver = $uri->dbi_driver ) {
      eval "require DBD::$driver" or die;
  }

Returns a string representing the L<DBI> driver name for the database engine,
if one is known. Returns C<undef> if no driver is known.

=head3 C<dbi_dsn>

  DBI->connect( $uri->dbi_dsn, $uri->user, $uri->pass );

Returns a L<DBI> DSN appropriate for use in a call to C<< DBI->connect >>. If
no driver is known for the URI, the C<dbi:$driver:> part of the DSN will be
omitted, in which case you can use the C<$DBI_DRIVER> environment variable to
identify an appropriate driver.

=head3 C<dbi_params>

  my @params = $uri->dbi_params;

Returns a list of key/value pairs used as parameters in the L<DBI> DSN,
including query parameters. Parameters specified more than once will be
returned more than once, so avoid assigning to a hash.

=head1 Support

This module is stored in an open
L<GitHub repository|http://github.com/theory/uri-db/>. Feel free to fork and
contribute!

Please file bug reports via
L<GitHub Issues|http://github.com/theory/uri-db/issues/> or by sending mail to
L<bug-URI-db@rt.cpan.org|mailto:bug-URI-db@rt.cpan.org>.

=head1 Compliance

Formally, a database URI is an opaque URI starting with C<db:> followed by an
embedded server-style URI. For example, this database URI:

  db:pg://localhost/mydb

Is formally the URI C<pg://localhost/mydb> embedded in an opaque C<db:> URI.
It adheres to this formal definition because the scheme part of a URI is not
allowed to contain a sub-scheme (or subprotocol, in the JDBC parlance). It
is therefore a legal URI embedded in a second legal URI

Informally, it's simpler to think of a database URI as a single URI starting
with the combination of the scheme and the engine, e.g., C<db:pg>.

=head1 Author

David E. Wheeler <david@justatheory.com>

=head1 Copyright and License

Copyright (c) 2013 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
