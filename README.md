# NAME

Reply::Plugin::ORM - Reply + O/R Mapper

# SYNOPSIS

    PERL_REPLY_PLUGIN_ORM=sandbox reply

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

# DESCRIPTION

Reply::Plugin::ORM is Reply's plugin for operation of database using O/R Mapper (Otogiri).

# LICENSE

Copyright (C) papix.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

papix <mail@papix.net>
