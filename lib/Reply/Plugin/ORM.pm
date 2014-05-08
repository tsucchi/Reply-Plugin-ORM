package Reply::Plugin::ORM;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";
use parent qw/ Reply::Plugin /;
use Path::Tiny;
use Module::Load;

my $ORM;

sub new {
    my ($class, %opts) = @_;

    my $db_name = $ENV{PERL_REPLY_PLUGIN_OTOGIRI};
    return $class->SUPER::new(%opts) unless defined $db_name;
    
    my $config_path = delete $opts{config}
        or Carp::croak "[Error] Please set plugin config file at .replyrc";
    my $config = $class->_config($db_name, $config_path);
    $class->_config_validate($config);

    my $orm_module = "Reply::Plugin::ORM::$config->{orm}";  
    eval "require $orm_module";
    Carp::croak "[Error] $orm_module not found." if $@;

    load $orm_module;
    $ORM = $orm_module->new($db_name => $config, %opts);
    my @methods = (@{$ORM->{methods}}, qw/ Show_dbname Show_methods /);

    no strict 'refs';
    for my $method (@{$ORM->{methods}}) {
        *{"main::$method"} = sub { _command(lc $method, @_ ) };
    }
    *main::Show_dbname  = sub { return $db_name };
    *main::Show_methods = sub { return @methods };
    use strict 'refs';

    return $class->SUPER::new(%opts,
        methods => \@methods,
    );
}    

sub tab_handler {
    my $self = shift;
    my ($line) = @_;

    return if length $line <= 0; 
    return if $line =~ /^#/; # command
    return if $line =~ /->\s*$/; # method call
    return if $line =~ /[\$\@\%\&\*]\s*$/;

    return sort grep {
        index ($_, $line) == 0
    } @{$self->{methods}};
}

sub _config {
    my ($class, $db_name, $config_path) = @_;

    my $config_fullpath = path($config_path);
    Carp::croak "[Error] Plugin config file not found: $config_fullpath" unless -f $config_fullpath;
    my $config = do $config_fullpath 
        or Carp::croak "[Error] Failed to load config file: $config_path";

    return $config->{$db_name}
        or Carp::croak "[Error] '$db_name' not found";
}

sub _config_validate {
    my ($class, $config) = @_;
    Carp::croak "[Error] Please set 'orm' at plugin config file." unless $config->{orm};
    Carp::croak "[Error] Please set 'connect_info' at plugin config file." unless $config->{connect_info};
}

sub _command {
    my $command = shift || '';
    return $ORM->{orm}->$command(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

Reply::Plugin::ORM - Reply + O/R Mapper

=head1 SYNOPSIS

    PERL_REPLY_PLUGIN_OTOGIRI=sandbox reply

    # .replyrc
    ...
    [ORM]
    config = ~/.reply-plugin-orm
    plugin_otogiri = DeleteCascade

    # .reply-plugin-orm
    +{
        sandbox => {
            orm          => 'Otogiri',
            connect_info => ["dbi:SQLite:dbname=...", '', '', { ... }],
        }
    }

=head1 DESCRIPTION

Reply::Plugin::ORM is Reply's plugin for operation of database using O/R Mapper (Otogiri).

=head1 LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

papix E<lt>mail@papix.netE<gt>

=cut

