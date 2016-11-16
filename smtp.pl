#!/usr/bin/env perl
use utf8;
use strict;
use warnings;
use feature 'say';
binmode(STDOUT,":utf8");

use Mail::SimpleSender;
use Mail::SimpleSender::SMTP;

my $ms=Mail::SimpleSender->new(
	to      => 'user@domain.dom',
	from    => '送り主 <user@domain.dom>',
	bcc     => 'user2@domain.dom',
	subject	=> 'サブジェクト'
);
$ms->text("本文");

my $smtp=Mail::SimpleSender::SMTP->new('SMTP_SERVER',Timeout=>60,Debug=>1);
$smtp->send($ms);

