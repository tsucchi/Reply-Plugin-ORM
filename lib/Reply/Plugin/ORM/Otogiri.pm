package Reply::Plugin::ORM::Otogiri;
use strict;
use warnings;

use List::Compare;
use Module::Load;
use Path::Tiny;

my @UNNECESSARY_METHODS = qw/
    _deflate_param
    _inflate_rows
    BEGIN
    import
    load_plugin
    maker
    new
/;

sub new {
    my ($class, $db_name, $config, %opts) = @_;

    eval { require Otogiri };
    Carp::croak "[Error] Module 'Otogiri' not found." if $@;
    eval { require Otogiri::Plugin };
    Carp::croak "[Error] Module 'Otogiri::Plugin' not found." if $@;

    load 'Otogiri'; 
    load 'Otogiri::Plugin'; 

    if ($opts{otogiri_plugins}) {
        Otogiri->load_plugin($_) for split /,/, $opts{otogiri_plugins};
    } 
    my $orm = Otogiri->new( %{ $config } );

    my $self = bless { orm => $orm }, $class;
    my @methods = $self->methods();
    $self->{methods} = \@methods;
    return $self;
}

sub methods {
    my ($self) = @_;
    my $list = List::Compare->new([ grep { $_ !~ /^_/ } keys %{DBIx::Otogiri::} ], \@UNNECESSARY_METHODS);
    my @methods = map { s/(^.)/uc $1/e; $_ } $list->get_Lonly;
    return @methods;
}

1;
