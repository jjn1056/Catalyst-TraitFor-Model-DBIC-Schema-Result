package Catalyst::TraitFor::Model::DBIC::Schema::Result;

use Moose::Role;

after '_install_rs_models', sub {
  my $self  = shift;
  my $class = $self->_original_class_name;
 
  no strict 'refs';
  my @sources = $self->schema->sources;
  die "No sources for your schema" unless @sources;

  foreach my $moniker (@sources) {
    my $classname = "${class}::${moniker}::Result";
    *{"${classname}::ACCEPT_CONTEXT"} = sub {
      my ($result_self, $c, @args) = @_;
      warn "You passed args '@args' but we can't use them" if @args;
      my $id = '__' . ref($result_self);
      return $c->stash->{$id} ||= $c->model($self->model_name)
        ->resultset($moniker)
          ->find(@{$c->request->args}); # this line is pretty much the whole point
    };
  }
};

1;

=head1 NAME

Catalyst::TraitFor::Model::DBIC::Schema::Result - PerRequest Result from Catalyst Request

=head1 SYNOPSIS

In your configuration, set the trait:

    MyApp->config(
      'Model::Schema' => {
        traits => ['Result'],
        schema_class => 'MyApp::Schema',
        connect_info => [ ... ],
      },
    );

Now in your actions you can call the generated models, which get their ->find($id) from
$c->request->args.

  sub user :Local Args(1) {
    my ($self, $c) = @_;
    my $user = $c->model('Schema::User::Result');
  }

=head1 DESCRIPTION

Its a common case to get the result of a L<DBIx::Class> ->find based on the current
L<Catalyst> request (typically from the Args attribute).  This is an experimental trait
to see if we can usefull encapsulate that common task in a way that is not easily broken.

If you can't read the source code and figure out what is going on, might want to stay
away for now!

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Model::DBIC::Schema>.

=head1 AUTHOR
 
John Napiorkowski L<email:jjnapiork@cpan.org>
  
=head1 COPYRIGHT & LICENSE
 
Copyright 2015, John Napiorkowski L<email:jjnapiork@cpan.org>
 
This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
