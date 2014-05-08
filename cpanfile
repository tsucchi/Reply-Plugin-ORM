requires 'perl', '5.008001';
requires 'Reply';
requires 'Path::Tiny';
requires 'Module::Load';
requires 'List::Compare';

on 'recommends' => sub {
    requires 'Otogiri';
};

on 'test' => sub {
    requires 'Test::More', '0.98';
};

