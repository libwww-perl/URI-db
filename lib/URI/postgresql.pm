package URI::postgresql;
use base 'URI::db';

# postgresql://[user[:password]@][netloc][:port][/dbname][?param1=value1&...]

sub default_port { 5432 }

1;
