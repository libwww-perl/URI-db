package URI::db;

# db://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]

use strict;
use 5.8.1;
use base 'URI::_login';

sub db_name {
    my (undef, @segs) = shift->path_segments or return;
    join '/' => @segs;
}

1;
__END__

=head1 Name

URI::db - Database URIs

=head1 Synopsis

  use URI;
  my $uri = URI->new('postgresql://user@localhost');

=head1 Description

This class provides support for database URIs. They're modeled on
L<JDBC URIs|http://docs.oracle.com/cd/B14117_01/java.101/b10979/urls.htm#BEIJFHHB> and
L<PostgreSQL URIs|>http://www.postgresql.org/docs/9.3/static/libpq-connect.html#LIBPQ-CONNSTRING.

=head2 Interface

The following differences exist compared to the C<URI> class interface:

=head3 C<db_name>

Returns the name of the database.

=head3 C<host>

Returns the host to connect to.

=head3 C<port>

Returns the port to connect to.

=head3 C<user>

Returns the user name.

=head3 C<password>

Returns the password.

=head1 Support

This module is stored in an open
L<GitHub repository|http://github.com/theory/uri-db/>. Feel free to fork and
contribute!

Please file bug reports via
L<GitHub Issues|http://github.com/theory/uri-db/issues/> or by sending mail to
L<bug-URI-db@rt.cpan.org|mailto:bug-URI-db@rt.cpan.org>.

=head1 Author

David E. Wheeler <david@kineticode.com>

=head1 Copyright and License

Copyright (c) 2013 David E. Wheeler. Some Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
