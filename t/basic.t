use Test::Most;

BEGIN {
  package MyApp::Schema::User;
  $INC{'MyApp/Schema/User.pm'} = __FILE__;

  use base 'DBIx::Class::Core';
 
  __PACKAGE__->table("users");
  __PACKAGE__->add_columns(
    id => { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    first_name => { data_type => "varchar", size => 100 });

  __PACKAGE__->set_primary_key("id");
  __PACKAGE__->add_unique_constraint([ qw/first_name/ ]);

  package MyApp::Schema;
  $INC{'MyApp/Schema.pm'} = __FILE__;

  use base 'DBIx::Class::Schema';
 
  __PACKAGE__->load_classes('User');
}

{
  package MyApp::Model::Schema;
  $INC{'MyApp/Model/Schema.pm'} = __FILE__;

  use Moose;
  extends 'Catalyst::Model::DBIC::Schema';

  package MyApp::Controller::Example;
  $INC{'MyApp/Controller/Example.pm'} = __FILE__;

  use base 'Catalyst::Controller';

  sub user :Local Args(1) {
    my ($self, $c) = @_;
    Test::Most::ok (my $user = $c->model('Schema::User::Result'));

    $c->res->body('test');
  }

  sub user_with_attr :Local Args(1) ResultModelFrom(first_name=>$args[0]) {
    my ($self, $c) = @_;
    Test::Most::ok (my $user = $c->model('Schema::User::Result'));

    $c->res->body('test');
  }

  package MyApp;
  use Catalyst;
  use Test::DBIx::Class
    -schema_class => 'MyApp::Schema', qw/User Schema/;

  User->populate([
    ['first_name'],
    [qw/john joe mark matt/]]);

  MyApp->config(
    'Model::Schema' => {
      traits => ['Result'],
      schema_class => 'MyApp::Schema',
      connect_info => [ sub { Schema()->storage->dbh } ],
    },
  );

  MyApp->setup;

}

use Catalyst::Test 'MyApp';

{
  my ($res, $c) = ctx_request( '/example/user/1' );
}

{
  my ($res, $c) = ctx_request( '/example/user_with_attr/john' );
}

done_testing;
