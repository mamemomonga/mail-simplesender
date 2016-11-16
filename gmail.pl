#!/usr/bin/env perl
# メール文章を作成しGmailの下書きに保存する
use utf8;
use strict;
use warnings;
use feature 'say';
binmode(STDOUT,":utf8");

use Mail::SimpleSender;
use Mail::SimpleSender::Gmail;

my $ms=Mail::SimpleSender->new(
	to      => 'user@domain.dom',
	from    => '送り主 <user@domain.dom>',
	bcc     => 'user2@domain.dom',
	subject	=> 'サブジェクト'
);
$ms->text("本文");

my $gmail=Mail::SimpleSender::Gmail->new(
	client_secret_file => 'var/client_secret.json',
	access_token_file  => 'var/token.json',
	user_id            => 'GMAIL_USER_ID'
);
$gmail->auth();
$gmail->send_draft($ms);

